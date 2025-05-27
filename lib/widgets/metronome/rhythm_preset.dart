import 'package:equatable/equatable.dart';
import 'package:tiomusic/models/note_handler.dart';
import 'package:tiomusic/src/rust/api/modules/metronome_rhythm.dart';

const oneFourth = '1_4th';
const twoEighth = '2_8th';
const fourSixteenth = '4_16th';

class RhythmPreset extends Equatable {
  final List<BeatType> beats;
  final List<BeatTypePoly> polyBeats;
  final String noteKey;

  const RhythmPreset({required this.beats, required this.polyBeats, required this.noteKey});

  @override
  List<Object> get props => [beats, polyBeats, noteKey];
}

List<BeatTypePoly> _repeatPolyBeatPattern(int repetitions, List<BeatTypePoly> pattern) {
  return List.generate(repetitions, (_) => pattern).expand((e) => e).toList();
}

RhythmPreset getPresetRhythmPattern(String? noteKey) {
  switch (noteKey) {
    case oneFourth:
      return RhythmPreset(
        beats: const [BeatType.Accented, BeatType.Unaccented, BeatType.Unaccented, BeatType.Unaccented],
        polyBeats: const [],
        noteKey: NoteValues.quarter,
      );
    case twoEighth:
      return RhythmPreset(
        beats: const [BeatType.Accented, BeatType.Unaccented, BeatType.Unaccented, BeatType.Unaccented],
        polyBeats: _repeatPolyBeatPattern(4, [BeatTypePoly.Muted, BeatTypePoly.Unaccented]),
        noteKey: NoteValues.quarter,
      );
    case fourSixteenth:
      return RhythmPreset(
        beats: const [BeatType.Accented, BeatType.Unaccented, BeatType.Unaccented, BeatType.Unaccented],
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
        beats: const [BeatType.Accented, BeatType.Unaccented, BeatType.Unaccented, BeatType.Unaccented],
        polyBeats: const [],
        noteKey: NoteValues.quarter,
      );
  }
}
