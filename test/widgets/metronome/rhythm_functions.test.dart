import 'package:flutter_test/flutter_test.dart';
import 'package:tiomusic/pages/metronome/rhythm/rhythm_functions.dart';

void main() {
  group('rhythm functions', () {
    group('getIncrementStepForPolyBeat', () {
      test('increment step is always one when beat count is one', () {
        expect(getIncrementStepForPolyBeat(1, 1), 1);
        expect(getIncrementStepForPolyBeat(1, 2), 1);
      });

      test('increment step is equal to beat count when poly beat count equal to beat count', () {
        expect(getIncrementStepForPolyBeat(1, 1), 1);
        expect(getIncrementStepForPolyBeat(2, 2), 2);
      });

      test('increment step is equal to beat count when poly beat count is larger than beat count', () {
        expect(getIncrementStepForPolyBeat(2, 4), 2);
        expect(getIncrementStepForPolyBeat(3, 9), 3);
      });

      test('increment step is half of beat count when poly beat count is half of beat count', () {
        expect(getIncrementStepForPolyBeat(4, 2), 2);
        expect(getIncrementStepForPolyBeat(6, 3), 3);
      });

      test(
        'increment step is difference to next multiple of beat count when beat count is higher than poly beat count',
        () {
          expect(getIncrementStepForPolyBeat(5, 1), 4);
          expect(getIncrementStepForPolyBeat(12, 3), 1);
          expect(getIncrementStepForPolyBeat(12, 6), 6);
        },
      );

      test('increment step is one when poly beat count is zero', () {
        expect(getIncrementStepForPolyBeat(1, 0), 1);
        expect(getIncrementStepForPolyBeat(3, 0), 1);
      });
    });

    group('getDecrementStepForPolyBeat', () {
      test('decrement step is always one when beat count is one', () {
        expect(getDecrementStepForPolyBeat(1, 1), 1);
        expect(getDecrementStepForPolyBeat(1, 2), 1);
      });

      test('decrement step is equal to beat count when poly beat count is larger than beat count', () {
        expect(getDecrementStepForPolyBeat(2, 4), 2);
        expect(getDecrementStepForPolyBeat(3, 9), 3);
      });

      test('decrement step is half of poly beat count when beat count is half of poly beat count', () {
        expect(getDecrementStepForPolyBeat(2, 4), 2);
        expect(getDecrementStepForPolyBeat(3, 6), 3);
      });

      test(
        'decrement step is difference to previous multiple of beat count when poly beat count equal to beat count',
        () {
          expect(getDecrementStepForPolyBeat(5, 5), 4);
          expect(getDecrementStepForPolyBeat(8, 8), 4);
          expect(getDecrementStepForPolyBeat(9, 9), 6);
        },
      );

      test(
        'decrement step is difference to previous multiple of beat count when beat count is higher than poly beat count',
        () {
          expect(getDecrementStepForPolyBeat(5, 1), 1);
          expect(getDecrementStepForPolyBeat(12, 3), 1);
          expect(getDecrementStepForPolyBeat(12, 6), 2);
        },
      );

      test('decrement step is zero when poly beat count is zero', () {
        expect(getDecrementStepForPolyBeat(1, 0), 0);
        expect(getDecrementStepForPolyBeat(3, 0), 0);
      });
    });
  });
}
