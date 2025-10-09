import 'package:tiomusic/src/rust/api/modules/metronome_rhythm.dart';

extension TestMetroBar on MetroBar {
  static MetroBar make({
    int id = 0,
    List<BeatType> beats = const [],
    List<BeatTypePoly> polyBeats = const [],
    double beatLen = 1.0,
  }) => MetroBar(id: id, beats: beats, polyBeats: polyBeats, beatLen: beatLen);
}
