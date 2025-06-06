import 'dart:async';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/metronome_block.dart';
import 'package:tiomusic/models/note_handler.dart';
import 'package:tiomusic/models/rhythm_group.dart';
import 'package:tiomusic/pages/metronome/metronome_functions.dart';
import 'package:tiomusic/pages/metronome/metronome_utils.dart';
import 'package:tiomusic/pages/parent_tool/parent_inner_island.dart';
import 'package:tiomusic/services/file_system.dart';
import 'package:tiomusic/src/rust/api/api.dart';
import 'package:tiomusic/src/rust/api/modules/metronome.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/util/log.dart';
import 'package:tiomusic/util/util_functions.dart';
import 'package:tiomusic/widgets/metronome/beat/beat_button.dart';
import 'package:tiomusic/widgets/metronome/beat/beat_button_type.dart';
import 'package:tiomusic/widgets/metronome/current_beat.dart';

class MetronomeIslandView extends StatefulWidget {
  final MetronomeBlock metronomeBlock;

  const MetronomeIslandView({super.key, required this.metronomeBlock});

  @override
  State<MetronomeIslandView> createState() => _MetronomeIslandViewState();
}

class _MetronomeIslandViewState extends State<MetronomeIslandView> {
  static final _logger = createPrefixLogger('MetronomeIslandView');

  late FileSystem _fs;

  bool _isStarted = false;
  late Timer _beatDetection;

  CurrentBeat currentPrimaryBeat = CurrentBeat();
  CurrentBeat currentSecondaryBeat = CurrentBeat();

  bool _processingButtonClick = false;

  StreamSubscription<AudioInterruptionEvent>? audioInterruptionListener;

  @override
  void initState() {
    super.initState();

    _fs = context.read<FileSystem>();

    metronomeSetVolume(volume: widget.metronomeBlock.volume);
    metronomeSetRhythm(
      bars: getRhythmAsMetroBar(widget.metronomeBlock.rhythmGroups),
      bars2: getRhythmAsMetroBar(widget.metronomeBlock.rhythmGroups2),
    );
    metronomeSetBpm(bpm: widget.metronomeBlock.bpm.toDouble());
    metronomeSetBeatMuteChance(muteChance: widget.metronomeBlock.randomMute.toDouble() / 100.0);
    metronomeSetMuted(muted: false);

    MetronomeUtils.loadSounds(_fs, widget.metronomeBlock);

    _beatDetection = Timer.periodic(const Duration(milliseconds: MetronomeParams.beatDetectionDurationMillis), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (!_isStarted) return;

      metronomePollBeatEventHappened().then((event) {
        if (event != null) onBeatHappened(event);
      });
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void deactivate() {
    stopMetronome();
    _beatDetection.cancel();
    super.deactivate();
  }

  void onBeatHappened(BeatHappenedEvent event) {
    if (event.isRandomMute) return;

    Timer(Duration(milliseconds: event.millisecondsBeforeStart), () {
      if (!mounted) return;
      currentPrimaryBeat = MetronomeUtils.getCurrentPrimaryBeatFromEvent(isOn: true, event: event);
      currentSecondaryBeat = MetronomeUtils.getCurrentSecondaryBeatFromEvent(isOn: true, event: event);
      setState(() {});
    });

    Timer(Duration(milliseconds: event.millisecondsBeforeStart + MetronomeParams.flashDurationInMs), () {
      if (!mounted) return;
      currentPrimaryBeat = MetronomeUtils.getCurrentPrimaryBeatFromEvent(isOn: false, event: event);
      currentSecondaryBeat = MetronomeUtils.getCurrentSecondaryBeatFromEvent(isOn: false, event: event);
      setState(() {});
    });
  }

  void onMetronomeToggleButtonClicked() async {
    if (_processingButtonClick) return;
    setState(() => _processingButtonClick = true);

    if (_isStarted) {
      await stopMetronome();
    } else {
      await startMetronome();
    }

    await Future.delayed(const Duration(milliseconds: TIOMusicParams.millisecondsPlayPauseDebounce));
    setState(() => _processingButtonClick = false);
  }

  Future<void> startMetronome() async {
    audioInterruptionListener = (await AudioSession.instance).interruptionEventStream.listen((event) {
      if (event.type == AudioInterruptionType.unknown) stopMetronome();
    });
    final success = await MetronomeFunctions.start();
    if (!success) {
      _logger.e('Unable to start metronome.');
      return;
    }
    _isStarted = true;
  }

  Future<void> stopMetronome() async {
    await audioInterruptionListener?.cancel();
    await MetronomeFunctions.stop();
    _isStarted = false;
  }

  @override
  Widget build(BuildContext context) {
    return ParentInnerIsland(
      onMainIconPressed: onMetronomeToggleButtonClicked,
      mainIcon:
          _isStarted ? const Icon(TIOMusicParams.pauseIcon, color: ColorTheme.primary) : widget.metronomeBlock.icon,
      parameterText: '${widget.metronomeBlock.bpm} ${context.l10n.commonBpm}',
      centerView: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Beats(rhythmGroups: widget.metronomeBlock.rhythmGroups, currentBeat: currentPrimaryBeat),
          if (widget.metronomeBlock.rhythmGroups2.isNotEmpty)
            Beats(rhythmGroups: widget.metronomeBlock.rhythmGroups2, currentBeat: currentSecondaryBeat),
        ],
      ),
      textSpaceWidth: 60,
    );
  }
}

class Beats extends StatelessWidget {
  final List<RhythmGroup> rhythmGroups;
  final CurrentBeat currentBeat;

  const Beats({super.key, required this.rhythmGroups, required this.currentBeat});

  RhythmGroup get rhythmGroup => rhythmGroups[currentBeat.segmentIndex ?? 0];

  bool get isMainBeatHighlighted => currentBeat.mainBeatIndex != null;

  bool get isPolyBeatHighlighted => currentBeat.polyBeatIndex != null;

  String get beatsText =>
      rhythmGroup.beats.isEmpty && rhythmGroup.polyBeats.isEmpty
          ? '${rhythmGroup.beats.length}'
          : '${rhythmGroup.beats.length}:${rhythmGroup.polyBeats.length}';

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            BeatButton(
              type: BeatButtonType.unaccented,
              buttonSize: TIOMusicParams.beatButtonSizeIsland,
              color: ColorTheme.surfaceTint,
              isHighlighted: isMainBeatHighlighted,
            ),
            BeatButton(
              type: BeatButtonType.unaccented,
              buttonSize: TIOMusicParams.beatButtonSizeIsland,
              color: ColorTheme.surfaceTint,
              isHighlighted: isPolyBeatHighlighted,
            ),
          ],
        ),
        const SizedBox(width: 2),
        SizedBox(
          width: 38,
          child: Column(
            children: [
              const SizedBox(height: 4),
              CircleAvatar(
                radius: MetronomeParams.rhythmSegmentSize / 4,
                backgroundColor: Colors.transparent,
                child: NoteHandler.getNoteSvg(rhythmGroup.noteKey),
              ),
              Text(beatsText, style: const TextStyle(color: ColorTheme.surfaceTint)),
            ],
          ),
        ),
      ],
    );
  }
}
