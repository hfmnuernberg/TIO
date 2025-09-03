import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/widgets/metronome/beat/beat.dart';
import 'package:tiomusic/widgets/metronome/beat/beat_button_type.dart';

class Beats extends StatelessWidget {
  final List<BeatButtonType> beatTypes;
  final int? highlightedBeatIndex;
  final double width;
  final double? spaceBetweenBeats;

  const Beats({
    super.key,
    required this.beatTypes,
    required this.highlightedBeatIndex,
    required this.width,
    this.spaceBetweenBeats,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: beatTypes.isEmpty
          ? const SizedBox(height: TIOMusicParams.beatButtonSizeMainPage + TIOMusicParams.beatButtonPadding * 2)
          : Row(
              children: beatTypes
                  .expandIndexed(
                    (i, beatType) => [
                      if (spaceBetweenBeats != null && i > 0)
                        SizedBox(
                          width:
                              spaceBetweenBeats! -
                              TIOMusicParams.beatButtonSizeMainPage -
                              TIOMusicParams.beatButtonPadding * 2,
                        ),
                      Beat(beatType: beatType, isHighlighted: i == highlightedBeatIndex),
                    ],
                  )
                  .toList(),
            ),
    );
  }
}
