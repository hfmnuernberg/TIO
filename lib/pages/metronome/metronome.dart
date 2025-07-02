import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/app.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/metronome_block.dart';
import 'package:tiomusic/models/metronome_sound.dart';
import 'package:tiomusic/models/metronome_sound_extension.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/pages/metronome/advanced_rhythm_group_editor.dart';
import 'package:tiomusic/pages/metronome/metronome_functions.dart';
import 'package:tiomusic/pages/metronome/metronome_utils.dart';
import 'package:tiomusic/pages/metronome/setting_bpm.dart';
import 'package:tiomusic/pages/metronome/setting_metronome_sound.dart';
import 'package:tiomusic/pages/metronome/setting_random_mute.dart';
import 'package:tiomusic/pages/parent_tool/parent_island_view.dart';
import 'package:tiomusic/pages/parent_tool/parent_tool.dart';
import 'package:tiomusic/pages/parent_tool/setting_volume_page.dart';
import 'package:tiomusic/pages/parent_tool/settings_tile.dart';
import 'package:tiomusic/pages/parent_tool/volume.dart';
import 'package:tiomusic/services/file_system.dart';
import 'package:tiomusic/services/project_repository.dart';
import 'package:tiomusic/src/rust/api/api.dart';
import 'package:tiomusic/src/rust/api/modules/metronome.dart';
import 'package:tiomusic/util/app_snackbar.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/util/log.dart';
import 'package:tiomusic/util/tutorial_util.dart';
import 'package:tiomusic/util/util_functions.dart';
import 'package:tiomusic/widgets/confirm_dialog.dart';
import 'package:tiomusic/widgets/custom_border_shape.dart';
import 'package:tiomusic/widgets/metronome/color_painter.dart';
import 'package:tiomusic/widgets/metronome/current_beat.dart';
import 'package:tiomusic/widgets/metronome/rhythms.dart';
import 'package:tiomusic/widgets/on_off_button.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:volume_controller/volume_controller.dart';

int calcMsUntilNextFlashOn(int eventDelayInMs, int avgRenderTimeInMs) => eventDelayInMs + avgRenderTimeInMs;

int calcMsUntilNextFlashOff(int msUntilNextFlashOn) => msUntilNextFlashOn + MetronomeParams.flashDurationInMs;

class Metronome extends StatefulWidget {
  final bool isQuickTool;

  const Metronome({super.key, required this.isQuickTool});

  @override
  State<Metronome> createState() => _MetronomeState();
}

class _MetronomeState extends State<Metronome> with RouteAware {
  late FileSystem fs;
  late ProjectRepository projectRepo;

  int lastStateChange = DateTime.now().millisecondsSinceEpoch;
  final List<int> lastRenderTimes = List.empty(growable: true);
  int _avgRenderTimeInMs = 0;

  late bool isSimpleModeOn;

  bool isStarted = false;
  bool sound = true;
  bool blink = MetronomeParams.defaultVisualMetronome;
  bool isFlashOn = false;
  VolumeLevel deviceVolumeLevel = VolumeLevel.normal;

  CurrentBeat currentPrimaryBeat = CurrentBeat();
  CurrentBeat currentSecondaryBeat = CurrentBeat();

  late Timer beatDetection;
  late MetronomeBlock metronomeBlock;

  bool processingButtonClick = false;

  final Tutorial tutorial = Tutorial();
  final GlobalKey keyStartStop = GlobalKey();
  final GlobalKey keySettings = GlobalKey();
  final GlobalKey keySimpleMode = GlobalKey();
  final GlobalKey keyAdvancedMode = GlobalKey();

  StreamSubscription<AudioInterruptionEvent>? audioInterruptionListener;

  @override
  void initState() {
    super.initState();

    fs = context.read<FileSystem>();
    projectRepo = context.read<ProjectRepository>();

    VolumeController.instance.addListener(handleVolumeChange);

    metronomeBlock = Provider.of<ProjectBlock>(context, listen: false) as MetronomeBlock;
    metronomeBlock.timeLastModified = getCurrentDateTime();
    isSimpleModeOn = metronomeBlock.isSimpleModeSupported;

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    metronomeSetVolume(volume: metronomeBlock.volume);
    metronomeSetBpm(bpm: metronomeBlock.bpm.toDouble());
    metronomeSetBeatMuteChance(muteChance: metronomeBlock.randomMute.toDouble() / 100.0);

    _muteMetronome(!sound);
    MetronomeUtils.loadSounds(fs, metronomeBlock);

    beatDetection = Timer.periodic(const Duration(milliseconds: MetronomeParams.beatDetectionDurationMillis), (
      t,
    ) async {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (!isStarted) return;

      var event = await metronomePollBeatEventHappened();
      if (event != null) {
        _onBeatHappened(event);
        if (!mounted) return;
        setState(() {});
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!context.read<ProjectLibrary>().showMetronomeTutorial && !context.read<ProjectLibrary>().showToolTutorial) {
        if (isSimpleModeOn && context.read<ProjectLibrary>().showMetronomeSimpleTutorial) {
          _createTutorialSimpleMode();
          tutorial.show(context);
        }
        if (!isSimpleModeOn && context.read<ProjectLibrary>().showMetronomeAdvancedTutorial) {
          _createTutorialAdvancedMode();
          tutorial.show(context);
        }
      }

      await _syncMetronomeSound();
    });
  }

