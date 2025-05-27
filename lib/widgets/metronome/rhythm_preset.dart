import 'package:tiomusic/models/note_handler.dart';
import 'package:tiomusic/src/rust/api/modules/metronome_rhythm.dart';

const oneFourth = '1_4th';
const twoEighth = '2_8th';
const fourSixteenth = '4_16th';

class RhythmPreset {
  final List<BeatType> beats;
  final List<BeatTypePoly> polyBeats;
  final String noteKey;

  RhythmPreset({required this.beats, required this.polyBeats, required this.noteKey});
}

List<BeatTypePoly> _repeatPolyBeatPattern(int repetitions, List<BeatTypePoly> pattern) {
  return List.generate(repetitions, (_) => pattern).expand((e) => e).toList();
}

RhythmPreset getPresetRhythmPattern(String? noteKey) {
  switch (noteKey) {
    case oneFourth:
      return RhythmPreset(
        beats: [BeatType.Accented, BeatType.Unaccented, BeatType.Unaccented, BeatType.Unaccented],
        polyBeats: [],
        noteKey: NoteValues.quarter,
      );
    case twoEighth:
      return RhythmPreset(
        beats: [BeatType.Accented, BeatType.Unaccented, BeatType.Unaccented, BeatType.Unaccented],
        polyBeats: _repeatPolyBeatPattern(4, [BeatTypePoly.Muted, BeatTypePoly.Unaccented]),
        noteKey: NoteValues.quarter,
      );
    case fourSixteenth:
      return RhythmPreset(
        beats: [BeatType.Accented, BeatType.Unaccented, BeatType.Unaccented, BeatType.Unaccented],
        polyBeats: _repeatPolyBeatPattern(4, [
          BeatTypePoly.Muted,
          BeatTypePoly.Unaccented,
          BeatTypePoly.Unaccented,
          BeatTypePoly.Unaccented,
        ]),
        noteKey: NoteValues.quarter,
      );
    default:
      return RhythmPreset(
        beats: [BeatType.Accented, BeatType.Unaccented, BeatType.Unaccented, BeatType.Unaccented],
        polyBeats: [],
        noteKey: NoteValues.quarter,
      );
  }
}

// TODO: Implement equatable to check if preset matches
bool matchesPreset(RhythmPreset preset, List<BeatType> beats, List<BeatTypePoly> polyBeats, String noteKey) {
  if (preset.noteKey != noteKey) return false;
  if (preset.beats.length != beats.length || preset.polyBeats.length != polyBeats.length) return false;

  for (int i = 0; i < beats.length; i++) {
    if (beats[i] != preset.beats[i]) return false;
  }
  for (int i = 0; i < polyBeats.length; i++) {
    if (polyBeats[i] != preset.polyBeats[i]) return false;
  }
  return true;
}
