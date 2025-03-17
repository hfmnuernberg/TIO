import 'package:flutter_test/flutter_test.dart';
import 'package:tiomusic/pages/metronome/metronome.dart';
import 'package:tiomusic/util/constants.dart';

void main() {
  group('metronome functions', () {
    group('calcMsUntilNextFlashOn', () {
      test('calculates zero when all arguments are zero', () {
        expect(calcMsUntilNextFlashOn(timestamp: 0, eventTimestamp: 0, eventDelayInMs: 0, avgRenderTimeInMs: 0), 0);
      });

      test('schedules next flash when event is due', () {
        expect(calcMsUntilNextFlashOn(timestamp: 0, eventTimestamp: 50, eventDelayInMs: 0, avgRenderTimeInMs: 0), 50);
        expect(calcMsUntilNextFlashOn(timestamp: 50, eventTimestamp: 50, eventDelayInMs: 0, avgRenderTimeInMs: 0), 0);
        expect(calcMsUntilNextFlashOn(timestamp: 50, eventTimestamp: 100, eventDelayInMs: 0, avgRenderTimeInMs: 0), 50);
      });

      test('considers event delay', () {
        expect(calcMsUntilNextFlashOn(timestamp: 0, eventTimestamp: 0, eventDelayInMs: 50, avgRenderTimeInMs: 0), 50);
        expect(
          calcMsUntilNextFlashOn(timestamp: 50, eventTimestamp: 100, eventDelayInMs: 25, avgRenderTimeInMs: 0),
          75,
        );
      });

      test('considers average render time', () {
        expect(calcMsUntilNextFlashOn(timestamp: 0, eventTimestamp: 100, eventDelayInMs: 0, avgRenderTimeInMs: 50), 50);
        expect(
          calcMsUntilNextFlashOn(timestamp: 50, eventTimestamp: 100, eventDelayInMs: 50, avgRenderTimeInMs: 25),
          75,
        );
      });

      test('never schedules next flash in the past', () {
        expect(calcMsUntilNextFlashOn(timestamp: 50, eventTimestamp: 0, eventDelayInMs: 0, avgRenderTimeInMs: 0), 0);
        expect(calcMsUntilNextFlashOn(timestamp: 0, eventTimestamp: 0, eventDelayInMs: 0, avgRenderTimeInMs: 50), 0);
        expect(calcMsUntilNextFlashOn(timestamp: 0, eventTimestamp: 0, eventDelayInMs: 25, avgRenderTimeInMs: 50), 0);
      });
    });

    group('calcMsUntilNextFlashOff', () {
      test('schedules flash off after flash duration has passed', () {
        expect(calcMsUntilNextFlashOff(msUntilNextFlashOn: 0), MetronomeParams.flashDurationInMs);
        expect(calcMsUntilNextFlashOff(msUntilNextFlashOn: 50), MetronomeParams.flashDurationInMs + 50);
      });
    });
  });
}
