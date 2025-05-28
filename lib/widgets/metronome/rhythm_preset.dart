import 'package:equatable/equatable.dart';
import 'package:tiomusic/models/note_handler.dart';
import 'package:tiomusic/src/rust/api/modules/metronome_rhythm.dart';

enum RhythmPresetKey {
  oneFourth('1_4th'),
  twoEighth('2_8th'),
  fourSixteenth('4_16th');

  final String assetName;
  const RhythmPresetKey(this.assetName);
}

class RhythmPreset extends Equatable {
  final List<BeatType> beats;
  final List<BeatTypePoly> polyBeats;
  final String noteKey;

  const RhythmPreset({required this.beats, required this.polyBeats, required this.noteKey});

  static final RhythmPreset oneFourth = RhythmPreset(
    beats: const [BeatType.Accented, BeatType.Unaccented, BeatType.Unaccented, BeatType.Unaccented],
    polyBeats: const [],
    noteKey: NoteValues.quarter,
  );

  static final RhythmPreset twoEighth = RhythmPreset(
    beats: const [BeatType.Accented, BeatType.Unaccented, BeatType.Unaccented, BeatType.Unaccented],
    polyBeats: _repeatPolyBeatPattern(4, [BeatTypePoly.Muted, BeatTypePoly.Unaccented]),
    noteKey: NoteValues.quarter,
  );

  static final RhythmPreset fourSixteenth = RhythmPreset(
    beats: const [BeatType.Accented, BeatType.Unaccented, BeatType.Unaccented, BeatType.Unaccented],
    polyBeats: _repeatPolyBeatPattern(4, [
      BeatTypePoly.Muted,
      BeatTypePoly.Unaccented,
      BeatTypePoly.Unaccented,
      BeatTypePoly.Unaccented,
    ]),
    noteKey: NoteValues.quarter,
  );

  static RhythmPreset fromKey(RhythmPresetKey key) => switch (key) {
    RhythmPresetKey.oneFourth => oneFourth.copy(),
    RhythmPresetKey.twoEighth => twoEighth.copy(),
    RhythmPresetKey.fourSixteenth => fourSixteenth.copy(),
  };

  RhythmPreset copy() => RhythmPreset(
    beats: List.from(beats),
    polyBeats: List.from(polyBeats),
    noteKey: noteKey,
  );

  @override
  List<Object> get props => [beats, polyBeats, noteKey];
}

List<BeatTypePoly> _repeatPolyBeatPattern(int repetitions, List<BeatTypePoly> pattern) {
  return List.generate(repetitions, (_) => pattern).expand((e) => e).toList();
}
