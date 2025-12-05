import 'package:flutter/material.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants/constants.dart';
import 'package:tiomusic/widgets/metronome/beat/beat_button.dart';
import 'package:tiomusic/widgets/metronome/beat/beat_button_type.dart';

class Beat extends StatelessWidget {
  final BeatButtonType beatType;
  final bool isHighlighted;

  const Beat({super.key, required this.beatType, required this.isHighlighted});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(TIOMusicParams.beatButtonPadding),
      child: BeatButton(
        color: ColorTheme.surfaceTint,
        type: beatType,
        buttonSize: TIOMusicParams.beatButtonSizeMainPage,
        isHighlighted: isHighlighted,
      ),
    );
  }
}