  void _toggleSimpleMode() {
    isSimpleModeOn = !isSimpleModeOn;
    if (isSimpleModeOn && !metronomeBlock.isSimpleModeSupported) _clearAllRhythms();
    setState(() {});
  }

  void showModeTutorial() {
    if (!isSimpleModeOn && context.read<ProjectLibrary>().showMetronomeSimpleTutorial) {
      _createTutorialSimpleMode();
      tutorial.show(context);
    }
    if (isSimpleModeOn && context.read<ProjectLibrary>().showMetronomeAdvancedTutorial) {
      _createTutorialAdvancedMode();
      tutorial.show(context);
    }
  }

  Future<void> _toggleSimpleModeIfSaveOrUserConfirms() async {
    if (!isSimpleModeOn && !metronomeBlock.isSimpleModeSupported) {
      final shouldReset = await showConfirmDialog(
        context: context,
        title: context.l10n.metronomeResetDialogTitle,
        content: context.l10n.metronomeResetDialogHint,
      );

      if (!shouldReset) return;
    }

    showModeTutorial();

    _toggleSimpleMode();
  }

  void handleVolumeChange(double newVolume) {
    setState(() {
      deviceVolumeLevel = getVolumeLevel(newVolume);
    });
  }

  void _createTutorial() {
    final l10n = context.l10n;
    var targets = <CustomTargetFocus>[
      CustomTargetFocus(
        isSimpleModeOn ? keySimpleMode : keyAdvancedMode,
        isSimpleModeOn ? l10n.metronomeTutorialModeSimple : l10n.metronomeTutorialModeAdvanced,
        alignText: ContentAlign.bottom,
        pointingDirection: PointingDirection.up,
        shape: ShapeLightFocus.RRect,
        pointerPosition: PointerPosition.left,
      ),
      CustomTargetFocus(
        keyStartStop,
        l10n.metronomeTutorialStartStop,
        alignText: ContentAlign.top,
        pointingDirection: PointingDirection.down,
      ),
      CustomTargetFocus(
        keySettings,
        l10n.metronomeTutorialAdjust,
        alignText: ContentAlign.top,
        pointingDirection: PointingDirection.down,
        buttonsPosition: ButtonsPosition.top,
        shape: ShapeLightFocus.RRect,
      ),
      CustomTargetFocus(
        null,
        context: context,
        l10n.metronomeTutorialModeChange,
        customTextPosition: CustomTargetContentPosition(top: MediaQuery.of(context).size.height / 2 - 100),
      ),
    ];

    tutorial.create(targets.map((e) => e.targetFocus).toList(), () async {
      context.read<ProjectLibrary>().showMetronomeTutorial = false;
      if (isSimpleModeOn) context.read<ProjectLibrary>().showMetronomeSimpleTutorial = false;
      if (!isSimpleModeOn) context.read<ProjectLibrary>().showMetronomeAdvancedTutorial = false;
      await projectRepo.saveLibrary(context.read<ProjectLibrary>());
    }, context);
  }

  void _createTutorialSimpleMode() {
    final l10n = context.l10n;
    var targets = <CustomTargetFocus>[
      CustomTargetFocus(
        keySimpleMode,
        l10n.metronomeTutorialModeSimple,
        alignText: ContentAlign.bottom,
        pointingDirection: PointingDirection.up,
        shape: ShapeLightFocus.RRect,
        pointerPosition: PointerPosition.left,
      ),
    ];
    tutorial.create(targets.map((e) => e.targetFocus).toList(), () async {
      context.read<ProjectLibrary>().showMetronomeSimpleTutorial = false;
      await projectRepo.saveLibrary(context.read<ProjectLibrary>());
    }, context);
  }

