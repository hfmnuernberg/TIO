import 'package:tiomusic/util/util_midi.dart';

const Set<int> emptySet = {};

enum TunerType {
  chromatic(midiToName, emptySet),
  guitar(midiToNameAndOctave, {40, 45, 50, 55, 59, 64}),
  bass(midiToNameAndOctave, {28, 33, 38, 43}),
  ukulele(midiToNameAndOctave, {67, 60, 64, 69}),
  viola(midiToNameAndOctave, {48, 55, 62, 69}),
  violin(midiToNameAndOctave, {55, 62, 69, 76}),
  violoncello(midiToNameAndOctave, {36, 43, 50, 57});

  final Set<int> midis;
  final String Function(int midi) toName;

  const TunerType(this.toName, this.midis);

  bool isSupportedMidi(int midi) => midis.isEmpty || midis.contains(midi);

  String getNameForMidi(int midi) => toName(midi);
}
