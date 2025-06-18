import 'package:flutter/material.dart';
import 'package:tiomusic/models/tuner_type.dart';
import 'package:tiomusic/widgets/tuner/sound_button.dart';
import 'package:tiomusic/widgets/tuner/active_reference_sound_button.dart';

const double buttonWidth = 40;
const double buttonPadding = 4;

class SoundButtonRows extends StatelessWidget {
  final TunerType tunerType;
  final int offset;
  final ActiveReferenceSoundButton buttonListener;

  const SoundButtonRows({super.key, required this.tunerType, required this.offset, required this.buttonListener});

  List<Widget> _buildSoundButtons(List<int> midiNumbers, int startIdx, int offset) => List.generate(
    midiNumbers.length,
    (index) =>
        SoundButton(midiNumber: midiNumbers[index] + offset, idx: startIdx + index, buttonListener: buttonListener),
  );

  @override
  Widget build(BuildContext context) {
    if (tunerType == TunerType.guitar) {
      final guitarNotes = [40, 45, 50, 55, 59, 64]; // E2, A2, D3, G3, B3, E4
      return Row(mainAxisAlignment: MainAxisAlignment.center, children: _buildSoundButtons(guitarNotes, 0, 0));
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ..._buildSoundButtons([25, 27], 0, offset),
            SizedBox(width: buttonWidth + buttonPadding * 2),
            ..._buildSoundButtons([30, 32, 34], 2, offset),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _buildSoundButtons([24, 26, 28, 29, 31, 33, 35], 5, offset),
        ),
      ],
    );
  }
}
