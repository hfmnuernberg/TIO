import 'package:mocktail/mocktail.dart';
import 'package:tiomusic/domain/metronome/metronome_beat_event.dart';

class BeatHandlerMock extends Mock {
  BeatHandlerMock() {
    registerFallbackValue(MetronomeBeatEvent());
  }

  void onBeatEvent(MetronomeBeatEvent beat);
  void onBeatStartEvent(MetronomeBeatEvent beat);
  void onBeatStopEvent(MetronomeBeatEvent beat);

  void verifyOnBeatCalled(MetronomeBeatEvent beat) => verify(() => onBeatEvent(beat)).called(1);
  void verifyOnBeatNeverCalled() => verifyNever(() => onBeatEvent(any()));

  void verifyOnBeatStartCalled(MetronomeBeatEvent beat) => verify(() => onBeatStartEvent(beat)).called(1);
  void verifyOnBeatStartNeverCalled() => verifyNever(() => onBeatStartEvent(any()));

  void verifyOnBeatStopCalled(MetronomeBeatEvent beat) => verify(() => onBeatStopEvent(beat)).called(1);
  void verifyOnBeatStopNeverCalled() => verifyNever(() => onBeatStopEvent(any()));
}
