import 'package:tiomusic/src/rust/api/modules/metronome_rhythm.dart';
import 'package:tiomusic/widgets/metronome/rhythm_preset.dart';

RhythmPresetKey? findMatchingPresetKey({
  required List<BeatType> beats,
  required List<BeatTypePoly> polyBeats,
  required String noteKey,
}) {
  for (final key in RhythmPresetKey.values) {
    if (RhythmPreset.fromKey(key) == RhythmPreset(beats: beats, polyBeats: polyBeats, noteKey: noteKey)) {
      return key;
    }
  }
  return null;
}
