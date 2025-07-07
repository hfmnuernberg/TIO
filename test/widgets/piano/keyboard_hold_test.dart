import 'package:flutter_test/flutter_test.dart';

import 'keyboard_test_utils.dart';

void main() {
  group('Keyboard - Hold', () {
    testWidgets('does not release any keys when holding', (tester) async {
      final pianoMock = await tester.renderKeyboard(isHolding: true);

      await tester.pressAndReleaseKey('C4');
      await tester.pressAndReleaseKey('D4');

      pianoMock.verifyKeyPlayed(c4);
      pianoMock.verifyKeyPlayed(d4);
      pianoMock.verifyNoKeysReleased();
    });

    testWidgets('releases all keys when hold switches off', (tester) async {
      var pianoMock = await tester.renderKeyboard(isHolding: true);

      await tester.pressAndReleaseKey('C4');
      await tester.pressAndReleaseKey('D4');

      pianoMock = await tester.renderKeyboard(isHolding: false);

      pianoMock.verifyKeyReleased(c4);
      pianoMock.verifyKeyReleased(d4);
    });
  });
}
