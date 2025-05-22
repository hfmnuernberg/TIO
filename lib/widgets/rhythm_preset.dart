import 'package:tiomusic/models/note_handler.dart';
import 'package:tiomusic/src/rust/api/modules/metronome_rhythm.dart';

class RhythmPreset {
  final List<BeatType> beats;
  final List<BeatTypePoly> polyBeats;
  final String noteKey;

  RhythmPreset({required this.beats, required this.polyBeats, required this.noteKey});
}

RhythmPreset getPresetRhythmPattern(String noteKey) {
  switch (noteKey) {
    case NoteValues.quarter:
      return RhythmPreset(
        beats: [BeatType.Accented, BeatType.Unaccented, BeatType.Unaccented, BeatType.Unaccented],
        polyBeats: [],
        noteKey: NoteValues.quarter,
      );

    case NoteValues.eighth:
      return RhythmPreset(
        beats: [BeatType.Accented, BeatType.Unaccented, BeatType.Accented, BeatType.Unaccented],
        polyBeats: [],
        noteKey: NoteValues.eighth,
      );

    case NoteValues.sixteenth:
      return RhythmPreset(
        beats: List.generate(8, (i) => i % 4 == 0 ? BeatType.Accented : BeatType.Unaccented),
        polyBeats: [],
        noteKey: NoteValues.sixteenth,
      );

    case NoteValues.eighthDotted:
      return RhythmPreset(
        beats: [BeatType.Accented, BeatType.Unaccented, BeatType.Unaccented],
        polyBeats: [],
        noteKey: NoteValues.eighthDotted,
      );

    case NoteValues.tuplet3Quarter:
      return RhythmPreset(
        beats: [BeatType.Accented, BeatType.Unaccented, BeatType.Unaccented],
        polyBeats: [],
        noteKey: NoteValues.tuplet3Quarter,
      );

    default:
      return RhythmPreset(
        beats: [BeatType.Accented, BeatType.Unaccented, BeatType.Unaccented, BeatType.Unaccented],
        polyBeats: [],
        noteKey: NoteValues.quarter,
      );
  }
}
