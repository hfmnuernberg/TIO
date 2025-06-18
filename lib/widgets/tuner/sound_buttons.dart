import 'package:flutter/material.dart';
import 'package:tiomusic/widgets/tuner/sound_button.dart';
import 'package:tiomusic/widgets/tuner/active_reference_sound_button.dart';

class SoundButtons extends StatelessWidget {
  final List<int> midiNumbers;
  final int startIdx;
  final int offset;
  final ActiveReferenceSoundButton buttonListener;
  final List<String>? customLabels;
  final void Function(int) onOctaveChange;

  const SoundButtons({
    super.key,
    required this.midiNumbers,
    required this.startIdx,
    required this.offset,
    required this.buttonListener,
    this.customLabels,
    required this.onOctaveChange,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(midiNumbers.length, (index) {
        final midi = midiNumbers[index] + offset;

        return SoundButton(
          midiNumber: midi,
          idx: startIdx + index,
          buttonListener: buttonListener,
          customLabel: customLabels != null ? customLabels![index] : null,
          onOctaveChange: onOctaveChange,
        );
      }),
    );
  }
}
