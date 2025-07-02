import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/util/util_midi.dart';
import 'package:tiomusic/widgets/input/number_input_and_slider_int.dart';
import 'package:tiomusic/widgets/tuner/sound_button.dart';

const defaultOctave = 4;

class ChromaticPlayReference extends StatefulWidget {
  final int? midi;
  final double frequency;
  final void Function(int midi) onToggle;

  const ChromaticPlayReference({super.key, required this.midi, required this.frequency, required this.onToggle});

  @override
  State<ChromaticPlayReference> createState() => _ChromaticPlayReferenceState();
}

class _ChromaticPlayReferenceState extends State<ChromaticPlayReference> {
  int octave = defaultOctave;

  void handleOctaveChange(int newOctave) => setState(() => octave = newOctave);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        NumberInputAndSliderInt(
          value: octave,
          onChange: handleOctaveChange,
          min: 1,
          max: 7,
          step: 1,
          label: l10n.commonOctave,
          textFieldWidth: TIOMusicParams.textFieldWidth1Digit,
        ),
        const SizedBox(height: 40),
        Text(
          '${l10n.tunerFrequency}: ${l10n.formatNumber(double.parse(widget.frequency.toStringAsFixed(1)))} Hz',
          style: const TextStyle(color: ColorTheme.primary),
        ),
        const SizedBox(height: 40),
        PianoKeys(midi: widget.midi, octave: octave, onToggle: widget.onToggle),
      ],
    );
  }
}

const double buttonWidth = 40;
const double buttonPadding = 4;

class PianoKeys extends StatelessWidget {
  final int? midi;
  final int octave;
  final void Function(int midi) onToggle;

  const PianoKeys({super.key, this.midi, required this.octave, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final offset = (octave - 1) * 12;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...[25, 27].map(
              (midi) => SoundButton(
                isActive: midi == midi,
                label: midiToNameOneChar(midi),
                onToggle: () => onToggle(midi + offset),
              ),
            ),

            SizedBox(width: buttonWidth + buttonPadding * 2),

            ...[30, 32, 34].map(
              (midi) => SoundButton(
                isActive: midi == midi,
                label: midiToNameOneChar(midi),
                onToggle: () => onToggle(midi + offset),
              ),
            ),
          ],
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...[24, 26, 28, 29, 31, 33, 35].map(
              (midi) => SoundButton(
                isActive: midi == midi,
                label: midiToNameOneChar(midi),
                onToggle: () => onToggle(midi + offset),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