  void _createTutorialAdvancedMode() {
    final l10n = context.l10n;
    var targets = <CustomTargetFocus>[
      CustomTargetFocus(
        keyAdvancedMode,
        l10n.metronomeTutorialModeAdvanced,
        alignText: ContentAlign.bottom,
        pointingDirection: PointingDirection.up,
        shape: ShapeLightFocus.RRect,
        pointerPosition: PointerPosition.left,
      ),
    ];
    tutorial.create(targets.map((e) => e.targetFocus).toList(), () async {
      context.read<ProjectLibrary>().showMetronomeAdvancedTutorial = false;
      await projectRepo.saveLibrary(context.read<ProjectLibrary>());
    }, context);
  }

  @override
  void deactivate() {
    _stopMetronome();
    beatDetection.cancel();
    super.deactivate();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ModalRoute? route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    VolumeController.instance.removeListener();
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    super.didPopNext();
    VolumeController.instance.addListener(handleVolumeChange);
  }

  void _handleUpdateRhythm() async {
    setState(() {});
    if (mounted) await context.read<ProjectRepository>().saveLibrary(context.read<ProjectLibrary>());
    await _syncMetronomeSound();
  }

  Future<void> _handleEditRhythmGroup(bool isSecondary, int index) async {
    if (isStarted) await _stopMetronome();
    if (!mounted) return;

    final rhythmGroups = isSecondary ? metronomeBlock.rhythmGroups2 : metronomeBlock.rhythmGroups;
    await openSettingPage(
      AdvancedRhythmGroupEditor(
        metronomeBlock: metronomeBlock,
        rhythmGroups: rhythmGroups,
        rhythmGroupIndex: index,
        currentNoteKey: rhythmGroups[index].noteKey,
        currentMainBeats: rhythmGroups[index].beats,
        currentPolyBeats: rhythmGroups[index].polyBeats,
        isAddingNewRhythmGroup: false,
        isSecondMetronome: isSecondary,
      ),
      context,
      metronomeBlock,
      callbackOnReturn: (editingConfirmed) async {
        if (editingConfirmed != true) return;
        setState(() {});
        if (mounted) await context.read<ProjectRepository>().saveLibrary(context.read<ProjectLibrary>());
        await _syncMetronomeSound();
      },
    );
  }

  void _handleAddRhythmGroup(bool isSecondary) async {
    if (isStarted) await _stopMetronome();
    if (!mounted) return;

    openSettingPage(
      AdvancedRhythmGroupEditor(
        metronomeBlock: metronomeBlock,
        rhythmGroups: isSecondary ? metronomeBlock.rhythmGroups2 : metronomeBlock.rhythmGroups,
        currentNoteKey: MetronomeParams.defaultNoteKey,
        currentMainBeats: MetronomeParams.defaultBeats,
        currentPolyBeats: MetronomeParams.defaultPolyBeats,
        isAddingNewRhythmGroup: true,
        isSecondMetronome: isSecondary,
      ),
      context,
      metronomeBlock,
      callbackOnReturn: (addingConfirmed) async {
        if (addingConfirmed != true) return;
        setState(() {});
        if (mounted) await context.read<ProjectRepository>().saveLibrary(context.read<ProjectLibrary>());
        await _syncMetronomeSound();
      },
    );
  }

  void _clearAllRhythms() async {
    if (isStarted) await _stopMetronome();

    metronomeBlock.resetPrimaryMetronome();
    metronomeBlock.rhythmGroups[0].keyID = MetronomeParams.getNewKeyID();
    metronomeBlock.resetSecondaryMetronome();

    _handleUpdateRhythm();
    MetronomeUtils.loadSounds(fs, metronomeBlock);
  }

  void _onToggleButtonClicked() async {
    if (processingButtonClick) return;
    setState(() => processingButtonClick = true);

    if (isStarted) {
      await _stopMetronome();
    } else {
      await _startMetronome();
    }

    await Future.delayed(const Duration(milliseconds: TIOMusicParams.millisecondsPlayPauseDebounce));
    setState(() => processingButtonClick = false);
  }

  Future<void> _startMetronome() async {
    if (sound && [VolumeLevel.muted, VolumeLevel.low].contains(deviceVolumeLevel)) {
      showSnackbar(context: context, message: getVolumeInfoText(deviceVolumeLevel, context.l10n))();
    }

    audioInterruptionListener = (await AudioSession.instance).interruptionEventStream.listen((event) {
      if (event.type == AudioInterruptionType.unknown) _stopMetronome();
    });

    await MetronomeFunctions.stop();
    final success = await MetronomeFunctions.start();
    if (!success) {
      logger.e('Unable to start metronome.');
      return;
    }
    isStarted = true;
  }

