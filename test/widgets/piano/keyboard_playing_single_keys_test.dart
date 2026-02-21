import 'package:flutter_test/flutter_test.dart';

import 'keyboard_test_utils.dart';

void main() {
  group('Keyboard - Playing single keys', () {
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

        await tester.pressAndReleaseKey('C4');

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

        await tester.pressAndReleaseKey('C♯4');

        pianoMock.verifyKeyPlayed(cSharp4);
        pianoMock.verifyKeyReleased(cSharp4);

        pianoMock.verifyNoKeysReleased();
        pianoMock.verifyNoKeysPlayed();
      });
    });
  });
}
