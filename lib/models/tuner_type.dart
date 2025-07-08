import 'package:tiomusic/util/util_midi.dart';

const Set<int> emptySet = {};

enum TunerType {
  chromatic(midiToName, emptySet),
  guitar(midiToNameAndOctave, {40, 45, 50, 55, 59, 64});

  final Set<int> midis;
  final String Function(int midi) toName;

  const TunerType(this.toName, this.midis);

  bool isSupportedMidi(int midi) => midis.isEmpty || midis.contains(midi);

  String getNameForMidi(int midi) => toName(midi);
}
