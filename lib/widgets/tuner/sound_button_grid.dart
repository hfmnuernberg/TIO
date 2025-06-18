import 'package:flutter/material.dart';
import 'package:tiomusic/models/tuner_type.dart';
import 'package:tiomusic/util/util_midi.dart';
import 'package:tiomusic/widgets/tuner/active_reference_sound_button.dart';
import 'package:tiomusic/widgets/tuner/sound_buttons.dart';

const double buttonWidth = 40;
const double buttonPadding = 4;

class SoundButtonGrid extends StatelessWidget {
  final TunerType tunerType;
  final int offset;
  final ActiveReferenceSoundButton buttonListener;
  final void Function(int) onOctaveChange;

  const SoundButtonGrid({
    super.key,
    required this.tunerType,
    required this.offset,
    required this.buttonListener,
    required this.onOctaveChange,
  });

  @override
  Widget build(BuildContext context) {
    if (tunerType == TunerType.guitar) {
      final guitarNotes = [40, 45, 50, 55, 59, 64];
      final guitarLabels = guitarNotes.map(midiToNameAndOctave).toList();

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SoundButtons(
            midiNumbers: guitarNotes,
            startIdx: 0,
            offset: 0,
            buttonListener: buttonListener,
            onOctaveChange: onOctaveChange,
            customLabels: guitarLabels,
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
              startIdx: 0,
              offset: offset,
              buttonListener: buttonListener,
              onOctaveChange: onOctaveChange,
            ),
            SizedBox(width: buttonWidth + buttonPadding * 2),
            SoundButtons(
              midiNumbers: const [30, 32, 34],
              startIdx: 2,
              offset: offset,
              buttonListener: buttonListener,
              onOctaveChange: onOctaveChange,
            ),
          ],
        ),
        SoundButtons(
          midiNumbers: const [24, 26, 28, 29, 31, 33, 35],
          startIdx: 5,
          offset: offset,
          buttonListener: buttonListener,
          onOctaveChange: onOctaveChange,
        ),
      ],
    );
  }
}