  Future<void> _stopMetronome() async {
    await audioInterruptionListener?.cancel();
    bool success = await metronomeStop();
    if (!success) logger.e('Unable to stop metronome.');
    isStarted = false;
  }

  void _muteMetronome(bool isMute) => metronomeSetMuted(muted: isMute);

  void _onBeatHappened(BeatHappenedEvent event) {
    if (event.isRandomMute) return;

    final msUntilNextFlashOn = calcMsUntilNextFlashOn(event.millisecondsBeforeStart, _avgRenderTimeInMs);
    final msUntilNextFlashOff = calcMsUntilNextFlashOff(msUntilNextFlashOn);

    Timer(Duration(milliseconds: msUntilNextFlashOn), () {
      if (!mounted) return;
      lastStateChange = DateTime.now().millisecondsSinceEpoch;
      isFlashOn = true;
      currentPrimaryBeat = MetronomeUtils.getCurrentPrimaryBeatFromEvent(isOn: true, event: event);
      currentSecondaryBeat = MetronomeUtils.getCurrentSecondaryBeatFromEvent(isOn: true, event: event);
      setState(() {});

      WidgetsBinding.instance.addPostFrameCallback(_updateAvgRenderTime);
    });

    Timer(Duration(milliseconds: msUntilNextFlashOff), () {
      if (!mounted) return;
      isFlashOn = false;
      currentPrimaryBeat = MetronomeUtils.getCurrentPrimaryBeatFromEvent(isOn: false, event: event);
      currentSecondaryBeat = MetronomeUtils.getCurrentSecondaryBeatFromEvent(isOn: false, event: event);
      setState(() {});
    });
  }

