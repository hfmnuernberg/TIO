import 'dart:async';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:tiomusic/models/blocks/metronome_block.dart';
import 'package:tiomusic/models/note_handler.dart';
import 'package:tiomusic/pages/metronome/beat_button.dart';
import 'package:tiomusic/pages/metronome/metronome_functions.dart';
import 'package:tiomusic/pages/metronome/metronome_utils.dart';
import 'package:tiomusic/pages/metronome/rhythm_segment.dart';
import 'package:tiomusic/pages/parent_tool/parent_inner_island.dart';
import 'package:tiomusic/src/rust/api/api.dart';
import 'package:tiomusic/src/rust/api/modules/metronome.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/util/util_functions.dart';

class MetronomeIslandView extends StatefulWidget {
  final MetronomeBlock metronomeBlock;

  const MetronomeIslandView({
    super.key,
    required this.metronomeBlock,
  });

  @override
  State<MetronomeIslandView> createState() => _MetronomeIslandViewState();
}

class _MetronomeIslandViewState extends State<MetronomeIslandView> {
  bool _isStarted = false;
  late Timer _beatDetection;

  final ActiveBeatsModel _activeBeatsModel = ActiveBeatsModel();

  bool _processingButtonClick = false;

  StreamSubscription<AudioInterruptionEvent>? audioInterruptionListener;

  @override
  void initState() {
    super.initState();

    metronomeSetVolume(volume: widget.metronomeBlock.volume);
    metronomeSetRhythm(
        bars: getRhythmAsMetroBar(widget.metronomeBlock.rhythmGroups),
        bars2: getRhythmAsMetroBar(widget.metronomeBlock.rhythmGroups2));
    metronomeSetBpm(bpm: widget.metronomeBlock.bpm.toDouble());
    metronomeSetBeatMuteChance(muteChance: widget.metronomeBlock.randomMute.toDouble() / 100.0);
    metronomeSetMuted(muted: false);

    MetronomeUtils.loadSounds(widget.metronomeBlock);

    // Start beat detection timer
    _beatDetection =
        Timer.periodic(const Duration(milliseconds: MetronomeParams.beatDetectionDurationMillis), (Timer t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (!_isStarted) return;

      metronomePollBeatEventHappened().then((BeatHappenedEvent? event) {
        if (event != null) _onBeatHappened(event);
      });
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void deactivate() {
    _stopMetronome();
    _beatDetection.cancel();
    super.deactivate();
  }

  // React to beat signal
  void _onBeatHappened(BeatHappenedEvent event) {
    if (!event.isRandomMute) {
      Timer(Duration(milliseconds: event.millisecondsBeforeStart), () {
        if (!mounted) return;
        setState(() {
          _activeBeatsModel.setBeatOnOff(true, event.barIndex, event.beatIndex, event.isPoly, event.isSecondary);
        });
      });

      Timer(Duration(milliseconds: event.millisecondsBeforeStart + MetronomeParams.blackScreenDurationMs), () {
        if (!mounted) return;
        setState(() {
          _activeBeatsModel.setBeatOnOff(false, event.barIndex, event.beatIndex, event.isPoly, event.isSecondary);
        });
      });
    }
  }

  void _onMetronomeToggleButtonClicked() async {
    if (_processingButtonClick) return;
    setState(() => _processingButtonClick = true);

    if (_isStarted) {
      await _stopMetronome();
    } else {
      await _startMetronome();
    }

    await Future.delayed(const Duration(milliseconds: TIOMusicParams.millisecondsPlayPauseDebounce));
    setState(() => _processingButtonClick = false);
  }

  Future<void> _startMetronome() async {
    audioInterruptionListener = (await AudioSession.instance).interruptionEventStream.listen((event) {
      if (event.type == AudioInterruptionType.unknown) _stopMetronome();
    });
    final success = await MetronomeFunctions.start();
    if (!success) {
      debugPrint('failed to start metronome');
      return;
    }
    _isStarted = true;
  }

  Future<void> _stopMetronome() async {
    await audioInterruptionListener?.cancel();
    await MetronomeFunctions.stop();
    _isStarted = false;
  }

  @override
  Widget build(BuildContext context) {
    return ParentInnerIsland(
      onMainIconPressed: _onMetronomeToggleButtonClicked,
      mainIcon:
          _isStarted ? const Icon(TIOMusicParams.pauseIcon, color: ColorTheme.primary) : widget.metronomeBlock.icon,
      parameterText: "${widget.metronomeBlock.bpm} bpm",
      centerView: _centerView(),
      textSpaceWidth: 60,
    );
  }

  Widget _centerView() {
    var children = [_metronome()];
    if (widget.metronomeBlock.rhythmGroups2.isNotEmpty) {
      children.add(_metronome(isSecondMetronome: true));
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: children,
    );
  }

  Widget _metronome({bool isSecondMetronome = false}) {
    var rhythmGroups = widget.metronomeBlock.rhythmGroups;
    if (isSecondMetronome) {
      rhythmGroups = widget.metronomeBlock.rhythmGroups2;
    }

    return ListenableBuilder(
      listenable: _activeBeatsModel,
      builder: (BuildContext context, Widget? child) {
        String beatsText = rhythmGroups[isSecondMetronome ? _activeBeatsModel.mainBar2 : _activeBeatsModel.mainBar]
            .beats
            .length
            .toString();

        // we need to check if this main beat still has a poly beat, otherwise the poly beat from last bar will still be shown
        if (rhythmGroups[isSecondMetronome ? _activeBeatsModel.mainBar2 : _activeBeatsModel.mainBar]
            .polyBeats
            .isNotEmpty) {
          // and we also need to check if the poly beat listener changed
          if (rhythmGroups[isSecondMetronome ? _activeBeatsModel.polyBar2 : _activeBeatsModel.polyBar]
              .polyBeats
              .isNotEmpty) {
            beatsText +=
                ":${rhythmGroups[isSecondMetronome ? _activeBeatsModel.polyBar2 : _activeBeatsModel.polyBar].polyBeats.length}";
          }
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // main beat
                BeatButton(
                  color: ColorTheme.surfaceTint,
                  beatTypes: const [BeatButtonType.unaccented],
                  beatTypeIndex: 0,
                  buttonSize: TIOMusicParams.beatButtonSizeIsland,
                  beatHighlighted: isSecondMetronome ? _activeBeatsModel.mainBeatOn2 : _activeBeatsModel.mainBeatOn,
                ),

                // poly beat
                BeatButton(
                  color: ColorTheme.surfaceTint,
                  beatTypes: const [BeatButtonType.unaccented],
                  beatTypeIndex: 0,
                  buttonSize: TIOMusicParams.beatButtonSizeIsland,
                  beatHighlighted: isSecondMetronome ? _activeBeatsModel.polyBeatOn2 : _activeBeatsModel.polyBeatOn,
                ),
              ],
            ),
            const SizedBox(width: 2),
            SizedBox(
              width: 38, // this prevents the widgets in the island from moving, when the text size changes
              child: Column(
                children: [
                  const SizedBox(height: 4),

                  // note symbol
                  CircleAvatar(
                    radius: MetronomeParams.rhythmSegmentSize / 4,
                    backgroundColor: Colors.transparent,
                    child: NoteHandler.getNoteSvg(
                        rhythmGroups[isSecondMetronome ? _activeBeatsModel.mainBar2 : _activeBeatsModel.mainBar]
                            .noteKey),
                  ),

                  // beat as number
                  Text(
                    beatsText,
                    style: const TextStyle(color: ColorTheme.surfaceTint),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
