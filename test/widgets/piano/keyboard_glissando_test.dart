import 'package:flutter_test/flutter_test.dart';

import 'keyboard_test_utils.dart';

void main() {
  group('Keyboard - Glissando', () {
    group('dragging over keys', () {
      testWidgets('plays keys once when dragging within key', (tester) async {
        final pianoMock = await tester.renderKeyboard();

        final gesture = await tester.startGesture(whiteKey1);
        pianoMock.verifyKeyPlayed(c4);

        await gesture.moveBy(const Offset(1, 0));
        await gesture.moveBy(const Offset(1, 0));

        pianoMock.verifyNoKeysReleased();
        pianoMock.verifyNoKeysPlayed();
      });

      testWidgets('plays new key and releases old key when dragging into new key', (tester) async {
        final pianoMock = await tester.renderKeyboard();

        final gesture = await tester.startGesture(whiteKey1);
        pianoMock.verifyKeyPlayed(c4);
        await gesture.moveBy(const Offset(1, 0));
        await gesture.moveBy(const Offset(1, 0));

        await gesture.moveBy(const Offset(10, 0));
        pianoMock.verifyKeyReleased(c4);
        pianoMock.verifyKeyPlayed(d4);

        pianoMock.verifyNoKeysReleased();
        pianoMock.verifyNoKeysPlayed();
      });

      testWidgets('plays one key at a time when dragging over multiple keys', (tester) async {
        final pianoMock = await tester.renderKeyboard();
        final gesture = await tester.startGesture(whiteKey1);
        pianoMock.verifyKeyPlayed(c4);
        await gesture.moveBy(const Offset(1, 0));
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

      testWidgets('releases all keys when dragging out of piano', (tester) async {
        final pianoMock = await tester.renderKeyboard();
        final gesture = await tester.startGesture(whiteKey1);
        pianoMock.verifyKeyPlayed(c4);
        await gesture.moveBy(const Offset(1, 0));
        await gesture.moveBy(const Offset(1, 0));

        await gesture.moveBy(const Offset(-10, 0));
        pianoMock.verifyKeyReleased(c4);

        pianoMock.verifyNoKeysReleased();
        pianoMock.verifyNoKeysPlayed();
      });
    });

    group('playing and dragging over keys', () {
      testWidgets('plays and holds key while dragging over other group of keys with other finger', (tester) async {
        final pianoMock = await tester.renderKeyboard();
        await tester.startGesture(whiteKey1);
        pianoMock.verifyKeyPlayed(c4);

        final gesture = await tester.startGesture(blackKey1);
        pianoMock.verifyKeyPlayed(cSharp4);
        await gesture.moveBy(const Offset(1, 0));
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
        await gesture.moveBy(const Offset(1, 0));

        await gesture.moveBy(const Offset(0, -50));
        pianoMock.verifyKeyReleased(cSharp4);

        pianoMock.verifyNoKeysReleased();
        pianoMock.verifyNoKeysPlayed();
      });

      testWidgets('plays and holds key when dragging on same key with other finger', (tester) async {
        final pianoMock = await tester.renderKeyboard();
        final gesture1 = await tester.startGesture(whiteKey1);
        pianoMock.verifyKeyPlayed(c4);
        await gesture1.moveBy(const Offset(1, 0));
        await gesture1.moveBy(const Offset(1, 0));

        final gesture2 = await tester.startGesture(whiteKey1);
        await gesture2.moveBy(const Offset(1, 0));
        await gesture2.moveBy(const Offset(1, 0));

        pianoMock.verifyNoKeysReleased();
        pianoMock.verifyNoKeysPlayed();
      });

      testWidgets('plays and holds key when dragging over same key with other finger', (tester) async {
        final pianoMock = await tester.renderKeyboard();
        final gesture1 = await tester.startGesture(whiteKey2);
        pianoMock.verifyKeyPlayed(d4);
        await gesture1.moveBy(const Offset(1, 0));
        await gesture1.moveBy(const Offset(1, 0));

        final gesture2 = await tester.startGesture(whiteKey1);
        await gesture2.moveBy(const Offset(1, 0));
        pianoMock.verifyKeyPlayed(c4);

        await gesture2.moveBy(const Offset(10, 0));
        pianoMock.verifyKeyReleased(c4);

        await gesture2.moveBy(const Offset(10, 0));
        pianoMock.verifyKeyPlayed(e4);

        pianoMock.verifyNoKeysReleased();
        pianoMock.verifyNoKeysPlayed();
      });

      testWidgets('plays and holds key when dragging next to key with other finger', (tester) async {
        final pianoMock = await tester.renderKeyboard();
        final gesture1 = await tester.startGesture(whiteKey1);
        pianoMock.verifyKeyPlayed(c4);
        await gesture1.moveBy(const Offset(1, 0));
        await gesture1.moveBy(const Offset(1, 0));

        final gesture2 = await tester.startGesture(whiteKey3);
        pianoMock.verifyKeyPlayed(e4);
        await gesture2.moveBy(const Offset(1, 0));
        await gesture1.moveBy(const Offset(1, 0));

        await gesture2.moveBy(const Offset(-10, 0));
        pianoMock.verifyKeyReleased(e4);
        pianoMock.verifyKeyPlayed(d4);

        pianoMock.verifyNoKeysReleased();
        pianoMock.verifyNoKeysPlayed();
      });
    });
  });
}
