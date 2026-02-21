import 'package:flutter_test/flutter_test.dart';

import 'keyboard_test_utils.dart';

void main() {
  group('Keyboard - Black keys - sharps starting with E4', () {
    testWidgets('renders no sharp on first half of first white key', (tester) async {
      final pianoMock = await tester.renderKeyboard(lowestNote: e4);

      await tester.pressAndReleaseBlackKeyAt(5);
      pianoMock.verifyKeyPlayed(e4);
    });

    testWidgets('leaves gap where 1st sharp key would be', (tester) async {
      final pianoMock = await tester.renderKeyboard(lowestNote: e4);

      await tester.pressAndReleaseBlackKeyAt(10);
      pianoMock.verifyNoKeysPlayed();
    });

    testWidgets('renders 2rd sharp key', (tester) async {
      final pianoMock = await tester.renderKeyboard(lowestNote: e4);

      await tester.pressAndReleaseBlackKeyAt(20);
      pianoMock.verifyKeyPlayed(fSharp4);

      await tester.pressAndReleaseKey('F♯4');
      pianoMock.verifyKeyPlayed(fSharp4);
    });

    testWidgets('renders no sharp key on second half of last white key', (tester) async {
      final pianoMock = await tester.renderKeyboard(lowestNote: e4);

      await tester.pressAndReleaseBlackKeyAt(115);
      pianoMock.verifyKeyPlayed(h5);
    });
  });
}