  void _updateAvgRenderTime(Duration timeStamp) {
    final renderTime = DateTime.now().millisecondsSinceEpoch - lastStateChange;
    lastRenderTimes.add(renderTime);
    if (lastRenderTimes.length > 5) lastRenderTimes.removeAt(0);
    _avgRenderTimeInMs = lastRenderTimes.reduce((a, b) => a + b) ~/ lastRenderTimes.length;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ParentTool(
      barTitle: metronomeBlock.title,
      isQuickTool: widget.isQuickTool,
      project: widget.isQuickTool ? null : Provider.of<Project>(context, listen: false),
      toolBlock: metronomeBlock,
      menuItems: <MenuItemButton>[
        if (!isSimpleModeOn)
          MenuItemButton(
            onPressed: _clearAllRhythms,
            child: Text(l10n.metronomeClearAllRhythms, style: const TextStyle(color: ColorTheme.primary)),
          ),
        MenuItemButton(
          onPressed: _toggleSimpleModeIfSaveOrUserConfirms,
          child: Text(
            isSimpleModeOn ? l10n.metronomeSimpleModeOff : l10n.metronomeSimpleModeOn,
            style: const TextStyle(color: ColorTheme.primary),
          ),
        ),
      ],
      onParentTutorialFinished: () {
        if (context.read<ProjectLibrary>().showMetronomeTutorial) {
          _createTutorial();
          tutorial.show(context);
        }
      },
      island: ParentIslandView(
        project: widget.isQuickTool ? null : Provider.of<Project>(context, listen: false),
        toolBlock: metronomeBlock,
      ),
      heightForCenterModule: metronomeBlock.rhythmGroups2.isNotEmpty ? 400 : null,
      centerModule: Stack(
        children: <Widget>[
          Visibility(
            visible: blink && isFlashOn,
            child: CustomPaint(size: MediaQuery.of(context).size, painter: ColorPainter(color: ColorTheme.surfaceTint)),
          ),
          Center(
            child: Column(
              children: [
                Rhythms(
                  key: isSimpleModeOn ? keySimpleMode : keyAdvancedMode,
                  isSimpleModeOn: isSimpleModeOn,
                  currentPrimaryBeat: currentPrimaryBeat,
                  currentSecondaryBeat: currentSecondaryBeat,
                  onUpdate: _handleUpdateRhythm,
                  onEditRhythmGroup: _handleEditRhythmGroup,
                  onAddRhythmGroup: _handleAddRhythmGroup,
                ),

                const SizedBox(height: TIOMusicParams.edgeInset),

                Align(
                  alignment: const Alignment(0, -0.4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OnOffButton(
                        isActive: blink,
                        onTap: () {
                          setState(() {
                            blink = !blink;
                          });
                        },
                        iconOff: Icons.visibility_off_outlined,
                        iconOn: Icons.visibility_outlined,
                        buttonSize: TIOMusicParams.sizeSmallButtons,
                      ),
                      OnOffButton(
                        key: keyStartStop,
                        isActive: isStarted,
                        onTap: _onToggleButtonClicked,
                        iconOff: MetronomeParams.svgIconPath,
                        iconOn: TIOMusicParams.pauseIcon,
                        buttonSize: TIOMusicParams.sizeBigButtons,
                      ),
                      OnOffButton(
                        isActive: sound,
                        onTap: () {
                          setState(() {
                            sound = !sound;
                            _muteMetronome(!sound);
                          });
                        },
                        iconOff: Icons.volume_off_outlined,
                        iconOn: Icons.volume_up_outlined,
                        buttonSize: TIOMusicParams.sizeSmallButtons,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      keySettingsList: keySettings,
      settingTiles: [
        SettingsTile(
          title: l10n.commonVolume,
          subtitle: l10n.formatNumber(metronomeBlock.volume),
          leadingIcon: Icons.volume_up,
          settingPage: SetVolume(
            initialValue: metronomeBlock.volume,
            onChange: (vol) => metronomeSetVolume(volume: vol),
            onConfirm: (vol) {
              metronomeBlock.volume = vol;
              metronomeSetVolume(volume: vol);
            },
            onCancel: () => metronomeSetVolume(volume: metronomeBlock.volume),
          ),
          block: metronomeBlock,
          callOnReturn: (value) => setState(() {}),
          icon: getVolumeInfoIcon(deviceVolumeLevel),
          onIconPressed: showSnackbar(context: context, message: getVolumeInfoText(deviceVolumeLevel, l10n)),
        ),
        SettingsTile(
          title: l10n.commonBasicBeat,
          subtitle: '${metronomeBlock.bpm} ${l10n.commonBpm}',
          leadingIcon: Icons.speed,
          settingPage: const SetBPM(),
          block: metronomeBlock,
          callOnReturn: (value) => setState(() {}),
        ),
        SettingsTile(
          title: metronomeBlock.rhythmGroups2.isEmpty ? l10n.metronomeSound : l10n.metronomeSoundPrimary,
          subtitle:
              '${l10n.metronomeSoundMain}: ${MetronomeSound.fromFilename(metronomeBlock.accSound).getLabel(l10n)}, ${MetronomeSound.fromFilename(metronomeBlock.unaccSound).getLabel(l10n)}\n${l10n.metronomeSoundPolyShort}: ${MetronomeSound.fromFilename(metronomeBlock.polyAccSound).getLabel(l10n)}, ${MetronomeSound.fromFilename(metronomeBlock.polyUnaccSound).getLabel(l10n)}',
          leadingIcon: Icons.library_music_outlined,
          settingPage: SetMetronomeSound(running: sound && isStarted),
          block: metronomeBlock,
          callOnReturn: (value) => setState(() {}),
        ),
        if (metronomeBlock.rhythmGroups2.isEmpty)
          const SizedBox()
        else
          SettingsTile(
            title: l10n.metronomeSoundSecondary,
            subtitle:
                '${l10n.metronomeSoundMain}: ${MetronomeSound.fromFilename(metronomeBlock.accSound2).getLabel(l10n)}, ${MetronomeSound.fromFilename(metronomeBlock.unaccSound2).getLabel(l10n)}\n${l10n.metronomeSoundPolyShort}: ${MetronomeSound.fromFilename(metronomeBlock.polyAccSound2).getLabel(l10n)}, ${MetronomeSound.fromFilename(metronomeBlock.polyUnaccSound2).getLabel(l10n)}',
            leadingIcon: Icons.library_music_outlined,
            settingPage: SetMetronomeSound(running: sound && isStarted, forSecondMetronome: true),
            block: metronomeBlock,
            callOnReturn: (value) => setState(() {}),
          ),
        SettingsTile(
          title: l10n.metronomeRandomMute,
          subtitle: '${metronomeBlock.randomMute}%',
          leadingIcon: Icons.question_mark,
          settingPage: const SetRandomMute(),
          block: metronomeBlock,
          callOnReturn: (value) => setState(() {}),
        ),
      ],
    );
  }

  Future<void> _syncMetronomeSound() => metronomeSetRhythm(
    bars: getRhythmAsMetroBar(metronomeBlock.rhythmGroups),
    bars2: getRhythmAsMetroBar(metronomeBlock.rhythmGroups2),
  );
}
