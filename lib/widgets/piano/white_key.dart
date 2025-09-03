import 'package:flutter/material.dart';
import 'package:tiomusic/util/color_constants.dart';

const _releasedColor = Colors.white;
const _playedColor = ColorTheme.secondaryContainer;

class WhiteKey extends StatelessWidget {
  final bool isPlayed;
  final double width;
  final double height;
  final double borderWidth;
  final String semanticsLabel;
  final String? label;

  const WhiteKey({
    super.key,
    required this.isPlayed,
    required this.width,
    required this.height,
    required this.borderWidth,
    required this.semanticsLabel,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
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
            color: isPlayed ? _playedColor : _releasedColor,
            child: InkWell(
              excludeFromSemantics: true,
              splashColor: _playedColor,
              highlightColor: _playedColor,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: label == null
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
