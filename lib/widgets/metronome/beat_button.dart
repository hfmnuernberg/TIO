import 'package:flutter/material.dart';
import 'package:tiomusic/widgets/metronome/beat_button_type.dart';
import 'package:tiomusic/util/color_constants.dart';

class BeatButton extends StatelessWidget {
  final BeatButtonType type;
  final double buttonSize;
  final Color color;
  final bool isHighlighted;

  final Function()? onTap;

  const BeatButton({
    super.key,
    required this.type,
    required this.buttonSize,
    required this.color,
    this.isHighlighted = false,
    this.onTap,
  });

  Color get outerCircleColor {
    if (isHighlighted) return ColorTheme.tertiary60;
    if (type == BeatButtonType.muted) return ColorTheme.primary87;
    return color;
  }

  Color get innerCircleColor {
    if (type == BeatButtonType.accented) return ColorTheme.primary92;
    if (type != BeatButtonType.muted) return outerCircleColor;
    return isHighlighted ? ColorTheme.tertiary60 : ColorTheme.primary87;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(shape: BoxShape.circle, color: outerCircleColor),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Center(
            child: Container(
              width: buttonSize * 0.6,
              height: buttonSize * 0.6,
              decoration: BoxDecoration(shape: BoxShape.circle, color: innerCircleColor),
            ),
          ),
        ),
      ),
    );
  }
}
