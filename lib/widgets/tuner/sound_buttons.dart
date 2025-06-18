import 'package:flutter/material.dart';
import 'package:tiomusic/util/util_midi.dart';
import 'package:tiomusic/widgets/tuner/sound_button.dart';
import 'package:tiomusic/widgets/tuner/active_reference_sound_button.dart';

class SoundButtons extends StatelessWidget {
  final List<int> midiNumbers;
  final int startIdx;
  final int offset;
  final bool isGuitar;
  final ActiveReferenceSoundButton buttonListener;
  final void Function(int) onOctaveChange;

  const SoundButtons({
    super.key,
    required this.midiNumbers,
    required this.startIdx,
    required this.offset,
    this.isGuitar = false,
    required this.buttonListener,
    required this.onOctaveChange,
  });

  @override
  Widget build(BuildContext context) {
    final labels =
        isGuitar ? midiNumbers.map(midiToNameAndOctave).toList() : midiNumbers.map(midiToNameOneChar).toList();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(midiNumbers.length, (index) {
        final midi = midiNumbers[index] + offset;

        return SoundButton(
          midiNumber: midi,
          idx: startIdx + index,
          buttonListener: buttonListener,
          label: labels[index],
          onOctaveChange: onOctaveChange,
        );
      }),
    );
  }
}
