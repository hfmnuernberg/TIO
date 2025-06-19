import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/tuner_type.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/widgets/input/number_input_and_slider_int.dart';
import 'package:tiomusic/widgets/tuner/sound_button_grid.dart';

class ChromaticPlayReference extends StatelessWidget {
  final int octave;
  final int? midi;
  final double frequency;
  final TunerType tunerType;
  final ValueChanged<int> onOctaveChange;
  final void Function(int midiNumber) onButtonToggle;

  const ChromaticPlayReference({
    super.key,
    required this.octave,
    required this.midi,
    required this.frequency,
    required this.tunerType,
    required this.onOctaveChange,
    required this.onButtonToggle,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final offset = (octave - 1) * 12;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        NumberInputAndSliderInt(
          value: octave,
          onChange: onOctaveChange,
          min: 1,
          max: 7,
          step: 1,
          label: l10n.commonOctave,
          textFieldWidth: TIOMusicParams.textFieldWidth1Digit,
        ),
        const SizedBox(height: 40),
        Text(
          '${l10n.tunerFrequency}: ${l10n.formatNumber(double.parse(frequency.toStringAsFixed(1)))} Hz',
          style: const TextStyle(color: ColorTheme.primary),
        ),
        const SizedBox(height: 40),
        SoundButtonGrid(
          tunerType: tunerType,
          offset: offset,
          onOctaveChange: onOctaveChange,
          onButtonToggle: onButtonToggle,
        ),
      ],
    );
  }
}
