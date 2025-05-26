import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiomusic/src/rust/api/modules/metronome_rhythm.dart';
import 'package:tiomusic/widgets/metronome/set_rhythm_parameters_simple.dart';
import 'package:tiomusic/widgets/metronome/rhythm_preset.dart';

void main() {
  group('metronome rhythm functions', () {
    group('getIconForNoteKey', () {
      test('returns icon when given key is valid', () {
        expect(getIconForNoteKey('1'), Icons.looks_one);
        expect(getIconForNoteKey('2'), Icons.looks_two);
      });

      test('returns default icon when given key is invalid', () {
        expect(getIconForNoteKey('0'), Icons.music_note);
      });
    });

    group('matchesPreset', () {
      final validPreset = RhythmPreset(
        beats: [BeatType.Accented, BeatType.Unaccented],
        polyBeats: [BeatTypePoly.Muted, BeatTypePoly.Unaccented],
        noteKey: '1',
      );

      test('returns true when given preset matches other given values', () {
        expect(matchesPreset(validPreset, validPreset.beats, validPreset.polyBeats, validPreset.noteKey), true);
      });

      test('returns false when given preset does not match given beats', () {
        expect(matchesPreset(validPreset, [], validPreset.polyBeats, validPreset.noteKey), false);
      });

      test('returns false when given preset does not match given poly beats', () {
        expect(matchesPreset(validPreset, validPreset.beats, [], validPreset.noteKey), false);
      });

      test('returns false when given preset does not match given note key', () {
        expect(matchesPreset(validPreset, validPreset.beats, validPreset.polyBeats, '0'), false);
      });
    });
  });
}
