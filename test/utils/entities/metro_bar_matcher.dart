import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiomusic/src/rust/api/modules/metronome_rhythm.dart';

Matcher metroBarEquals(MetroBar expected) => predicate<MetroBar>(
  (actual) =>
      actual.id == expected.id &&
      ListEquality().equals(actual.beats, expected.beats) &&
      ListEquality().equals(actual.polyBeats, expected.polyBeats) &&
      actual.beatLen == expected.beatLen,
  'MetroBar equals $expected',
);

Matcher metroBarListEquals(List<MetroBar> expected) => predicate<List<MetroBar>>((actual) {
  if (actual.length != expected.length) return false;
  for (var i = 0; i < actual.length; i++) {
    final a = actual[i];
    final b = expected[i];
    if (!(a.id == b.id &&
        ListEquality().equals(a.beats, b.beats) &&
        ListEquality().equals(a.polyBeats, b.polyBeats) &&
        a.beatLen == b.beatLen)) {
      return false;
    }
  }
  return true;
}, 'List<MetroBar> equals $expected');
