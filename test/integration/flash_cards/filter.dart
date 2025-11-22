import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiomusic/pages/flash_cards/flash_cards_page.dart';

import '../../utils/action_utils.dart';
import '../../utils/render_utils.dart';

void main() {
  setUpAll(WidgetsFlutterBinding.ensureInitialized);

  group('FlashCardsPage', () {
    testWidgets('filters flash cards by category', (tester) async {
      await tester.renderScaffold(FlashCardsPage());
      expect(find.bySemanticsLabel('Vision'), findsNothing);

      await tester.tapAndSettle(find.bySemanticsLabel('Filter categories'));
      await tester.tapAndSettle(find.bySemanticsLabel('Vision'));

      expect(find.bySemanticsLabel('Vision'), findsOneWidget);
    });
  });
}
