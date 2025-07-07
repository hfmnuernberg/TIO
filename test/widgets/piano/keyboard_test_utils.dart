import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/widgets/piano/keyboard.dart';

import '../../utils/render_utils.dart';

const keyboardWidth = 10.0 * PianoParams.numberOfWhiteKeys;
const keyboardHeight = 100.0;

const c4 = 60;
const cSharp4 = 61;
const d4 = 62;
const dSharp4 = 63;
const e4 = 64;
const f4 = 65;
const fSharp4 = 66;
const g4 = 67;
const gSharp4 = 68;
const a4 = 69;
const aSharp4 = 70;
const c5 = 71;
const cSharp5 = 73;
const d5 = 74;
const dSharp5 = 75;
const fSharp5 = 78;
const g5 = 79;
const gSharp5 = 80;
const a5 = 81;
const h5 = 83;
const c6 = 84;

const whiteKey1 = Offset(5, 75);
const whiteKey2 = Offset(15, 75);
const whiteKey3 = Offset(25, 75);
const whiteKey12 = Offset(115, 75);

const blackKey1 = Offset(10, 25);
const blackKey2 = Offset(20, 25);

class PianoMock extends Mock {
  void onPlay(int note);
  void onRelease(int note);

  void verifyKeyPlayed(int note) => verify(() => onPlay(note)).called(1);
  void verifyKeyReleased(int note) => verify(() => onRelease(note)).called(1);

  void verifyNoKeysPlayed() => verifyNever(() => onPlay(any()));
  void verifyNoKeysReleased() => verifyNever(() => onRelease(any()));
}

extension WidgetTesterRenderExtension on WidgetTester {
  Future<PianoMock> renderKeyboard({lowestNote = c4, isHolding = false}) async {
    final pianoMock = PianoMock();
    await renderWidget(
      SizedBox(
        width: keyboardWidth,
        height: keyboardHeight,
        child: Keyboard(
          lowestNote: lowestNote,
          isHolding: isHolding,
          onPlay: pianoMock.onPlay,
          onRelease: pianoMock.onRelease,
        ),
      ),
    );
    return pianoMock;
  }

  Future<TestGesture> pressAndHoldWhiteKeyAt(double x) async => startGesture(Offset(x, 75));
  Future<TestGesture> pressAndHoldBlackKeyAt(double x) async => startGesture(Offset(x, 25));

  Future<void> pressAndReleaseWhiteKeyAt(double x) async => (await pressAndHoldWhiteKeyAt(x)).up();
  Future<void> pressAndReleaseBlackKeyAt(double x) async => (await pressAndHoldBlackKeyAt(x)).up();

  Future<void> pressAndReleaseKey(Pattern label) async => tap(find.bySemanticsLabel(label));
}
