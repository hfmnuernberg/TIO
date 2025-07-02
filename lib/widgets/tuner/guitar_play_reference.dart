import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/util_midi.dart';
import 'package:tiomusic/widgets/tuner/sound_button.dart';

class GuitarPlayReference extends StatelessWidget {
  final int? midi;
  final double frequency;
  final void Function(int midi) onToggle;

  const GuitarPlayReference({super.key, required this.midi, required this.frequency, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${l10n.tunerFrequency}: ${l10n.formatNumber(double.parse(frequency.toStringAsFixed(1)))} Hz',
          style: const TextStyle(color: ColorTheme.primary),
        ),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children:
              [40, 45, 50, 55, 59, 64]
                  .map(
                    (midi) => SoundButton(
                      isActive: midi == midi,
                      label: midiToNameAndOctave(midi),
                      onToggle: () => onToggle(midi),
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }
}
