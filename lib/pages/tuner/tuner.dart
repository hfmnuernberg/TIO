import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/tuner_block.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/services/audio_session.dart';
import 'package:tiomusic/services/wakelock.dart';
import 'package:tiomusic/widgets/parent_tool/parent_island_view.dart';
import 'package:tiomusic/pages/parent_tool/parent_tool.dart';
import 'package:tiomusic/pages/parent_tool/settings_tile.dart';
import 'package:tiomusic/pages/tuner/pitch_visualizer.dart';
import 'package:tiomusic/pages/tuner/play_sound_page.dart';
import 'package:tiomusic/pages/tuner/set_concert_pitch.dart';
import 'package:tiomusic/pages/tuner/tuner_functions.dart';
import 'package:tiomusic/pages/tuner/tuner_type_page.dart';
import 'package:tiomusic/services/audio_system.dart';
import 'package:tiomusic/services/project_repository.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/util/l10n/tuner_type_extension.dart';
import 'package:tiomusic/util/tutorial_util.dart';
import 'package:tiomusic/util/util_functions.dart';
import 'package:tiomusic/util/util_midi.dart';
import 'package:tiomusic/widgets/custom_border_shape.dart';
import 'package:tiomusic/widgets/on_off_button.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class Tuner extends StatefulWidget {
  final bool isQuickTool;

  const Tuner({super.key, required this.isQuickTool});

  @override
  State<Tuner> createState() => _TunerState();
}

class _TunerState extends State<Tuner> {
  late TunerBlock tunerBlock;

  late AudioSystem _as;
  late AudioSession _audioSession;
  late Wakelock _wakelock;

  bool isRunning = false;
  bool gettingPitchInput = false;
  bool isInStartUp = true;

  final freqText = TextEditingController();
  final midiText = TextEditingController();
  final midiNameText = TextEditingController();
  final centOffsetText = TextEditingController();

  final historyLength = 100;
  late List<PitchOffset> history = List.empty(growable: true);

  late PitchVisualizer pitchVisualizer;

  final freqHistory = List<double>.filled(10, 0);
  var freqHistoryIndex = 0;

  bool processingButtonClick = false;

  Timer? timerPollFreq;

  final Tutorial tutorial = Tutorial();
  final GlobalKey keyStartStop = GlobalKey();
  final GlobalKey keySettings = GlobalKey();
  final GlobalKey islandToolTutorialKey = GlobalKey();

  AudioSessionInterruptionListenerHandle? _audioSessionInterruptionListenerHandle;

  Future<bool> startTuner() async {
    isRunning = true;
    _audioSessionInterruptionListenerHandle = await _audioSession.registerInterruptionListener(stopTuner);
    return TunerFunctions.start(_as, _audioSession, _wakelock);
  }

  Future<bool> stopTuner() async {
    if (_audioSessionInterruptionListenerHandle != null) {
      _audioSession.unregisterInterruptionListener(_audioSessionInterruptionListenerHandle!);
      _audioSessionInterruptionListenerHandle = null;
    }
    freqHistory.fillRange(0, freqHistory.length, 0);
    history.fillRange(0, history.length, PitchOffset.withoutValue());
    freqHistoryIndex = 0;
    gettingPitchInput = false;
    pitchVisualizer = PitchVisualizer(history, gettingPitchInput);
    midiNameText.text = '';
    freqText.text = '';
    centOffsetText.text = '';
    isRunning = false;
    return TunerFunctions.stop(_as, _wakelock);
  }

