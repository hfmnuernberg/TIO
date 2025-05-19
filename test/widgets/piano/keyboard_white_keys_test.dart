import 'package:flutter_test/flutter_test.dart';

import 'keyboard_test_utils.dart';

void main() {
  group('Keyboard - White Keys', () {
    group('naturals', () {
      testWidgets('renders first natural key', (tester) async {
        final pianoMock = await tester.renderKeyboard();

        await tester.pressAndReleaseWhiteKeyAt(5);
        pianoMock.verifyKeyPlayed(c4);

        await tester.pressAndReleaseKey('C4');
        pianoMock.verifyKeyPlayed(c4);
      });

      testWidgets('renders second natural key', (tester) async {
        final pianoMock = await tester.renderKeyboard();

        await tester.pressAndReleaseWhiteKeyAt(15);
        pianoMock.verifyKeyPlayed(d4);

        await tester.pressAndReleaseKey('D4');
        pianoMock.verifyKeyPlayed(d4);
      });

      testWidgets('renders last natural key', (tester) async {
        final pianoMock = await tester.renderKeyboard();

        await tester.pressAndReleaseWhiteKeyAt(115);
        pianoMock.verifyKeyPlayed(g5);

        await tester.pressAndReleaseKey('G5');
        pianoMock.verifyKeyPlayed(g5);
      });

      testWidgets('renders no natural keys beyond end of keyboard', (tester) async {
        final pianoMock = await tester.renderKeyboard();

        await tester.pressAndReleaseWhiteKeyAt(121);
        pianoMock.verifyNoKeysPlayed();
      });

      testWidgets('starts with lowest key', (tester) async {
        final pianoMock = await tester.renderKeyboard(g5);

        await tester.pressAndReleaseWhiteKeyAt(5);
        pianoMock.verifyKeyPlayed(g5);

        await tester.pressAndReleaseWhiteKeyAt(15);
        pianoMock.verifyKeyPlayed(a5);
      });
    });
  });
}
