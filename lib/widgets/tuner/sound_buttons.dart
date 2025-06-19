import 'package:flutter/material.dart';
import 'package:tiomusic/util/util_midi.dart';
import 'package:tiomusic/widgets/tuner/sound_button.dart';
import 'package:tiomusic/widgets/tuner/active_reference_sound_button.dart';

class SoundButtons extends StatelessWidget {
  final List<int> midiNumbers;
  final int? currentMidi;
  final int startIdx;
  final int offset;
  final bool isGuitar;
  // TODO: Check return type ValueChanged<int> instead of void Function(int)
  final void Function(int) onOctaveChange;
  final void Function(int midiNumber) onButtonToggle;

  const SoundButtons({
    super.key,
    required this.midiNumbers,
    required this.currentMidi,
    required this.startIdx,
    required this.offset,
    this.isGuitar = false,
    required this.onOctaveChange,
    required this.onButtonToggle,
  });

  @override
  Widget build(BuildContext context) {
    final labels =
        isGuitar ? midiNumbers.map(midiToNameAndOctave).toList() : midiNumbers.map(midiToNameOneChar).toList();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(midiNumbers.length, (index) {
        final midi = midiNumbers[index] + offset;

        // return SoundButton(
        //   midiNumber: midi,
        //   idx: startIdx + index,
        //   label: labels[index],
        //   onToggle: onOctaveChange,
        // );

        return SoundButton(
          midiNumber: midi,
          label: labels[index],
          isOn: currentMidi == midi,
          onToggle: () => onButtonToggle(midi),
        );
      }),
    );
  }
}
