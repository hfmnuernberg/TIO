import 'package:flutter_test/flutter_test.dart';

import 'keyboard_test_utils.dart';

void main() {
  group('Keyboard - Black keys - sharps starting with F4', () {
    testWidgets('renders no sharp on first half of first white key', (tester) async {
      final pianoMock = await tester.renderKeyboard(lowestNote: f4);

      await tester.pressAndReleaseBlackKeyAt(4);
      pianoMock.verifyKeyPlayed(f4);
    });

    testWidgets('renders 1st sharp key', (tester) async {
      final pianoMock = await tester.renderKeyboard(lowestNote: f4);

      await tester.pressAndReleaseBlackKeyAt(10);
      pianoMock.verifyKeyPlayed(fSharp4);

      await tester.pressAndReleaseKey('F♯4');
      pianoMock.verifyKeyPlayed(fSharp4);
    });

    testWidgets('leaves gap where 11th sharp key would be', (tester) async {
      final pianoMock = await tester.renderKeyboard(lowestNote: f4);

      await tester.pressAndReleaseBlackKeyAt(110);
      pianoMock.verifyNoKeysPlayed();
    });

    testWidgets('renders no sharp key on second half of last white key', (tester) async {
      final pianoMock = await tester.renderKeyboard(lowestNote: f4);

      await tester.pressAndReleaseBlackKeyAt(115);
      pianoMock.verifyKeyPlayed(c6);
    });
  });
}
