import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/tuner_type.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/widgets/tuner/active_reference_sound_button.dart';
import 'package:tiomusic/widgets/tuner/sound_button_grid.dart';

class InstrumentPlayReference extends StatelessWidget {
  final int octave;
  final double frequency;
  final TunerType tunerType;
  final ActiveReferenceSoundButton buttonListener;
  final ValueChanged<int> onOctaveChange;

  const InstrumentPlayReference({
    super.key,
    required this.octave,
    required this.frequency,
    required this.tunerType,
    required this.buttonListener,
    required this.onOctaveChange,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final offset = (octave - 1) * 12;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${l10n.tunerFrequency}: ${l10n.formatNumber(double.parse(frequency.toStringAsFixed(1)))} Hz',
          style: const TextStyle(color: ColorTheme.primary),
        ),
        const SizedBox(height: 40),
        SoundButtonGrid(
          tunerType: tunerType,
          offset: offset,
          buttonListener: buttonListener,
          onOctaveChange: onOctaveChange,
        ),
      ],
    );
  }
}
