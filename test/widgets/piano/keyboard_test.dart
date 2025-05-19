import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/widgets/piano/key_note.dart';
import 'package:tiomusic/widgets/piano/keyboard.dart';
import 'package:tiomusic/widgets/piano/keyboard_utils.dart';

import '../../utils/render_utils.dart';

const keyboardWidth = 10.0 * PianoParams.numberOfWhiteKeys;
const keyboardHeight = 100.0;

const c4 = 60;
const cSharp4 = 61;
const d4 = 62;
const dSharp4 = 63;

const whiteKey1 = Offset(5, 75);
const whiteKey2 = Offset(15, 75);

const blackKey1 = Offset(10, 25);
const blackKey2 = Offset(20, 25);

class PianoMock extends Mock {
  void onPlay(int note);
  void onRelease(int note);

  void verifyKeyPlayed(int note) => verify(() => onPlay(note)).called(1);
  void verifyKeyReleased(int note) => verify(() => onRelease(note)).called(1);

  void verifyKeyNeverPlayed(int note) => verifyNever(() => onPlay(note));
  void verifyKeyNeverReleased(int note) => verifyNever(() => onRelease(note));

  void verifyNoKeysPlayed() => verifyNever(() => onPlay(any()));
  void verifyNoKeysReleased() => verifyNever(() => onRelease(any()));
}

extension WidgetTesterRenderExtension on WidgetTester {
  Future<PianoMock> renderKeyboard() async {
    final pianoMock = PianoMock();
    await renderWidget(
      SizedBox(
        width: keyboardWidth,
        height: keyboardHeight,
        child: Keyboard(lowestNote: 60, onPlay: pianoMock.onPlay, onRelease: pianoMock.onRelease),
      ),
    );
    return pianoMock;
  }
}

