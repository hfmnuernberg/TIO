import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiomusic/widgets/piano/key_note.dart';
import 'package:tiomusic/widgets/piano/keyboard.dart';

void main() {
  group('keyboard', () {
    group('createNaturals', () {
      test('creates 12 notes', () {
        expect(Keyboard.createNaturals(60).length, 12);
        expect(Keyboard.createNaturals(61).length, 12);
        expect(Keyboard.createNaturals(80).length, 12);
      });

      test('creates only naturals', () {
        expect(Keyboard.createNaturals(60).every((note) => note.isNatural), true);
      });

      test('starts with lowest natural', () {
        expect(Keyboard.createNaturals(60).first, KeyNote(note: 60, name: 'C4', isNatural: true));
        expect(Keyboard.createNaturals(61).first, KeyNote(note: 62, name: 'D4', isNatural: true));
        expect(Keyboard.createNaturals(80).first, KeyNote(note: 81, name: 'A5', isNatural: true));
      });

      test('creates consecutive naturals', () {
        final notes = Keyboard.createNaturals(48);
        expect(notes[0], KeyNote(note: 48, name: 'C3', isNatural: true));
        expect(notes[1], KeyNote(note: 50, name: 'D3', isNatural: true));
        expect(notes[2], KeyNote(note: 52, name: 'E3', isNatural: true));
      });
    });

    group('createSharps', () {
      test('creates 7 or 8 notes', () {
        expect(Keyboard.createSharps(60).length, 8);
        expect(Keyboard.createSharps(61).length, 8);
        expect(Keyboard.createSharps(70).length, 7);
      });

      test('creates only sharps', () {
        expect(Keyboard.createSharps(60).none((note) => note.isNatural), true);
      });

      test('starts with lowest sharp', () {
        expect(Keyboard.createSharps(60).first, KeyNote(note: 61, name: 'C♯4', isNatural: false));
        expect(Keyboard.createSharps(61).first, KeyNote(note: 63, name: 'D♯4', isNatural: false));
        expect(Keyboard.createSharps(70).first, KeyNote(note: 73, name: 'C♯5', isNatural: false));
      });

      test('creates consecutive sharps', () {
        final notes = Keyboard.createSharps(48);
        expect(notes[0], KeyNote(note: 49, name: 'C♯3', isNatural: false));
        expect(notes[1], KeyNote(note: 51, name: 'D♯3', isNatural: false));
        expect(notes[2], KeyNote(note: 54, name: 'F♯3', isNatural: false));
      });
    });

    group('createSharpsWithSpacing', () {
      test('creates 11 notes or gaps', () {
        expect(Keyboard.createSharpsWithSpacing(60).length, 11);
        expect(Keyboard.createSharpsWithSpacing(61).length, 11);
        expect(Keyboard.createSharpsWithSpacing(70).length, 11);
      });

      test('creates no naturals', () {
        expect(Keyboard.createSharpsWithSpacing(60).none((note) => note?.isNatural ?? false), true);
      });

      test('starts with lowest sharp', () {
        expect(Keyboard.createSharpsWithSpacing(60).first, KeyNote(note: 61, name: 'C♯4', isNatural: false));
        expect(Keyboard.createSharpsWithSpacing(61).first, KeyNote(note: 63, name: 'D♯4', isNatural: false));
        expect(Keyboard.createSharpsWithSpacing(70).first, null);
      });

      test('creates consecutive sharps with null where there is only a natural', () {
        final notes = Keyboard.createSharpsWithSpacing(48);
        expect(notes[0], KeyNote(note: 49, name: 'C♯3', isNatural: false));
        expect(notes[1], KeyNote(note: 51, name: 'D♯3', isNatural: false));
        expect(notes[2], null);
      });
    });

    group('createNotes', () {
      test('creates all notes of octave', () {
        final notes = Keyboard.createNotes(60);
        expect(notes.first, KeyNote(note: 60, name: 'C4', isNatural: true));
        expect(notes[1], KeyNote(note: 61, name: 'C♯4', isNatural: false));
        expect(notes.last, KeyNote(note: 79, name: 'G5', isNatural: true));
      });
    });
  });
}
