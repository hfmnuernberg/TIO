import 'package:flutter/material.dart';
import 'package:tiomusic/models/rhythm_group.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/widgets/metronome/beat_button_type.dart';
import 'package:tiomusic/widgets/metronome/beats.dart';
import 'package:tiomusic/widgets/metronome/notes.dart';

class RhythmSegment extends StatelessWidget {
  final RhythmGroup rhythmGroup;
  final int? highlightedMainBeatIndex;
  final int? highlightedPolyBeatIndex;

  final Function onEdit;

  const RhythmSegment({
    super.key,
    required this.rhythmGroup,
    required this.highlightedMainBeatIndex,
    required this.highlightedPolyBeatIndex,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    double? spaceForEachPoly;
    double? spaceForEachMainBeat;
    double totalGroupWidth = TIOMusicParams.beatButtonSizeMainPage + TIOMusicParams.beatButtonPadding * 2;
    if (rhythmGroup.polyBeats.length > rhythmGroup.beats.length) {
      totalGroupWidth = totalGroupWidth * rhythmGroup.polyBeats.length;
      spaceForEachMainBeat = totalGroupWidth / rhythmGroup.beats.length;
    } else {
      totalGroupWidth = totalGroupWidth * rhythmGroup.beats.length;
      spaceForEachPoly = totalGroupWidth / rhythmGroup.polyBeats.length;
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: ColorTheme.primary87),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          children: [
            Notes(
              numberOfNotes: rhythmGroup.beats.length,
              noteKey: rhythmGroup.noteKey,
              width: totalGroupWidth,
              spaceBetweenNotes: spaceForEachMainBeat,
            ),
            Beats(
              beatTypes: BeatButtonType.fromMainBeatTypes(rhythmGroup.beats),
              highlightedBeatIndex: highlightedMainBeatIndex,
              width: totalGroupWidth,
              spaceBetweenBeats: spaceForEachMainBeat,
            ),
            Beats(
              beatTypes: BeatButtonType.fromPolyBeatTypes(rhythmGroup.polyBeats),
              highlightedBeatIndex: highlightedPolyBeatIndex,
              width: totalGroupWidth,
              spaceBetweenBeats: spaceForEachPoly,
            ),
          ],
        ),
      ),
    );
  }
}
