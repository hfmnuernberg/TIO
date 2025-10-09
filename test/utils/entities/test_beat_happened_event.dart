import 'package:tiomusic/src/rust/api/modules/metronome.dart';

extension TestBeatHappenedEvent on BeatHappenedEvent {
  static BeatHappenedEvent make({
    int millisecondsBeforeStart = 0,
    int barIndex = 0,
    int beatIndex = 0,
    bool isPoly = false,
    bool isRandomMute = false,
    bool isSecondary = false,
  }) => BeatHappenedEvent(
    millisecondsBeforeStart: millisecondsBeforeStart,
    barIndex: barIndex,
    beatIndex: beatIndex,
    isPoly: isPoly,
    isRandomMute: isRandomMute,
    isSecondary: isSecondary,
  );
}
