import 'dart:async';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/services.dart';
import 'package:stats/stats.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/models/file_io.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/pages/parent_tool/parent_island_view.dart';
import 'package:tiomusic/pages/parent_tool/parent_tool.dart';
import 'package:tiomusic/pages/parent_tool/settings_tile.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/pages/tuner/play_sound_page.dart';
import 'package:tiomusic/pages/tuner/setting_concert_pitch.dart';
import 'package:tiomusic/pages/tuner/tuner_functions.dart';

import 'package:tiomusic/pages/tuner/pitch_visualizer.dart';
import 'package:tiomusic/src/rust/api/api.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/util/util_functions.dart';
import 'package:tiomusic/util/util_midi.dart';
import 'package:tiomusic/models/blocks/tuner_block.dart';
import 'package:tiomusic/util/walkthrough_util.dart';
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
  late TunerBlock _tunerBlock;

  bool _isRunning = false;
  bool _gettingPitchInput = false;
  bool _isInStartUp = true;

  final _freqText = TextEditingController();
  final _midiText = TextEditingController();
  final _midiNameText = TextEditingController();
  final _centOffsetText = TextEditingController();

  final _historyLength = 100;
  late List<PitchOffset> _history = List.empty(growable: true);

  late PitchVisualizer _pitchVisualizer;

  final _freqHistory = List<double>.filled(10, 0.0);
  var _freqHistoryIndex = 0;

  bool _processingButtonClick = false;

  Timer? _timerPollFreq;

  final Walkthrough _walkthrough = Walkthrough();
  final GlobalKey _keyStartStop = GlobalKey();
  final GlobalKey _keySettings = GlobalKey();

  StreamSubscription<AudioInterruptionEvent>? audioInterruptionListener;

  Future<bool> startTuner() async {
    _isRunning = true;
    audioInterruptionListener = (await AudioSession.instance).interruptionEventStream.listen((event) {
      if (event.type == AudioInterruptionType.unknown) stopTuner();
    });
    return TunerFunctions.start();
  }

  Future<bool> stopTuner() async {
    await audioInterruptionListener?.cancel();
    _freqHistory.fillRange(0, _freqHistory.length, 0.0);
    _history.fillRange(0, _history.length, PitchOffset.withoutValue());
    _freqHistoryIndex = 0;
    _gettingPitchInput = false;
    _pitchVisualizer = PitchVisualizer(_history, _gettingPitchInput);
    _midiNameText.text = '';
    _freqText.text = '';
    _centOffsetText.text = '';
    _isRunning = false;
    return TunerFunctions.stop();
  }

  @override
  void initState() {
    super.initState();

    _history = List.filled(_historyLength, PitchOffset.withoutValue(), growable: true);
    _pitchVisualizer = PitchVisualizer(_history, _gettingPitchInput);

    _tunerBlock = Provider.of<ProjectBlock>(context, listen: false) as TunerBlock;

    _tunerBlock.timeLastModified = getCurrentDateTime();

    // only allow portrait mode for this tool
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // start with delay to make sure previous tuner is stopped before new one is started (on copy/save)
      _processingButtonClick = true;
      await Future.delayed(const Duration(milliseconds: 400));
      startTuner();
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          setState(() {
            _processingButtonClick = false;
            // after tuner is started, we can set the flag and rebuilt the setting tiles
            _isInStartUp = false;
          });
        }
      });

      _timerPollFreq = Timer.periodic(const Duration(milliseconds: TunerParams.freqPollMillis), (Timer t) async {
        if (!mounted) {
          t.cancel();
          return;
        }
        if (!_isRunning) return;
        _onNewFrequency(await tunerGetFrequency());
      });

      if (mounted) {
        if (context.read<ProjectLibrary>().showTunerTutorial &&
            !context.read<ProjectLibrary>().showToolTutorial &&
            !context.read<ProjectLibrary>().showQuickToolTutorial &&
            !context.read<ProjectLibrary>().showIslandTutorial) {
          _createWalkthrough();
          _walkthrough.show(context);
        }
      }
    });
  }

  void _createWalkthrough() {
    // add the targets here
    var targets = <CustomTargetFocus>[
      CustomTargetFocus(
        _keyStartStop,
        'Tap here to start and stop the tuner',
        alignText: ContentAlign.top,
        pointingDirection: PointingDirection.down,
      ),
      CustomTargetFocus(
        _keySettings,
        'Tap here to adjust the concert pitch or play a reference tone',
        alignText: ContentAlign.top,
        pointingDirection: PointingDirection.down,
        buttonsPosition: ButtonsPosition.top,
        shape: ShapeLightFocus.RRect,
      ),
    ];
    _walkthrough.create(targets.map((e) => e.targetFocus).toList(), () {
      context.read<ProjectLibrary>().showTunerTutorial = false;
      FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());
    }, context);
  }

  @override
  void deactivate() {
    stopTuner();
    _timerPollFreq?.cancel();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return ParentTool(
      barTitle: _tunerBlock.title,
      isQuickTool: widget.isQuickTool,
      project: widget.isQuickTool ? null : Provider.of<Project>(context, listen: false),
      toolBlock: _tunerBlock,
      onParentWalkthroughFinished: () {
        if (context.read<ProjectLibrary>().showTunerTutorial) {
          _createWalkthrough();
          _walkthrough.show(context);
        }
      },
      island: ParentIslandView(
        project: widget.isQuickTool ? null : Provider.of<Project>(context, listen: false),
        toolBlock: _tunerBlock,
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
                    child: Text(_freqText.text, style: const TextStyle(fontSize: 20, color: ColorTheme.primary)),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 3,
                  child: Center(
                    child: Text(_midiNameText.text, style: const TextStyle(fontSize: 40, color: ColorTheme.primary)),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 3.1,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(_centOffsetText.text, style: const TextStyle(fontSize: 20, color: ColorTheme.primary)),
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
                      builder: (BuildContext context, BoxConstraints constraints) {
                        return CustomPaint(
                          painter: _pitchVisualizer,
                          size: Size(constraints.maxWidth, constraints.maxHeight),
                        );
                      },
                    ),
                  ),
                  // start stop button
                  Align(
                    child: OnOffButton(
                      key: _keyStartStop,
                      isActive: _isRunning,
                      onTap: _onToggleButtonClicked,
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
      keySettingsList: _keySettings,
      settingTiles: [
        SettingsTile(
          title: 'Concert Pitch',
          subtitle: '${formatDoubleToString(_tunerBlock.chamberNoteHz)} Hz',
          leadingIcon: Icons.location_searching,
          settingPage: const SetConcertPitch(),
          block: _tunerBlock,
          callOnReturn: (value) => setState(() {}),
          inactive: _isInStartUp,
        ),
        SettingsTile(
          title: 'Play Reference',
          subtitle: '',
          leadingIcon: Icons.music_note,
          settingPage: const PlaySoundPage(),
          block: _tunerBlock,
          callOnReturn: (value) => setState(() {}),
          callBeforeOpen: () async {
            await stopTuner();
          },
          inactive: _isInStartUp,
        ),
      ],
    );
  }

  void _onNewFrequency(double? newFreq) {
    if (newFreq == null) return;
    if (!mounted) return;

    if (newFreq <= 0.0) {
      setState(() {
        _gettingPitchInput = false;
        _setNoPitchOffset();
        _pitchVisualizer = PitchVisualizer(_history, _gettingPitchInput);
      });
      return;
    }

    _freqHistory[_freqHistoryIndex] = newFreq;
    _freqHistoryIndex = (_freqHistoryIndex + 1) % _freqHistory.length;

    final freqStats = Stats.fromData(_freqHistory);
    final freq = freqStats.median.toDouble();
    if (freq.abs() < 0.0001) return;

    var concertPitch = _tunerBlock.chamberNoteHz;

    var midi = freqToMidi(freq, concertPitch);
    var centOffset = ((midi - midi.round()) * 100.0).round();

    setState(() {
      _freqText.text = '${freq.toStringAsFixed(1)} Hz';
      _midiText.text = midi.toString();
      _midiNameText.text = midiToName(midi.round());
      _centOffsetText.text = '$centOffset Cent';
      _setPitchOffset(midi - midi.round());
      _gettingPitchInput = true;
      _pitchVisualizer = PitchVisualizer(_history, _gettingPitchInput);
    });
  }

  void _setPitchOffset(double pitchOffsetMidi) {
    _history.add(PitchOffset.withValue(pitchOffsetMidi));
    _history.removeAt(0);
  }

  void _setNoPitchOffset() {
    _history.add(_history.last);
    _history.removeAt(0);
  }

  // Start/Stop
  void _onToggleButtonClicked() async {
    if (_processingButtonClick) return;
    setState(() => _processingButtonClick = true);

    if (_isRunning) {
      await stopTuner();
    } else {
      await startTuner();
    }

    await Future.delayed(const Duration(milliseconds: TIOMusicParams.millisecondsPlayPauseDebounce));
    setState(() => _processingButtonClick = false);
  }
}
