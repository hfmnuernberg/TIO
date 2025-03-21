import 'package:flutter_test/flutter_test.dart';
import 'package:tiomusic/pages/metronome/metronome.dart';
import 'package:tiomusic/util/constants.dart';

void main() {
  group('metronome functions', () {
    group('calcMsUntilNextFlashOn', () {
      test('calculates zero when all arguments are zero', () {
        expect(calcMsUntilNextFlashOn(0, 0), 0);
      });

      test('schedules next flash when event is due', () {
        expect(calcMsUntilNextFlashOn(50, 0), 50);
      });

      test('considers average render time', () {
        expect(calcMsUntilNextFlashOn(0, 50), 50);
        expect(calcMsUntilNextFlashOn(50, 25), 75);
      });
    });

    group('calcMsUntilNextFlashOff', () {
      test('schedules flash off after flash duration has passed', () {
        expect(calcMsUntilNextFlashOff(0), MetronomeParams.flashDurationInMs);
        expect(calcMsUntilNextFlashOff(50), MetronomeParams.flashDurationInMs + 50);
      });
    });
  });
}
