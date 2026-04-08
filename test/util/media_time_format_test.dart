import 'package:flutter_test/flutter_test.dart';
import 'package:tiomusic/util/media_time_format.dart';

void main() {
  group('formatMediaDuration - sub-minute', () {
    test('zero', () => expect(formatMediaDuration(Duration.zero), '0.000'));
    test('500ms', () => expect(formatMediaDuration(const Duration(milliseconds: 500)), '0.500'));
    test('42s 123ms', () {
      expect(formatMediaDuration(const Duration(seconds: 42, milliseconds: 123)), '42.123');
    });
    test('59.999s', () {
      expect(formatMediaDuration(const Duration(seconds: 59, milliseconds: 999)), '59.999');
    });
  });

  group('formatMediaDuration - minutes', () {
    test('exactly 1m', () => expect(formatMediaDuration(const Duration(minutes: 1)), '1:00.000'));
    test('2m 5s 7ms', () {
      expect(formatMediaDuration(const Duration(minutes: 2, seconds: 5, milliseconds: 7)), '2:05.007');
    });
    test('12m 34s 567ms', () {
      expect(formatMediaDuration(const Duration(minutes: 12, seconds: 34, milliseconds: 567)), '12:34.567');
    });
    test('59m 59.999s', () {
      expect(formatMediaDuration(const Duration(minutes: 59, seconds: 59, milliseconds: 999)), '59:59.999');
    });
  });

  group('formatMediaDuration - hours', () {
    test('exactly 1h', () => expect(formatMediaDuration(const Duration(hours: 1)), '1:00:00.000'));
    test('1h 23m 45s 678ms', () {
      expect(formatMediaDuration(const Duration(hours: 1, minutes: 23, seconds: 45, milliseconds: 678)), '1:23:45.678');
    });
    test('keeps milliseconds at hour scale', () {
      expect(formatMediaDuration(const Duration(hours: 2, milliseconds: 1)), '2:00:00.001');
    });
    test('10h', () => expect(formatMediaDuration(const Duration(hours: 10)), '10:00:00.000'));
  });

  group('formatMediaDuration - edge cases', () {
    test('negative duration clamps to zero', () {
      expect(formatMediaDuration(const Duration(seconds: -5)), '0.000');
    });
    test('just below 1 minute uses sub-minute format', () {
      expect(formatMediaDuration(const Duration(seconds: 59, milliseconds: 999)), '59.999');
    });
    test('just below 1 hour uses minute format', () {
      expect(formatMediaDuration(const Duration(minutes: 59, seconds: 59, milliseconds: 999)), '59:59.999');
    });
  });
}
