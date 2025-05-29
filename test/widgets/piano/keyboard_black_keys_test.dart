import 'package:flutter_test/flutter_test.dart';

import 'keyboard_test_utils.dart';

void main() {
  group('Keyboard - Keys', () {
    group('sharps - starting with C4', () {
      testWidgets('renders no sharp on first half of first white key', (tester) async {
        final pianoMock = await tester.renderKeyboard();

        await tester.pressAndReleaseBlackKeyAt(4);
        pianoMock.verifyKeyPlayed(c4);
      });

      testWidgets('renders 1st sharp key', (tester) async {
        final pianoMock = await tester.renderKeyboard();

        await tester.pressAndReleaseBlackKeyAt(10);
        pianoMock.verifyKeyPlayed(cSharp4);

        await tester.pressAndReleaseKey('C♯4');
        pianoMock.verifyKeyPlayed(cSharp4);
      });

      testWidgets('renders 2nd sharp key', (tester) async {
        final pianoMock = await tester.renderKeyboard();

        await tester.pressAndReleaseBlackKeyAt(20);
        pianoMock.verifyKeyPlayed(dSharp4);

        await tester.pressAndReleaseKey('D♯4');
        pianoMock.verifyKeyPlayed(dSharp4);
      });

      testWidgets('leaves gap where 3rd sharp key would be', (tester) async {
        final pianoMock = await tester.renderKeyboard();

        await tester.pressAndReleaseBlackKeyAt(30);
        pianoMock.verifyNoKeysPlayed();
      });

      testWidgets('renders 4th sharp key', (tester) async {
        final pianoMock = await tester.renderKeyboard();

        await tester.pressAndReleaseBlackKeyAt(40);
        pianoMock.verifyKeyPlayed(fSharp4);

        await tester.pressAndReleaseKey('F♯4');
        pianoMock.verifyKeyPlayed(fSharp4);
      });

      testWidgets('renders 5th sharp key', (tester) async {
        final pianoMock = await tester.renderKeyboard();

        await tester.pressAndReleaseBlackKeyAt(50);
        pianoMock.verifyKeyPlayed(gSharp4);

        await tester.pressAndReleaseKey('G♯4');
        pianoMock.verifyKeyPlayed(gSharp4);
      });

      testWidgets('renders 6th sharp key', (tester) async {
        final pianoMock = await tester.renderKeyboard();

        await tester.pressAndReleaseBlackKeyAt(60);
        pianoMock.verifyKeyPlayed(aSharp4);

        await tester.pressAndReleaseKey('A♯4');
        pianoMock.verifyKeyPlayed(aSharp4);
      });

      testWidgets('leaves gap where 7th sharp key would be', (tester) async {
        final pianoMock = await tester.renderKeyboard();

        await tester.pressAndReleaseBlackKeyAt(70);
        pianoMock.verifyNoKeysPlayed();
      });

      testWidgets('renders 8th sharp key', (tester) async {
        final pianoMock = await tester.renderKeyboard();

        await tester.pressAndReleaseBlackKeyAt(80);
        pianoMock.verifyKeyPlayed(cSharp5);

        await tester.pressAndReleaseKey('C♯5');
        pianoMock.verifyKeyPlayed(cSharp5);
      });

      testWidgets('renders 9th sharp key', (tester) async {
        final pianoMock = await tester.renderKeyboard();

        await tester.pressAndReleaseBlackKeyAt(90);
        pianoMock.verifyKeyPlayed(dSharp5);

        await tester.pressAndReleaseKey('D♯5');
        pianoMock.verifyKeyPlayed(dSharp5);
      });

      testWidgets('leaves gap where 10th sharp key would be', (tester) async {
        final pianoMock = await tester.renderKeyboard();

        await tester.pressAndReleaseBlackKeyAt(100);
        pianoMock.verifyNoKeysPlayed();
      });

      testWidgets('renders 11th sharp key', (tester) async {
        final pianoMock = await tester.renderKeyboard();

        await tester.pressAndReleaseBlackKeyAt(110);
        pianoMock.verifyKeyPlayed(fSharp5);

        await tester.pressAndReleaseKey('F♯5');
        pianoMock.verifyKeyPlayed(fSharp5);
      });

      testWidgets('renders no sharp key on second half of last white key', (tester) async {
        final pianoMock = await tester.renderKeyboard();

        await tester.pressAndReleaseBlackKeyAt(115);
        pianoMock.verifyKeyPlayed(g5);
      });
    });

    group('sharps - starting with D4', () {
      testWidgets('renders no sharp on first half of first white key', (tester) async {
        final pianoMock = await tester.renderKeyboard(d4);

        await tester.pressAndReleaseBlackKeyAt(4);
        pianoMock.verifyKeyPlayed(d4);
      });

      testWidgets('renders 1st sharp key', (tester) async {
        final pianoMock = await tester.renderKeyboard(d4);

        await tester.pressAndReleaseBlackKeyAt(10);
        pianoMock.verifyKeyPlayed(dSharp4);

        await tester.pressAndReleaseKey('D♯4');
        pianoMock.verifyKeyPlayed(dSharp4);
      });

      testWidgets('leaves gap where 2nd sharp key would be', (tester) async {
        final pianoMock = await tester.renderKeyboard(d4);

        await tester.pressAndReleaseBlackKeyAt(20);
        pianoMock.verifyNoKeysPlayed();
      });

      testWidgets('renders 3rd sharp key', (tester) async {
        final pianoMock = await tester.renderKeyboard(d4);

        await tester.pressAndReleaseBlackKeyAt(30);
        pianoMock.verifyKeyPlayed(fSharp4);

        await tester.pressAndReleaseKey('F♯4');
        pianoMock.verifyKeyPlayed(fSharp4);
      });

      testWidgets('renders 11th sharp key', (tester) async {
        final pianoMock = await tester.renderKeyboard(d4);

        await tester.pressAndReleaseBlackKeyAt(110);
        pianoMock.verifyKeyPlayed(gSharp5);

        await tester.pressAndReleaseKey('G♯5');
        pianoMock.verifyKeyPlayed(gSharp5);
      });

      testWidgets('renders no sharp key on second half of last white key', (tester) async {
        final pianoMock = await tester.renderKeyboard(d4);

        await tester.pressAndReleaseBlackKeyAt(115);
        pianoMock.verifyKeyPlayed(a5);
      });
    });

    group('sharps - starting with E4', () {
      testWidgets('renders no sharp on first half of first white key', (tester) async {
        final pianoMock = await tester.renderKeyboard(e4);

        await tester.pressAndReleaseBlackKeyAt(5);
        pianoMock.verifyKeyPlayed(e4);
      });

      testWidgets('leaves gap where 1st sharp key would be', (tester) async {
        final pianoMock = await tester.renderKeyboard(e4);

        await tester.pressAndReleaseBlackKeyAt(10);
        pianoMock.verifyNoKeysPlayed();
      });

      testWidgets('renders 2rd sharp key', (tester) async {
        final pianoMock = await tester.renderKeyboard(e4);

        await tester.pressAndReleaseBlackKeyAt(20);
        pianoMock.verifyKeyPlayed(fSharp4);

        await tester.pressAndReleaseKey('F♯4');
        pianoMock.verifyKeyPlayed(fSharp4);
      });

      testWidgets('renders no sharp key on second half of last white key', (tester) async {
        final pianoMock = await tester.renderKeyboard(e4);

        await tester.pressAndReleaseBlackKeyAt(115);
        pianoMock.verifyKeyPlayed(h5);
      });
    });

    group('sharps - starting with F4', () {
      testWidgets('renders no sharp on first half of first white key', (tester) async {
        final pianoMock = await tester.renderKeyboard(f4);

        await tester.pressAndReleaseBlackKeyAt(4);
        pianoMock.verifyKeyPlayed(f4);
      });

      testWidgets('renders 1st sharp key', (tester) async {
        final pianoMock = await tester.renderKeyboard(f4);

        await tester.pressAndReleaseBlackKeyAt(10);
        pianoMock.verifyKeyPlayed(fSharp4);

        await tester.pressAndReleaseKey('F♯4');
        pianoMock.verifyKeyPlayed(fSharp4);
      });

      testWidgets('leaves gap where 11th sharp key would be', (tester) async {
        final pianoMock = await tester.renderKeyboard(f4);

        await tester.pressAndReleaseBlackKeyAt(110);
        pianoMock.verifyNoKeysPlayed();
      });

      testWidgets('renders no sharp key on second half of last white key', (tester) async {
        final pianoMock = await tester.renderKeyboard(f4);

        await tester.pressAndReleaseBlackKeyAt(115);
        pianoMock.verifyKeyPlayed(c6);
      });
    });
  });
}
