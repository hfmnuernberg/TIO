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

    return SizedBox(
      width: width,
      height: height,
      child: ClipRect(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: borderWidth),
          child: Material(
            color: isPlayed ? playedColor : releasedColor,
            child: InkWell(
              splashColor: playedColor,
              highlightColor: playedColor,
              onTapDown: (_) => onPlay(),
              onTapUp: (_) => onRelease(),
              child: Align(
                alignment: Alignment.bottomCenter,
                child:
                    label == null
                        ? null
                        : Text(
                          label!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: ColorTheme.primaryFixedDim, fontSize: width / 3),
                        ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