  @override
  void initState() {
    super.initState();

    _as = context.read<AudioSystem>();
    _audioSession = context.read<AudioSession>();
    _wakelock = context.read<Wakelock>();

    history = List.filled(historyLength, PitchOffset.withoutValue(), growable: true);
    pitchVisualizer = PitchVisualizer(history, gettingPitchInput);

    tunerBlock = Provider.of<ProjectBlock>(context, listen: false) as TunerBlock;

    tunerBlock.timeLastModified = getCurrentDateTime();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // start with delay to make sure previous tuner is stopped before new one is started (on copy/save)
      processingButtonClick = true;
      await Future.delayed(const Duration(milliseconds: 400));
      startTuner();
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          setState(() {
            processingButtonClick = false;
            // after tuner is started, we can set the flag and rebuilt the setting tiles
            isInStartUp = false;
          });
        }
      });

      timerPollFreq = Timer.periodic(const Duration(milliseconds: TunerParams.freqPollMillis), (t) async {
        if (!mounted) {
          t.cancel();
          return;
        }
        if (!isRunning) return;
        onNewFrequency(await _as.tunerGetFrequency());
      });
    });
  }

  void createTutorial() {
    final l10n = context.l10n;
    final targets = <CustomTargetFocus>[
      if (context.read<ProjectLibrary>().showTunerTutorial)
        CustomTargetFocus(
          keyStartStop,
          l10n.tunerTutorialStartStop,
          alignText: ContentAlign.top,
          pointingDirection: PointingDirection.down,
        ),
      if (context.read<ProjectLibrary>().showTunerTutorial)
        CustomTargetFocus(
          keySettings,
          l10n.tunerTutorialAdjust,
          alignText: ContentAlign.top,
          pointingDirection: PointingDirection.down,
          buttonsPosition: ButtonsPosition.top,
          shape: ShapeLightFocus.RRect,
        ),
      if (context.read<ProjectLibrary>().showTunerIslandTutorial && !widget.isQuickTool)
        CustomTargetFocus(
          islandToolTutorialKey,
          l10n.tunerTutorialIslandTool,
          pointingDirection: PointingDirection.up,
          alignText: ContentAlign.bottom,
          shape: ShapeLightFocus.RRect,
        ),
    ];

    if (targets.isEmpty) return;
    tutorial.create(targets.map((e) => e.targetFocus).toList(), () async {
      if (context.read<ProjectLibrary>().showTunerTutorial) {
        context.read<ProjectLibrary>().showTunerTutorial = false;
      }

      if (context.read<ProjectLibrary>().showTunerIslandTutorial && !widget.isQuickTool) {
        context.read<ProjectLibrary>().showTunerIslandTutorial = false;
      }

      await context.read<ProjectRepository>().saveLibrary(context.read<ProjectLibrary>());
    }, context);
  }

  @override
  void deactivate() {
    stopTuner();
    timerPollFreq?.cancel();
    super.deactivate();
  }

  @override
  void dispose() {
    tutorial.dispose();
    timerPollFreq?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ParentTool(
      barTitle: tunerBlock.title,
      isQuickTool: widget.isQuickTool,
      project: widget.isQuickTool ? null : Provider.of<Project>(context, listen: false),
      toolBlock: tunerBlock,
      islandToolTutorialKey: islandToolTutorialKey,
      onParentTutorialFinished: () {
        createTutorial();
        tutorial.show(context);
      },
      island: ParentIslandView(
        project: widget.isQuickTool ? null : Provider.of<Project>(context, listen: false),
        toolBlock: tunerBlock,
      ),
      centerModule: Center(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width / 3.1,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(freqText.text, style: const TextStyle(fontSize: 20, color: ColorTheme.primary)),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 3,
                  child: Center(
                    child: Text(midiNameText.text, style: const TextStyle(fontSize: 40, color: ColorTheme.primary)),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 3.1,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(centOffsetText.text, style: const TextStyle(fontSize: 20, color: ColorTheme.primary)),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return CustomPaint(
                          painter: pitchVisualizer,
                          size: Size(constraints.maxWidth, constraints.maxHeight),
                        );
                      },
                    ),
                  ),
                  // start stop button
                  Align(
                    child: OnOffButton(
                      key: keyStartStop,
                      isActive: isRunning,
                      onTap: onToggleButtonClicked,
                      iconOff: TunerParams.svgIconPath,
                      iconOn: TIOMusicParams.pauseIcon,
                      buttonSize: TIOMusicParams.sizeBigButtons,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      keySettingsList: keySettings,
      settingTiles: [
        SettingsTile(
          title: l10n.tunerInstrument,
          subtitle: tunerBlock.tunerType.getLabel(l10n),
          leadingIcon: Icons.piano,
          settingPage: const TunerTypePage(),
          block: tunerBlock,
          callOnReturn: (value) => setState(() {}),
          callBeforeOpen: stopTuner,
          inactive: isInStartUp,
        ),
        SettingsTile(
          title: l10n.tunerConcertPitch,
          subtitle: '${l10n.formatNumber(tunerBlock.chamberNoteHz)} Hz',
          leadingIcon: Icons.location_searching,
          settingPage: const SetConcertPitch(),
          block: tunerBlock,
          callOnReturn: (value) => setState(() {}),
          inactive: isInStartUp,
        ),
        SettingsTile(
          title: l10n.tunerPlayReference,
          subtitle: '',
          leadingIcon: Icons.music_note,
          settingPage: const PlaySoundPage(),
          block: tunerBlock,
          callOnReturn: (value) => setState(() {}),
          callBeforeOpen: () async {
            await stopTuner();
          },
          inactive: isInStartUp,
        ),
      ],
    );
  }

  double _medianOf(Iterable<double> values) {
    final list = values.toList()..sort();
    if (list.isEmpty) return 0;
    final mid = list.length ~/ 2;
    return list.length.isOdd ? list[mid] : (list[mid - 1] + list[mid]) / 2.0;
  }

  void onNewFrequency(double? newFreq) {
    if (newFreq == null) return;
    if (!mounted) return;

    if (newFreq <= 0.0) {
      setState(() {
        gettingPitchInput = false;
        setNoPitchOffset();
        pitchVisualizer = PitchVisualizer(history, gettingPitchInput);
      });
      return;
    }

    freqHistory[freqHistoryIndex] = newFreq;
    freqHistoryIndex = (freqHistoryIndex + 1) % freqHistory.length;

    final freq = _medianOf(freqHistory.where((e) => e > 0));
    if (freq.abs() < 0.0001) return;

    final concertPitch = tunerBlock.chamberNoteHz;
    final midi = freqToMidi(freq, concertPitch);

    if (!tunerBlock.tunerType.isSupportedMidi(midi.round())) return deactivatePitch();

    final centOffset = ((midi - midi.round()) * 100.0).round();

    setState(() {
      freqText.text = '${context.l10n.formatNumber(double.parse(freq.toStringAsFixed(1)))} Hz';
      midiText.text = midi.toString();
      midiNameText.text = tunerBlock.tunerType.toName(midi.round());
      centOffsetText.text = '$centOffset Cent';
      setPitchOffset(midi - midi.round());
      gettingPitchInput = true;
      pitchVisualizer = PitchVisualizer(history, gettingPitchInput);
    });
  }

  void deactivatePitch() {
    setState(() {
      gettingPitchInput = false;
      setNoPitchOffset();
      pitchVisualizer = PitchVisualizer(history, gettingPitchInput);
    });
  }

  void setPitchOffset(double pitchOffsetMidi) {
    history.add(PitchOffset.withValue(pitchOffsetMidi));
    history.removeAt(0);
  }

  void setNoPitchOffset() {
    history.add(history.last);
    history.removeAt(0);
  }

  // Start/Stop
  void onToggleButtonClicked() async {
    if (processingButtonClick) return;
    setState(() => processingButtonClick = true);

    if (isRunning) {
      await stopTuner();
    } else {
      await startTuner();
    }

    await Future.delayed(const Duration(milliseconds: TIOMusicParams.millisecondsPlayPauseDebounce));
    setState(() => processingButtonClick = false);
  }
}
