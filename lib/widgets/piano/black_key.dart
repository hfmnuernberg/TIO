import 'package:flutter/material.dart';
import 'package:tiomusic/util/color_constants.dart';

const _releasedColor = ColorTheme.onTertiaryFixed;
const _releasedBorderColor = ColorTheme.tertiary;

final _playedColor = HSLColor.fromColor(ColorTheme.onTertiaryFixed).withLightness(0.6).withAlpha(0.2).toColor();
final _playedBorderColor = HSLColor.fromColor(ColorTheme.tertiary).withLightness(0.6).toColor();

class BlackKey extends StatelessWidget {
  final bool isPlayed;
  final double width;
  final double height;
  final double borderWidth;
  final String semanticsLabel;

  const BlackKey({
    super.key,
    required this.isPlayed,
    required this.width,
    required this.height,
    required this.borderWidth,
    required this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final color = isPlayed ? _playedColor : _releasedColor;
    final borderColor = isPlayed ? _playedBorderColor : _releasedBorderColor;

    return Semantics(
      label: semanticsLabel,
      button: true,
      excludeSemantics: true,
      child: SizedBox(
        width: width,
        height: height,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: borderWidth),
          child: Material(
            color: _releasedColor,
            child: InkWell(
              excludeFromSemantics: true,
              splashColor: _playedColor,
              highlightColor: _playedColor,
              child: Ink(
                decoration: BoxDecoration(
                  color: color,
                  border: Border(
                    left: BorderSide(color: borderColor, width: 10),
                    bottom: BorderSide(color: borderColor, width: 10),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
