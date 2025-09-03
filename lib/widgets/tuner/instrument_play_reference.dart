import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/tuner_type.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/util_midi.dart';
import 'package:tiomusic/widgets/tuner/sound_button.dart';

class InstrumentPlayReference extends StatelessWidget {
  final TunerType tunerType;
  final int? midi;
  final double frequency;
  final void Function(int midi) onToggle;

  const InstrumentPlayReference({
    super.key,
    required this.tunerType,
    required this.midi,
    required this.frequency,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${context.l10n.tunerFrequency}: ${context.l10n.formatNumber(double.parse(frequency.toStringAsFixed(1)))} Hz',
          style: const TextStyle(color: ColorTheme.primary),
        ),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: tunerType.midis
              .toList()
              .map(
                (currentMidi) => SoundButton(
                  isActive: midi == currentMidi,
                  label: midiToNameAndOctave(currentMidi),
                  onToggle: () => onToggle(currentMidi),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
