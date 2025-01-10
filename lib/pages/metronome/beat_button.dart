import 'package:flutter/material.dart';
import 'package:tiomusic/src/rust/api/modules/metronome_rhythm.dart';
import 'package:tiomusic/util/color_constants.dart';

enum BeatButtonType {
  accented,
  unaccented,
  muted,
}

List<BeatButtonType> getBeatButtonsFromBeats(List<BeatType> beats) {
  List<BeatButtonType> beatTypes = List.empty(growable: true);
  for (var beatType in beats) {
    switch (beatType) {
      case BeatType.Accented:
        beatTypes.add(BeatButtonType.accented);
        break;
      case BeatType.Unaccented:
        beatTypes.add(BeatButtonType.unaccented);
        break;
      case BeatType.Muted:
        beatTypes.add(BeatButtonType.muted);
        break;
    }
  }
  return beatTypes;
}

List<BeatButtonType> getBeatButtonsFromBeatsPoly(List<BeatTypePoly> beatsPoly) {
  List<BeatButtonType> beatTypes = List.empty(growable: true);
  for (var beatTypePoly in beatsPoly) {
    switch (beatTypePoly) {
      case BeatTypePoly.Accented:
        beatTypes.add(BeatButtonType.accented);
        break;
      case BeatTypePoly.Unaccented:
        beatTypes.add(BeatButtonType.unaccented);
        break;
      case BeatTypePoly.Muted:
        beatTypes.add(BeatButtonType.muted);
        break;
    }
  }
  return beatTypes;
}

class BeatButton extends StatefulWidget {
  // NOTE: we need both the list of beats and the index here for the switching to work!

  final Color color;
  final List<BeatButtonType> beatTypes;
  final int beatTypeIndex;
  final double buttonSize;

  final bool beatHighlighted;

  final Function()? onTap;

  const BeatButton({
    super.key,
    required this.color,
    required this.beatTypes,
    required this.beatTypeIndex,
    required this.buttonSize,
    this.beatHighlighted = false,
    this.onTap,
  });

  @override
  State<BeatButton> createState() => _BeatButtonState();
}

class _BeatButtonState extends State<BeatButton> {
  @override
  Widget build(BuildContext context) {
    Color standardColor = widget.beatHighlighted ? ColorTheme.tertiary60 : widget.color;
    Color mutedColor = widget.beatHighlighted ? ColorTheme.tertiary60 : ColorTheme.primary87;
    Color innerCircleColor = standardColor;

    if (widget.beatTypes[widget.beatTypeIndex] == BeatButtonType.accented) {
      innerCircleColor = ColorTheme.primary92;
    } else if (widget.beatTypes[widget.beatTypeIndex] == BeatButtonType.muted) {
      standardColor = mutedColor;
      innerCircleColor = mutedColor;
    }

    return Center(
      // the center widget is necessary for the width and height of the container to work
      child: Container(
          width: widget.buttonSize,
          height: widget.buttonSize,
          decoration: BoxDecoration(shape: BoxShape.circle, color: standardColor),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: widget.onTap,
            child: Center(
              child: Container(
                width: widget.buttonSize * 0.6,
                height: widget.buttonSize * 0.6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: innerCircleColor,
                ),
              ),
            ),
          )),
    );
  }
}
