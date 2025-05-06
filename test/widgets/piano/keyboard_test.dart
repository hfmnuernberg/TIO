import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiomusic/widgets/piano/keyboard.dart';
import 'package:tiomusic/widgets/piano/note.dart';

void main() {
  group('keyboard', () {
    group('createNaturals', () {
      test('creates 12 notes', () {
        expect(Keyboard.createNaturals(60, {}).length, 12);
        expect(Keyboard.createNaturals(61, {}).length, 12);
        expect(Keyboard.createNaturals(80, {}).length, 12);
      });

      test('creates only naturals', () {
        expect(Keyboard.createNaturals(60, {}).every((note) => note.isNatural), true);
      });

      test('starts with lowest natural', () {
        expect(Keyboard.createNaturals(60, {}).first, Note(note: 60, name: 'C4', isNatural: true, isPlayed: false));
        expect(Keyboard.createNaturals(61, {}).first, Note(note: 62, name: 'D4', isNatural: true, isPlayed: false));
        expect(Keyboard.createNaturals(80, {}).first, Note(note: 81, name: 'A5', isNatural: true, isPlayed: false));
      });

      test('creates consecutive naturals', () {
        final notes = Keyboard.createNaturals(48, {});
        expect(notes[0], Note(note: 48, name: 'C3', isNatural: true, isPlayed: false));
        expect(notes[1], Note(note: 50, name: 'D3', isNatural: true, isPlayed: false));
        expect(notes[2], Note(note: 52, name: 'E3', isNatural: true, isPlayed: false));
      });

      test('marks naturals as played', () {
        final notes = Keyboard.createNaturals(60, {62});
        expect(notes[0], Note(note: 60, name: 'C4', isNatural: true, isPlayed: false));
        expect(notes[1], Note(note: 62, name: 'D4', isNatural: true, isPlayed: true));
        expect(notes[2], Note(note: 64, name: 'E4', isNatural: true, isPlayed: false));
      });
    });

    group('createSharps', () {
      test('creates 7 or 8 notes', () {
        expect(Keyboard.createSharps(60, {}).length, 8);
        expect(Keyboard.createSharps(61, {}).length, 8);
        expect(Keyboard.createSharps(70, {}).length, 7);
      });

      test('creates only sharps', () {
        expect(Keyboard.createSharps(60, {}).none((note) => note.isNatural), true);
      });

      test('starts with lowest sharp', () {
        expect(Keyboard.createSharps(60, {}).first, Note(note: 61, name: 'C♯4', isNatural: false, isPlayed: false));
        expect(Keyboard.createSharps(61, {}).first, Note(note: 63, name: 'D♯4', isNatural: false, isPlayed: false));
        expect(Keyboard.createSharps(70, {}).first, Note(note: 73, name: 'C♯5', isNatural: false, isPlayed: false));
      });

      test('creates consecutive sharps', () {
        final notes = Keyboard.createSharps(48, {});
        expect(notes[0], Note(note: 49, name: 'C♯3', isNatural: false, isPlayed: false));
        expect(notes[1], Note(note: 51, name: 'D♯3', isNatural: false, isPlayed: false));
        expect(notes[2], Note(note: 54, name: 'F♯3', isNatural: false, isPlayed: false));
      });

      test('marks sharps as played', () {
        final notes = Keyboard.createSharps(60, {63});
        expect(notes[0], Note(note: 61, name: 'C♯4', isNatural: false, isPlayed: false));
        expect(notes[1], Note(note: 63, name: 'D♯4', isNatural: false, isPlayed: true));
        expect(notes[2], Note(note: 66, name: 'F♯4', isNatural: false, isPlayed: false));
      });
    });

    group('createSharpsWithSpacing', () {
      test('creates 11 notes or gaps', () {
        expect(Keyboard.createSharpsWithSpacing(60, {}).length, 11);
        expect(Keyboard.createSharpsWithSpacing(61, {}).length, 11);
        expect(Keyboard.createSharpsWithSpacing(70, {}).length, 11);
      });

      test('creates no naturals', () {
        expect(Keyboard.createSharpsWithSpacing(60, {}).none((note) => note?.isNatural ?? false), true);
      });

      test('starts with lowest sharp', () {
        expect(
          Keyboard.createSharpsWithSpacing(60, {}).first,
          Note(note: 61, name: 'C♯4', isNatural: false, isPlayed: false),
        );
        expect(
          Keyboard.createSharpsWithSpacing(61, {}).first,
          Note(note: 63, name: 'D♯4', isNatural: false, isPlayed: false),
        );
        expect(Keyboard.createSharpsWithSpacing(70, {}).first, null);
      });

      test('creates consecutive sharps with null where there is only a natural', () {
        final notes = Keyboard.createSharpsWithSpacing(48, {});
        expect(notes[0], Note(note: 49, name: 'C♯3', isNatural: false, isPlayed: false));
        expect(notes[1], Note(note: 51, name: 'D♯3', isNatural: false, isPlayed: false));
        expect(notes[2], null);
      });

      test('marks sharps as played', () {
        final notes = Keyboard.createSharpsWithSpacing(60, {63});
        expect(notes[0], Note(note: 61, name: 'C♯4', isNatural: false, isPlayed: false));
        expect(notes[1], Note(note: 63, name: 'D♯4', isNatural: false, isPlayed: true));
        expect(notes[2], null);
      });
    });

    group('createNotes', () {
      test('creates all notes of octave', () {
        final notes = Keyboard.createNotes(60, {});
        expect(notes.first, Note(note: 60, name: 'C4', isNatural: true, isPlayed: false));
        expect(notes[1], Note(note: 61, name: 'C♯4', isNatural: false, isPlayed: false));
        expect(notes.last, Note(note: 79, name: 'G5', isNatural: true, isPlayed: false));
      });
    });
  });
}