void main() {
  group('keyboard', () {
    group('createNaturals', () {
      test('creates 12 notes', () {
        expect(createNaturals(60).length, 12);
        expect(createNaturals(61).length, 12);
        expect(createNaturals(80).length, 12);
      });

      test('creates only naturals', () {
        expect(createNaturals(60).every((note) => note.isNatural), true);
      });

      test('starts with lowest natural', () {
        expect(createNaturals(60).first, KeyNote(note: 60, name: 'C4', isNatural: true));
        expect(createNaturals(61).first, KeyNote(note: 62, name: 'D4', isNatural: true));
        expect(createNaturals(80).first, KeyNote(note: 81, name: 'A5', isNatural: true));
      });

      test('creates consecutive naturals', () {
        final notes = createNaturals(48);
        expect(notes[0], KeyNote(note: 48, name: 'C3', isNatural: true));
        expect(notes[1], KeyNote(note: 50, name: 'D3', isNatural: true));
        expect(notes[2], KeyNote(note: 52, name: 'E3', isNatural: true));
      });
    });

    group('createSharps', () {
      test('creates 7 or 8 notes', () {
        expect(createSharps(60).length, 8);
        expect(createSharps(61).length, 8);
        expect(createSharps(70).length, 7);
      });

      test('creates only sharps', () {
        expect(createSharps(60).none((note) => note.isNatural), true);
      });

      test('starts with lowest sharp', () {
        expect(createSharps(60).first, KeyNote(note: 61, name: 'C♯4', isNatural: false));
        expect(createSharps(61).first, KeyNote(note: 63, name: 'D♯4', isNatural: false));
        expect(createSharps(70).first, KeyNote(note: 73, name: 'C♯5', isNatural: false));
      });

      test('creates consecutive sharps', () {
        final notes = createSharps(48);
        expect(notes[0], KeyNote(note: 49, name: 'C♯3', isNatural: false));
        expect(notes[1], KeyNote(note: 51, name: 'D♯3', isNatural: false));
        expect(notes[2], KeyNote(note: 54, name: 'F♯3', isNatural: false));
      });
    });

    group('createSharpsWithSpacing', () {
      test('creates 11 notes or gaps', () {
        expect(createSharpsWithSpacing(60).length, 11);
        expect(createSharpsWithSpacing(61).length, 11);
        expect(createSharpsWithSpacing(70).length, 11);
      });

      test('creates no naturals', () {
        expect(createSharpsWithSpacing(60).none((note) => note?.isNatural ?? false), true);
      });

      test('starts with lowest sharp', () {
        expect(createSharpsWithSpacing(60).first, KeyNote(note: 61, name: 'C♯4', isNatural: false));
        expect(createSharpsWithSpacing(61).first, KeyNote(note: 63, name: 'D♯4', isNatural: false));
        expect(createSharpsWithSpacing(70).first, null);
      });

      test('creates consecutive sharps with null where there is only a natural', () {
        final notes = createSharpsWithSpacing(48);
        expect(notes[0], KeyNote(note: 49, name: 'C♯3', isNatural: false));
        expect(notes[1], KeyNote(note: 51, name: 'D♯3', isNatural: false));
        expect(notes[2], null);
      });
    });

    group('createNotes', () {
      test('creates all notes of octave', () {
        final notes = createNotes(60);
        expect(notes.first, KeyNote(note: 60, name: 'C4', isNatural: true));
        expect(notes[1], KeyNote(note: 61, name: 'C♯4', isNatural: false));
        expect(notes.last, KeyNote(note: 79, name: 'G5', isNatural: true));
      });
    });

    group('playing single white keys', () {
      testWidgets('plays and holds white key', (tester) async {
        final pianoMock = await tester.renderKeyboard();

        await tester.startGesture(whiteKey1);

        pianoMock.verifyKeyPlayed(c4);

        pianoMock.verifyNoKeysReleased();
        pianoMock.verifyNoKeysPlayed();
      });

      testWidgets('plays and releases white key', (tester) async {
        final pianoMock = await tester.renderKeyboard();

        final gesture = await tester.startGesture(whiteKey1);
        await gesture.up();

        pianoMock.verifyKeyPlayed(c4);
        pianoMock.verifyKeyReleased(c4);

        pianoMock.verifyNoKeysReleased();
        pianoMock.verifyNoKeysPlayed();
      });

      testWidgets('taps white key', (tester) async {
        final pianoMock = await tester.renderKeyboard();

        await tester.tap(find.bySemanticsLabel('C4'));

        pianoMock.verifyKeyPlayed(c4);
        pianoMock.verifyKeyReleased(c4);

        pianoMock.verifyNoKeysReleased();
        pianoMock.verifyNoKeysPlayed();
      });
    });

    group('playing single black keys', () {
      testWidgets('plays and holds black key', (tester) async {
        final pianoMock = await tester.renderKeyboard();

        await tester.startGesture(blackKey1);

        pianoMock.verifyKeyPlayed(cSharp4);

        pianoMock.verifyNoKeysReleased();
        pianoMock.verifyNoKeysPlayed();
      });

      testWidgets('plays and releases black key', (tester) async {
        final pianoMock = await tester.renderKeyboard();

        final gesture = await tester.startGesture(blackKey1);
        await gesture.up();

        pianoMock.verifyKeyPlayed(cSharp4);
        pianoMock.verifyKeyReleased(cSharp4);

        pianoMock.verifyNoKeysReleased();
        pianoMock.verifyNoKeysPlayed();
      });

      testWidgets('taps black key', (tester) async {
        final pianoMock = await tester.renderKeyboard();

        await tester.tap(find.bySemanticsLabel('C♯4'));

        pianoMock.verifyKeyPlayed(cSharp4);
        pianoMock.verifyKeyReleased(cSharp4);

        pianoMock.verifyNoKeysReleased();
        pianoMock.verifyNoKeysPlayed();
      });
    });

    group('playing multiple white keys', () {
      testWidgets('plays and holds multiple white keys', (tester) async {
        final pianoMock = await tester.renderKeyboard();

        await tester.startGesture(whiteKey1);
        await tester.startGesture(whiteKey2);

        pianoMock.verifyKeyPlayed(c4);
        pianoMock.verifyKeyPlayed(d4);

        pianoMock.verifyNoKeysReleased();
        pianoMock.verifyNoKeysPlayed();
      });

      testWidgets('plays and releases multiple white keys', (tester) async {
        final pianoMock = await tester.renderKeyboard();

        final gesture1 = await tester.startGesture(whiteKey1);
        await gesture1.up();
        final gesture2 = await tester.startGesture(whiteKey2);
        await gesture2.up();

        pianoMock.verifyKeyPlayed(c4);
        pianoMock.verifyKeyReleased(c4);

        pianoMock.verifyKeyPlayed(d4);
        pianoMock.verifyKeyReleased(d4);

        pianoMock.verifyNoKeysReleased();
        pianoMock.verifyNoKeysPlayed();
      });

      testWidgets('taps multiple white key', (tester) async {
        final pianoMock = await tester.renderKeyboard();

        await tester.tap(find.bySemanticsLabel('C4'));
        await tester.tap(find.bySemanticsLabel('D4'));

        pianoMock.verifyKeyPlayed(c4);
        pianoMock.verifyKeyReleased(c4);

        pianoMock.verifyKeyPlayed(d4);
        pianoMock.verifyKeyReleased(d4);

        pianoMock.verifyNoKeysReleased();
        pianoMock.verifyNoKeysPlayed();
      });
    });

    group('playing multiple black keys', () {
      testWidgets('plays and holds multiple black keys', (tester) async {
        final pianoMock = await tester.renderKeyboard();

        await tester.startGesture(blackKey1);
        await tester.startGesture(blackKey2);

        pianoMock.verifyKeyPlayed(cSharp4);
        pianoMock.verifyKeyPlayed(dSharp4);

        pianoMock.verifyNoKeysReleased();
        pianoMock.verifyNoKeysPlayed();
      });

      testWidgets('plays and releases multiple black keys', (tester) async {
        final pianoMock = await tester.renderKeyboard();

        final gesture1 = await tester.startGesture(blackKey1);
        await gesture1.up();
        final gesture2 = await tester.startGesture(blackKey2);
        await gesture2.up();

        pianoMock.verifyKeyPlayed(cSharp4);
        pianoMock.verifyKeyReleased(cSharp4);

        pianoMock.verifyKeyPlayed(dSharp4);
        pianoMock.verifyKeyReleased(dSharp4);

        pianoMock.verifyNoKeysReleased();
        pianoMock.verifyNoKeysPlayed();
      });

      testWidgets('taps multiple black key', (tester) async {
        final pianoMock = await tester.renderKeyboard();

        await tester.tap(find.bySemanticsLabel('C♯4'));
        await tester.tap(find.bySemanticsLabel('D♯4'));

        pianoMock.verifyKeyPlayed(cSharp4);
        pianoMock.verifyKeyReleased(cSharp4);

        pianoMock.verifyKeyPlayed(dSharp4);
        pianoMock.verifyKeyReleased(dSharp4);

        pianoMock.verifyNoKeysReleased();
        pianoMock.verifyNoKeysPlayed();
      });
    });

    group('dragging over keys (Glissando)', () {
      testWidgets('plays keys once when dragging within key', (tester) async {
        final pianoMock = await tester.renderKeyboard();

        final gesture = await tester.startGesture(whiteKey1);
        pianoMock.verifyKeyPlayed(c4);

        await gesture.moveBy(const Offset(1, 0));
        pianoMock.verifyNoKeysReleased();
        pianoMock.verifyNoKeysPlayed();
      });

      testWidgets('plays new key and releases old key when dragging into new key', (tester) async {
        final pianoMock = await tester.renderKeyboard();

        final gesture = await tester.startGesture(whiteKey1);
        pianoMock.verifyKeyPlayed(c4);
        await gesture.moveBy(const Offset(1, 0));

        await gesture.moveBy(const Offset(10, 0));
        pianoMock.verifyKeyReleased(c4);
        pianoMock.verifyKeyPlayed(d4);

        pianoMock.verifyNoKeysReleased();
        pianoMock.verifyNoKeysPlayed();
      });

      testWidgets('plays one key at a time when dragging over multiple keys (Glissando)', (tester) async {
        final pianoMock = await tester.renderKeyboard();
        final gesture = await tester.startGesture(whiteKey1);
        pianoMock.verifyKeyPlayed(c4);
        await gesture.moveBy(const Offset(1, 0));

        await gesture.moveBy(const Offset(5, -50));
        pianoMock.verifyKeyReleased(c4);
        pianoMock.verifyKeyPlayed(cSharp4);

        await gesture.moveBy(const Offset(5, 50));
        pianoMock.verifyKeyReleased(cSharp4);
        pianoMock.verifyKeyPlayed(d4);

        await gesture.moveBy(const Offset(5, -50));
        pianoMock.verifyKeyReleased(d4);
        pianoMock.verifyKeyPlayed(dSharp4);

        pianoMock.verifyNoKeysReleased();
        pianoMock.verifyNoKeysPlayed();
      });

      testWidgets('releases all keys when dragging into out of piano', (tester) async {
        final pianoMock = await tester.renderKeyboard();
        final gesture = await tester.startGesture(whiteKey1);
        pianoMock.verifyKeyPlayed(c4);
        await gesture.moveBy(const Offset(1, 0));

        await gesture.moveBy(const Offset(-10, 0));
        pianoMock.verifyKeyReleased(c4);

        pianoMock.verifyNoKeysReleased();
        pianoMock.verifyNoKeysPlayed();
      });
    });

    group('playing and dragging over keys (Glissando)', () {
      testWidgets('plays and holds key while dragging over other group of keys with other finger', (tester) async {
        final pianoMock = await tester.renderKeyboard();
        await tester.startGesture(whiteKey1);
        pianoMock.verifyKeyPlayed(c4);

        final gesture = await tester.startGesture(blackKey1);
        pianoMock.verifyKeyPlayed(cSharp4);
        await gesture.moveBy(const Offset(1, 0));

        await gesture.moveBy(const Offset(10, 0));
        pianoMock.verifyKeyReleased(cSharp4);
        pianoMock.verifyKeyPlayed(dSharp4);

        pianoMock.verifyNoKeysReleased();
        pianoMock.verifyNoKeysPlayed();
      });

      testWidgets('plays and holds key while dragging out of keyboard with other finger', (tester) async {
        final pianoMock = await tester.renderKeyboard();
        await tester.startGesture(whiteKey1);
        pianoMock.verifyKeyPlayed(c4);

        final gesture = await tester.startGesture(blackKey1);
        pianoMock.verifyKeyPlayed(cSharp4);
        await gesture.moveBy(const Offset(1, 0));

        await gesture.moveBy(const Offset(0, -50));
        pianoMock.verifyKeyReleased(cSharp4);

        pianoMock.verifyNoKeysReleased();
        pianoMock.verifyNoKeysPlayed();
      });
    });

    // TODO: lowest note
    // TODO: positioning
    // TODO: number of keys
    // TODO: has label
  });
}
