import 'package:flutter/material.dart';
import 'package:tiomusic/models/tuner_type.dart';
import 'package:tiomusic/widgets/tuner/sound_buttons.dart';

const double buttonWidth = 40;
const double buttonPadding = 4;

class SoundButtonGrid extends StatelessWidget {
  final TunerType tunerType;
  final int? currentMidi;
  final int offset;
  final void Function(int) onOctaveChange;
  final void Function(int midiNumber) onButtonToggle;

  const SoundButtonGrid({
    super.key,
    required this.tunerType,
    this.currentMidi,
    required this.offset,
    required this.onOctaveChange,
    required this.onButtonToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (tunerType == TunerType.guitar) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SoundButtons(
            midiNumbers: const [40, 45, 50, 55, 59, 64],
            currentMidi: currentMidi,
            startIdx: 0,
            offset: 0,
            isGuitar: true,
            onOctaveChange: onOctaveChange,
            onButtonToggle: onButtonToggle,
          ),
        ],
      );
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SoundButtons(
              midiNumbers: const [25, 27],
              currentMidi: currentMidi,
              startIdx: 0,
              offset: offset,
              onOctaveChange: onOctaveChange,
              onButtonToggle: onButtonToggle,
            ),
            SizedBox(width: buttonWidth + buttonPadding * 2),
            SoundButtons(
              midiNumbers: const [30, 32, 34],
              currentMidi: currentMidi,
              startIdx: 2,
              offset: offset,
              onOctaveChange: onOctaveChange,
              onButtonToggle: onButtonToggle,
            ),
          ],
        ),
        SoundButtons(
          midiNumbers: const [24, 26, 28, 29, 31, 33, 35],
          currentMidi: currentMidi,
          startIdx: 5,
          offset: offset,
          onOctaveChange: onOctaveChange,
          onButtonToggle: onButtonToggle,
        ),
      ],
    );
  }
}
