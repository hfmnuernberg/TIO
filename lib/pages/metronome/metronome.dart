import 'dart:async';
import 'dart:ui';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/app.dart';
import 'package:tiomusic/models/blocks/metronome_block.dart';
import 'package:tiomusic/models/metronome_sound.dart';
import 'package:tiomusic/models/metronome_sound_extension.dart';
import 'package:tiomusic/models/note_handler.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/models/rhythm_group.dart';
import 'package:tiomusic/pages/metronome/metronome_functions.dart';
import 'package:tiomusic/pages/metronome/metronome_utils.dart';
import 'package:tiomusic/pages/metronome/rhythm/rhythm_segment.dart';
import 'package:tiomusic/src/rust/api/modules/metronome_rhythm.dart';
import 'package:tiomusic/widgets/metronome/rhythm_preset.dart';
import 'package:tiomusic/widgets/metronome/set_rhythm_parameters_simple.dart';
import 'package:tiomusic/pages/metronome/setting_bpm.dart';
import 'package:tiomusic/pages/metronome/setting_metronome_sound.dart';
import 'package:tiomusic/pages/metronome/setting_random_mute.dart';
import 'package:tiomusic/pages/metronome/rhythm/set_rhythm_parameters.dart';
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
import 'package:tiomusic/util/util_functions.dart';
import 'package:tiomusic/util/tutorial_util.dart';
import 'package:tiomusic/widgets/custom_border_shape.dart';
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
  static final logger = createPrefixLogger('Metronome');

  late FileSystem fs;
  late ProjectRepository projectRepo;

  int lastStateChange = DateTime.now().millisecondsSinceEpoch;
  final List<int> lastRenderTimes = List.empty(growable: true);
  int _avgRenderTimeInMs = 0;

  bool isSimpleModeOn = true;
  bool forceFallbackToPreset = false;
  bool isStarted = false;
  bool sound = true;
  bool blink = MetronomeParams.defaultVisualMetronome;
  bool isFlashOn = false;
  VolumeLevel deviceVolumeLevel = VolumeLevel.normal;
  final List<RhythmSegment> rhythmSegmentList = List.empty(growable: true);
  final List<RhythmSegment> rhythmSegmentList2 = List.empty(growable: true);

  final ActiveBeatsModel activeBeatsModel = ActiveBeatsModel();

  late Timer beatDetection;
  late MetronomeBlock metronomeBlock;

  bool processingButtonClick = false;

  Color listTileMaskColor = Colors.transparent;

  final Tutorial tutorial = Tutorial();
  final GlobalKey keyStartStop = GlobalKey();
  final GlobalKey keySettings = GlobalKey();
  final GlobalKey keyGroups = GlobalKey();
  final GlobalKey keyAddSecondMetro = GlobalKey();

  StreamSubscription<AudioInterruptionEvent>? audioInterruptionListener;

  @override
  void initState() {
    super.initState();

    fs = context.read<FileSystem>();
    projectRepo = context.read<ProjectRepository>();

    VolumeController.instance.addListener(handleVolumeChange);

    metronomeBlock = Provider.of<ProjectBlock>(context, listen: false) as MetronomeBlock;
    metronomeBlock.timeLastModified = getCurrentDateTime();
    isSimpleModeOn = metronomeBlock.isSimpleModeOn;

    // only allow portrait mode for this tool
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    metronomeSetVolume(volume: metronomeBlock.volume);
    metronomeSetRhythm(
      bars: getRhythmAsMetroBar(metronomeBlock.rhythmGroups),
      bars2: getRhythmAsMetroBar(metronomeBlock.rhythmGroups2),
    );
    metronomeSetBpm(bpm: metronomeBlock.bpm.toDouble());
    metronomeSetBeatMuteChance(muteChance: metronomeBlock.randomMute.toDouble() / 100.0);

    _muteMetronome(!sound);
    MetronomeUtils.loadSounds(fs, metronomeBlock);

    // Build rhythm list
    _clearAndRebuildRhythmSegments(false);
    _clearAndRebuildRhythmSegments(true);

    // Start beat detection timer
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<ProjectLibrary>().showMetronomeTutorial &&
          !context.read<ProjectLibrary>().showToolTutorial &&
          !context.read<ProjectLibrary>().showQuickToolTutorial &&
          !context.read<ProjectLibrary>().showIslandTutorial) {
        _createTutorial();
        tutorial.show(context);
      }
    });
  }

  void _toggleSimpleMode() {
    setState(() {
      forceFallbackToPreset = !isSimpleModeOn;
      isSimpleModeOn = !isSimpleModeOn;
      metronomeBlock.isSimpleModeOn = isSimpleModeOn;
    });
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
        keyGroups,
        l10n.metronomeTutorialRelocate,
        alignText: ContentAlign.bottom,
        pointingDirection: PointingDirection.up,
        shape: ShapeLightFocus.RRect,
        pointerPosition: PointerPosition.left,
      ),
      CustomTargetFocus(
        keyAddSecondMetro,
        l10n.metronomeTutorialAddNew,
        alignText: ContentAlign.left,
        pointingDirection: PointingDirection.right,
      ),
    ];
    tutorial.create(targets.map((e) => e.targetFocus).toList(), () async {
      context.read<ProjectLibrary>().showMetronomeTutorial = false;
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

  void _addRhythmSegment(bool isSecond) async {
    await _stopMetronome();

    int newIndex = isSecond ? metronomeBlock.rhythmGroups2.length : metronomeBlock.rhythmGroups.length;

    if (mounted) {
      openSettingPage(
        SetRhythmParameters(
          currentNoteKey: MetronomeParams.defaultNoteKey,
          currentBeats: MetronomeParams.defaultBeats,
          currentPolyBeats: MetronomeParams.defaultPolyBeats,
          isAddingNewBar: true,
          rhythmGroups: isSecond ? metronomeBlock.rhythmGroups2 : metronomeBlock.rhythmGroups,
          isSecondMetronome: isSecond,
          metronomeBlock: metronomeBlock,
        ),
        context,
        metronomeBlock,
        callbackOnReturn: (addingConfirmed) {
          setState(() {
            if (addingConfirmed != null && addingConfirmed) {
              var newRhythmSegment = RhythmSegment(
                activeBeatsNotifier: activeBeatsModel,
                barIdx: newIndex,
                metronomeBlock: metronomeBlock,
                isSecondary: isSecond,
                editFunction: () => _editRhythmSegment(newIndex, isSecond),
              );

              isSecond ? rhythmSegmentList2.add(newRhythmSegment) : rhythmSegmentList.add(newRhythmSegment);
            }

            metronomeSetRhythm(
              bars: getRhythmAsMetroBar(metronomeBlock.rhythmGroups),
              bars2: getRhythmAsMetroBar(metronomeBlock.rhythmGroups2),
            );
          });
        },
      );
    }
  }

  void _editRhythmSegment(int idx, bool isSecond) async {
    await _stopMetronome();

    var rhythmGroups = isSecond ? metronomeBlock.rhythmGroups2 : metronomeBlock.rhythmGroups;

    if (mounted) {
      openSettingPage(
        SetRhythmParameters(
          barIndex: idx,
          currentNoteKey: rhythmGroups[idx].noteKey,
          currentBeats: rhythmGroups[idx].beats,
          currentPolyBeats: rhythmGroups[idx].polyBeats,
          isAddingNewBar: false,
          rhythmGroups: rhythmGroups,
          isSecondMetronome: isSecond,
          metronomeBlock: metronomeBlock,
        ),
        context,
        metronomeBlock,
      ).then((value) {
        var newRhythmSegment = RhythmSegment(
          activeBeatsNotifier: activeBeatsModel,
          metronomeBlock: metronomeBlock,
          barIdx: idx,
          isSecondary: isSecond,
          editFunction: () => _editRhythmSegment(idx, isSecond),
        );

        isSecond ? rhythmSegmentList2[idx] = newRhythmSegment : rhythmSegmentList[idx] = newRhythmSegment;

        metronomeSetRhythm(
          bars: getRhythmAsMetroBar(metronomeBlock.rhythmGroups),
          bars2: getRhythmAsMetroBar(metronomeBlock.rhythmGroups2),
        );
        setState(() {});
      });
    }
  }

  void _handleUpdateRhythm(
    List<BeatType> newBeats,
    List<BeatTypePoly> newPolyBeats,
    String newNoteKey,
    RhythmPresetKey newPresetKey,
  ) {
    final group = metronomeBlock.rhythmGroups[0];
    group.beats = List.from(newBeats);
    group.polyBeats = List.from(newPolyBeats);
    group.noteKey = newNoteKey;
    group.presetKey = newPresetKey;
    group.beatLen = NoteHandler.getBeatLength(newNoteKey);

    _clearAndRebuildRhythmSegments(false);
    metronomeSetRhythm(
      bars: getRhythmAsMetroBar(metronomeBlock.rhythmGroups),
      bars2: getRhythmAsMetroBar(metronomeBlock.rhythmGroups2),
    );
    setState(() {});
  }

  void _deleteRhythmSegment(int index, bool isSecond) async {
    _stopMetronome().then((value) async {
      isSecond ? metronomeBlock.rhythmGroups2.removeAt(index) : metronomeBlock.rhythmGroups.removeAt(index);

      _clearAndRebuildRhythmSegments(isSecond);

      metronomeSetRhythm(
        bars: getRhythmAsMetroBar(metronomeBlock.rhythmGroups),
        bars2: getRhythmAsMetroBar(metronomeBlock.rhythmGroups2),
      );
      if (mounted) {
        await projectRepo.saveLibrary(context.read<ProjectLibrary>());
        setState(() {});
      }
    });
  }

  void _reorderRythmSegments(int oldIndex, int newIndex, bool isSecond) async {
    _stopMetronome();

    metronomeBlock.changeRhythmOrder(
      oldIndex,
      newIndex,
      isSecond ? metronomeBlock.rhythmGroups2 : metronomeBlock.rhythmGroups,
    );

    _clearAndRebuildRhythmSegments(isSecond);

    metronomeSetRhythm(
      bars: getRhythmAsMetroBar(metronomeBlock.rhythmGroups),
      bars2: getRhythmAsMetroBar(metronomeBlock.rhythmGroups2),
    );
    await projectRepo.saveLibrary(context.read<ProjectLibrary>());
    setState(() {});
  }

  void _clearAllRhythms() async {
    await _stopMetronome();

    rhythmSegmentList.clear();
    rhythmSegmentList2.clear();
    metronomeBlock.rhythmGroups.clear();
    metronomeBlock.rhythmGroups2.clear();

    metronomeBlock.rhythmGroups.add(
      RhythmGroup(
        MetronomeParams.getNewKeyID(),
        MetronomeParams.defaultBeats,
        MetronomeParams.defaultPolyBeats,
        MetronomeParams.defaultNoteKey,
      ),
    );
    rhythmSegmentList.add(
      RhythmSegment(
        activeBeatsNotifier: activeBeatsModel,
        barIdx: 0,
        metronomeBlock: metronomeBlock,
        isSecondary: false,
        editFunction: () => _editRhythmSegment(0, false),
      ),
    );

    metronomeSetRhythm(
      bars: getRhythmAsMetroBar(metronomeBlock.rhythmGroups),
      bars2: getRhythmAsMetroBar(metronomeBlock.rhythmGroups2),
    );
    if (mounted) {
      await projectRepo.saveLibrary(context.read<ProjectLibrary>());
      setState(() {});
    }
  }

  void _clearAndRebuildRhythmSegments(bool isSecond) {
    isSecond ? rhythmSegmentList2.clear() : rhythmSegmentList.clear();
    for (int i = 0; i < (isSecond ? metronomeBlock.rhythmGroups2.length : metronomeBlock.rhythmGroups.length); i++) {
      var newRhythmSegment = RhythmSegment(
        activeBeatsNotifier: activeBeatsModel,
        barIdx: i,
        metronomeBlock: metronomeBlock,
        isSecondary: isSecond,
        editFunction: () => _editRhythmSegment(i, isSecond),
      );
      isSecond ? rhythmSegmentList2.add(newRhythmSegment) : rhythmSegmentList.add(newRhythmSegment);
    }
    setState(() {});
  }

  // Additional widget to remove the segment background while dragging it
  Widget _proxyDecorator(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final double animValue = Curves.easeInOut.transform(animation.value);
        final double elevation = lerpDouble(0, 6, animValue)!;
        return Material(elevation: elevation, color: Colors.transparent, shadowColor: Colors.transparent, child: child);
      },
      child: child,
    );
  }

  // Start/Stop Metronome
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

  // Turn off metronome sound
  void _muteMetronome(bool isMute) {
    metronomeSetMuted(muted: isMute);
  }

  // React to beat signal
  void _onBeatHappened(BeatHappenedEvent event) {
    if (!event.isRandomMute) {
      final msUntilNextFlashOn = calcMsUntilNextFlashOn(event.millisecondsBeforeStart, _avgRenderTimeInMs);
      final msUntilNextFlashOff = calcMsUntilNextFlashOff(msUntilNextFlashOn);

      Timer(Duration(milliseconds: msUntilNextFlashOn), () {
        if (!mounted) return;
        lastStateChange = DateTime.now().millisecondsSinceEpoch;
        setState(() {
          isFlashOn = true;
          activeBeatsModel.setBeatOnOff(true, event.barIndex, event.beatIndex, event.isPoly, event.isSecondary);
        });

        WidgetsBinding.instance.addPostFrameCallback(_updateAvgRenderTime);
      });

      Timer(Duration(milliseconds: msUntilNextFlashOff), () {
        if (!mounted) return;
        setState(() {
          isFlashOn = false;
          activeBeatsModel.setBeatOnOff(false, event.barIndex, event.beatIndex, event.isPoly, event.isSecondary);
        });
      });
    }
  }

  void _updateAvgRenderTime(Duration timeStamp) {
    final renderTime = DateTime.now().millisecondsSinceEpoch - lastStateChange;
    lastRenderTimes.add(renderTime);
    if (lastRenderTimes.length > 5) lastRenderTimes.removeAt(0);
    _avgRenderTimeInMs = lastRenderTimes.reduce((a, b) => a + b) ~/ lastRenderTimes.length;
  }

  Widget _rhythmGroup(int index, bool isSecond) {
    return DecoratedBox(
      key: index == 0 && !isSecond ? keyGroups : null,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: listTileMaskColor),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child:
        // Reordering handle with icon
        ReorderableDelayedDragStartListener(
          index: index,
          enabled: (isSecond ? metronomeBlock.rhythmGroups2.length : metronomeBlock.rhythmGroups.length) > 1,
          child: GestureDetector(
            onTap: () {
              _editRhythmSegment(index, isSecond);
            },
            child: isSecond ? rhythmSegmentList2[index] : rhythmSegmentList[index],
          ),
        ),
      ),
    );
  }

  Widget _rhythmRow({bool isSecondMetronome = false}) {
    return Column(
      children: [
        // rhythm groups and beats
        SizedBox(
          height: MetronomeParams.heightRhythmGroups,
          child: Padding(
            padding: const EdgeInsets.all(TIOMusicParams.edgeInset),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                // List of rhythm segments
                ReorderableListView.builder(
                  proxyDecorator: _proxyDecorator,
                  buildDefaultDragHandles: false,
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemCount: isSecondMetronome ? rhythmSegmentList2.length : rhythmSegmentList.length,
                  itemBuilder: (context, index) {
                    return Dismissible(
                      key: Key(
                        isSecondMetronome
                            ? metronomeBlock.rhythmGroups2[index].keyID
                            : metronomeBlock.rhythmGroups[index].keyID,
                      ),
                      direction:
                          isSecondMetronome
                              ? DismissDirection.up
                              : metronomeBlock.rhythmGroups.length > 1
                              ? DismissDirection.up
                              : DismissDirection.none,
                      onDismissed: (_) {
                        _deleteRhythmSegment(index, isSecondMetronome);
                      },
                      background: const Icon(Icons.delete_outlined, color: ColorTheme.primary),
                      child: _rhythmGroup(index, isSecondMetronome),
                    );
                  },
                  onReorderStart: (index) {
                    setState(() {
                      listTileMaskColor = const Color.fromARGB(57, 47, 47, 47);
                    });
                  },
                  onReorderEnd: (index) {
                    setState(() {
                      listTileMaskColor = Colors.transparent;
                    });
                  },
                  // Reorder rhythm segments
                  onReorder: (oldIndex, newIndex) {
                    _reorderRythmSegments(oldIndex, newIndex, isSecondMetronome);
                  },
                ),
                const SizedBox(width: 4),
                // Button to add more segments
                CircleAvatar(
                  radius: TIOMusicParams.rhythmPlusButtonSize,
                  backgroundColor: Colors.white,
                  child: Center(
                    child: IconButton(
                      iconSize: TIOMusicParams.rhythmPlusButtonSize,
                      onPressed: () => _addRhythmSegment(isSecondMetronome),
                      icon: const Icon(Icons.add, color: ColorTheme.surfaceTint),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Metronome row title
        Padding(
          padding: const EdgeInsets.only(left: TIOMusicParams.edgeInset, right: TIOMusicParams.edgeInset),
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: ColorTheme.surface, width: 2),
                bottom: BorderSide(color: ColorTheme.surface, width: 2),
              ),
            ),
            height: TIOMusicParams.rhythmPlusButtonSize * 2.5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isSecondMetronome ? context.l10n.metronomeSecondary : context.l10n.metronomePrimary,
                  style: const TextStyle(color: ColorTheme.primary),
                ),
                // add second metronome button
                if (isSecondMetronome || metronomeBlock.rhythmGroups2.isNotEmpty)
                  const SizedBox()
                else
                  IconButton(
                    key: keyAddSecondMetro,
                    iconSize: TIOMusicParams.rhythmPlusButtonSize,
                    onPressed: () => _addRhythmSegment(true),
                    icon: const Icon(Icons.add, color: ColorTheme.primary),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
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
        MenuItemButton(
          onPressed: _clearAllRhythms,
          child: Text(l10n.metronomeClearAllRhythms, style: const TextStyle(color: ColorTheme.primary)),
        ),
        MenuItemButton(
          onPressed: _toggleSimpleMode,
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
          // Black screen for visual metronome
          Visibility(
            visible: blink && isFlashOn,
            child: CustomPaint(size: MediaQuery.of(context).size, painter: FilledScreen(color: ColorTheme.surfaceTint)),
          ),
          Center(
            child: Column(
              children: [
                if (isSimpleModeOn)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                    child: SetRhythmParametersSimple(
                      currentNoteKey: metronomeBlock.rhythmGroups[0].noteKey,
                      currentBeats: metronomeBlock.rhythmGroups[0].beats,
                      currentPolyBeats: metronomeBlock.rhythmGroups[0].polyBeats,
                      rhythmGroups: metronomeBlock.rhythmGroups,
                      metronomeBlock: metronomeBlock,
                      forcePresetFallback: forceFallbackToPreset,
                      onUpdateRhythm: _handleUpdateRhythm,
                    ),
                  )
                else ...[
                  _rhythmRow(),
                  if (metronomeBlock.rhythmGroups2.isNotEmpty) _rhythmRow(isSecondMetronome: true),
                ],

                const SizedBox(height: TIOMusicParams.edgeInset),

                // Metronome control
                Align(
                  alignment: const Alignment(0, -0.4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Button to set visual metronome
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
                      // Button to start/stop Metronome
                      OnOffButton(
                        key: keyStartStop,
                        isActive: isStarted,
                        onTap: _onToggleButtonClicked,
                        iconOff: MetronomeParams.svgIconPath,
                        iconOn: TIOMusicParams.pauseIcon,
                        buttonSize: TIOMusicParams.sizeBigButtons,
                      ),
                      // Button to turn sound on/off
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
      // Setting Tiles
      keySettingsList: keySettings,
      settingTiles: [
        // Volume
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
        // BPM
        SettingsTile(
          title: l10n.commonBasicBeat,
          subtitle: '${metronomeBlock.bpm} ${l10n.commonBpm}',
          leadingIcon: Icons.speed,
          settingPage: const SetBPM(),
          block: metronomeBlock,
          callOnReturn: (value) => setState(() {}),
        ),
        // Sounds
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
        // Random mute
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
}

// Fills the whole screen with any color
class FilledScreen extends CustomPainter {
  FilledScreen({required this.color});
  Color color;

  @override
  void paint(Canvas canvas, Size size) {
    var paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
