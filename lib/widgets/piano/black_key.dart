import 'package:flutter/material.dart';
import 'package:tiomusic/util/color_constants.dart';

class BlackKey extends StatelessWidget {
  final bool isPlayed;
  final double width;
  final double height;
  final double borderWidth;

  final Function() onPlay;
  final Function() onRelease;

  const BlackKey({
    super.key,
    required this.isPlayed,
    required this.width,
    required this.height,
    required this.borderWidth,
    required this.onPlay,
    required this.onRelease,
  });

  @override
  Widget build(BuildContext context) {
    const releasedColor = ColorTheme.onTertiaryFixed;
    const shadedReleasedColor = ColorTheme.tertiary;

    final playedColor = HSLColor.fromColor(ColorTheme.onTertiaryFixed).withLightness(0.25).toColor();
    final shadedPlayedColor = HSLColor.fromColor(ColorTheme.tertiary).withLightness(0.45).toColor();

    return SizedBox(
      width: width,
      height: height,
      child: ClipRect(
        child: Padding(
          padding: EdgeInsets.all(borderWidth),
          child: Material(
            color: Colors.transparent,
            child: Ink(
              decoration: BoxDecoration(
                color: isPlayed ? playedColor : releasedColor,
                border: Border(
                  left: BorderSide(color: isPlayed ? shadedPlayedColor : shadedReleasedColor, width: 10),
                  bottom: BorderSide(color: isPlayed ? shadedPlayedColor : shadedReleasedColor, width: 10),
                ),
              ),
              child: InkWell(
                splashColor: playedColor,
                highlightColor: playedColor,
                onTapDown: (_) => onPlay(),
                onTapUp: (_) => onRelease(),
                child: Align(alignment: Alignment.bottomCenter, child: Container()),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
