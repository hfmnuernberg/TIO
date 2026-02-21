import 'package:flutter_test/flutter_test.dart';

import 'keyboard_test_utils.dart';

void main() {
  group('Keyboard - Black keys - sharps starting with D4', () {
    testWidgets('renders no sharp on first half of first white key', (tester) async {
      final pianoMock = await tester.renderKeyboard(lowestNote: d4);

      await tester.pressAndReleaseBlackKeyAt(4);
      pianoMock.verifyKeyPlayed(d4);
    });

    testWidgets('renders 1st sharp key', (tester) async {
      final pianoMock = await tester.renderKeyboard(lowestNote: d4);

      await tester.pressAndReleaseBlackKeyAt(10);
      pianoMock.verifyKeyPlayed(dSharp4);

      await tester.pressAndReleaseKey('D♯4');
      pianoMock.verifyKeyPlayed(dSharp4);
    });

    testWidgets('leaves gap where 2nd sharp key would be', (tester) async {
      final pianoMock = await tester.renderKeyboard(lowestNote: d4);

      await tester.pressAndReleaseBlackKeyAt(20);
      pianoMock.verifyNoKeysPlayed();
    });

    testWidgets('renders 3rd sharp key', (tester) async {
      final pianoMock = await tester.renderKeyboard(lowestNote: d4);

      await tester.pressAndReleaseBlackKeyAt(30);
      pianoMock.verifyKeyPlayed(fSharp4);

      await tester.pressAndReleaseKey('F♯4');
      pianoMock.verifyKeyPlayed(fSharp4);
    });

    testWidgets('renders 11th sharp key', (tester) async {
      final pianoMock = await tester.renderKeyboard(lowestNote: d4);

      await tester.pressAndReleaseBlackKeyAt(110);
      pianoMock.verifyKeyPlayed(gSharp5);

      await tester.pressAndReleaseKey('G♯5');
      pianoMock.verifyKeyPlayed(gSharp5);
    });

    testWidgets('renders no sharp key on second half of last white key', (tester) async {
      final pianoMock = await tester.renderKeyboard(lowestNote: d4);

      await tester.pressAndReleaseBlackKeyAt(115);
      pianoMock.verifyKeyPlayed(a5);
    });
  });
}
