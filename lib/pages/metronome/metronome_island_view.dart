import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/metronome_block.dart';
import 'package:tiomusic/models/note_handler.dart';
import 'package:tiomusic/models/rhythm_group.dart';
import 'package:tiomusic/pages/parent_tool/parent_inner_island.dart';
import 'package:tiomusic/services/audio_session.dart';
import 'package:tiomusic/services/audio_system.dart';
import 'package:tiomusic/services/file_system.dart';
import 'package:tiomusic/services/wakelock.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/domain/metronome/metronome.dart';
import 'package:tiomusic/domain/metronome/metronome_beat.dart';
import 'package:tiomusic/widgets/metronome/beat/beat_button.dart';
import 'package:tiomusic/widgets/metronome/beat/beat_button_type.dart';

class MetronomeIslandView extends StatefulWidget {
  final MetronomeBlock metronomeBlock;

  const MetronomeIslandView({super.key, required this.metronomeBlock});

  @override
  State<MetronomeIslandView> createState() => _MetronomeIslandViewState();
}

class _MetronomeIslandViewState extends State<MetronomeIslandView> {
  late final Metronome metronome;

  bool processingButtonClick = false;

  @override
  void initState() {
    super.initState();

    metronome = Metronome(
      context.read<AudioSystem>(),
      context.read<AudioSession>(),
      context.read<FileSystem>(),
      context.read<Wakelock>(),
      onBeatStart: refresh,
      onBeatStop: refresh,
    );

    // metronome.mute();
    metronome.setVolume(widget.metronomeBlock.volume);
    metronome.setBpm(widget.metronomeBlock.bpm);
    metronome.setChanceOfMuteBeat(widget.metronomeBlock.randomMute);
    metronome.setRhythm(widget.metronomeBlock.rhythmGroups, widget.metronomeBlock.rhythmGroups2);
    metronome.sounds.loadAllSounds(widget.metronomeBlock);
  }

  @override
  void deactivate() {
    metronome.stop();
    super.deactivate();
  }

  @override
  void dispose() {
    metronome.stop();
    super.dispose();
  }

  Future<void> refresh(_) async {
    if (!mounted) return metronome.stop();
    setState(() {});
  }

  Future<void> onMetronomeToggleButtonClicked() async {
    if (processingButtonClick) return;
    setState(() => processingButtonClick = true);

    if (metronome.isOn) {
      await metronome.stop();
    } else {
      await metronome.start();
    }

    await Future.delayed(const Duration(milliseconds: TIOMusicParams.millisecondsPlayPauseDebounce));
    setState(() => processingButtonClick = false);
  }

  @override
  Widget build(BuildContext context) {
    return ParentInnerIsland(
      onMainIconPressed: onMetronomeToggleButtonClicked,
      mainIcon:
          metronome.isOn ? const Icon(TIOMusicParams.pauseIcon, color: ColorTheme.primary) : widget.metronomeBlock.icon,
      parameterText: '${widget.metronomeBlock.bpm} ${context.l10n.commonBpm}',
      centerView: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Beats(rhythmGroups: widget.metronomeBlock.rhythmGroups, currentBeat: metronome.currentBeat),
          if (widget.metronomeBlock.rhythmGroups2.isNotEmpty)
            Beats(rhythmGroups: widget.metronomeBlock.rhythmGroups2, currentBeat: metronome.currentSecondaryBeat),
        ],
      ),
      textSpaceWidth: 60,
    );
  }
}

class Beats extends StatelessWidget {
  final List<RhythmGroup> rhythmGroups;
  final MetronomeBeat currentBeat;

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
