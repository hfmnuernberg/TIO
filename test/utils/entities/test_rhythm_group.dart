import 'package:tiomusic/models/rhythm_group.dart';
import 'package:tiomusic/src/rust/api/modules/metronome_rhythm.dart';

extension TestRhythmGroup on RhythmGroup {
  static RhythmGroup make({
    String keyID = '0',
    List<BeatType> beats = const [],
    List<BeatTypePoly> polyBeats = const [],
    String noteKey = 'e4',
  }) => RhythmGroup(keyID, beats, polyBeats, noteKey);
}
