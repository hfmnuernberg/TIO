import 'package:flutter/material.dart';
import 'package:tiomusic/util/color_constants.dart';

class WhiteKey extends StatelessWidget {
  final bool isPlayed;
  final double width;
  final double height;
  final double borderWidth;
  final String? label;

  final Function() onPlay;
  final Function() onRelease;

  const WhiteKey({
    super.key,
    required this.isPlayed,
    required this.width,
    required this.height,
    required this.borderWidth,
    this.label,
    required this.onPlay,
    required this.onRelease,
  });

  @override
  Widget build(BuildContext context) {
    const releasedColor = Colors.white;
    const playedColor = ColorTheme.secondaryContainer;
    const borderColor = ColorTheme.primaryFixedDim;

    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(color: isPlayed ? playedColor : releasedColor),
        child: Material(
          color: Colors.transparent,
          shape: RoundedRectangleBorder(side: BorderSide(color: borderColor, width: borderWidth)),
          child: InkWell(
            splashColor: playedColor,
            highlightColor: playedColor,
            onTapDown: (_) => onPlay(),
            onTapUp: (_) => onRelease(),
            child: Align(
              alignment: Alignment.bottomCenter,
              child:
                  label == null
                      ? Container()
                      : Text(
                        label!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: ColorTheme.primaryFixedDim, fontSize: width / 3),
                      ),
            ),
          ),
        ),
      ),
    );
  }
}
