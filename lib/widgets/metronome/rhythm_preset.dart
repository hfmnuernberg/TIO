import 'package:tiomusic/models/note_handler.dart';
import 'package:tiomusic/src/rust/api/modules/metronome_rhythm.dart';

class RhythmPreset {
  final List<BeatType> beats;
  final List<BeatTypePoly> polyBeats;
  final String noteKey;

  RhythmPreset({required this.beats, required this.polyBeats, required this.noteKey});
}

List<BeatTypePoly> repeatPolyBeatPattern(int repetitions, List<BeatTypePoly> pattern) {
  return List.generate(repetitions, (_) => pattern).expand((e) => e).toList();
}

RhythmPreset getPresetRhythmPattern(String? noteKey) {
  switch (noteKey) {
    case '1':
      // Quarter, all beats equal
      return RhythmPreset(
        beats: [BeatType.Unaccented, BeatType.Unaccented, BeatType.Unaccented, BeatType.Unaccented],
        polyBeats: [],
        noteKey: NoteValues.quarter,
      );
    case '2':
      // Quarter, beat 1 omitted
      return RhythmPreset(
        beats: [BeatType.Accented, BeatType.Unaccented, BeatType.Unaccented, BeatType.Unaccented],
        polyBeats: [],
        noteKey: NoteValues.quarter,
      );
    case '3':
      // 2/8, all beats equal
      return RhythmPreset(
        beats: [BeatType.Unaccented, BeatType.Unaccented, BeatType.Unaccented, BeatType.Unaccented],
        polyBeats: repeatPolyBeatPattern(4, [BeatTypePoly.Muted, BeatTypePoly.Unaccented]),
        noteKey: NoteValues.quarter,
      );
    case '4':
      // 2/8, beat 1 omitted
      return RhythmPreset(
        beats: [BeatType.Accented, BeatType.Unaccented, BeatType.Unaccented, BeatType.Unaccented],
        polyBeats: repeatPolyBeatPattern(4, [BeatTypePoly.Muted, BeatTypePoly.Unaccented]),
        noteKey: NoteValues.quarter,
      );
    case '5':
      // Eighth note rest with eighth note, all beats equal
      return RhythmPreset(
        beats: [BeatType.Muted, BeatType.Muted, BeatType.Muted, BeatType.Muted],
        polyBeats: repeatPolyBeatPattern(4, [BeatTypePoly.Muted, BeatTypePoly.Unaccented]),
        noteKey: NoteValues.quarter,
      );
    case '6':
      // Eighth note rest with eighth note, beat 1 omitted
      return RhythmPreset(
        beats: [BeatType.Accented, BeatType.Muted, BeatType.Muted, BeatType.Muted],
        polyBeats: repeatPolyBeatPattern(4, [BeatTypePoly.Muted, BeatTypePoly.Unaccented]),
        noteKey: NoteValues.quarter,
      );
    case '7':
      // Dotted eighth note with sixteenth note, all beats equal
      return RhythmPreset(
        beats: [BeatType.Unaccented, BeatType.Unaccented, BeatType.Unaccented, BeatType.Unaccented],
        polyBeats: repeatPolyBeatPattern(4, [
          BeatTypePoly.Muted,
          BeatTypePoly.Muted,
          BeatTypePoly.Muted,
          BeatTypePoly.Unaccented,
        ]),
        noteKey: NoteValues.quarter,
      );
    case '8':
      // Dotted eighth note with sixteenth note, beat 1 omitted
      return RhythmPreset(
        beats: [BeatType.Accented, BeatType.Unaccented, BeatType.Unaccented, BeatType.Unaccented],
        polyBeats: repeatPolyBeatPattern(4, [
          BeatTypePoly.Muted,
          BeatTypePoly.Muted,
          BeatTypePoly.Muted,
          BeatTypePoly.Unaccented,
        ]),
        noteKey: NoteValues.quarter,
      );
    case '9':
      // Sixteenth note with dotted eighth note, all beats equal
      return RhythmPreset(
        beats: [BeatType.Unaccented, BeatType.Unaccented, BeatType.Unaccented, BeatType.Unaccented],
        polyBeats: repeatPolyBeatPattern(4, [
          BeatTypePoly.Muted,
          BeatTypePoly.Unaccented,
          BeatTypePoly.Muted,
          BeatTypePoly.Muted,
        ]),
        noteKey: NoteValues.quarter,
      );
    case '10':
      // Sixteenth note with dotted eighth note, beat 1 omitted
      return RhythmPreset(
        beats: [BeatType.Accented, BeatType.Unaccented, BeatType.Unaccented, BeatType.Unaccented],
        polyBeats: repeatPolyBeatPattern(4, [
          BeatTypePoly.Muted,
          BeatTypePoly.Unaccented,
          BeatTypePoly.Muted,
          BeatTypePoly.Muted,
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
