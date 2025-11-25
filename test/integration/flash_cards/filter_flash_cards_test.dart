import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiomusic/pages/flash_cards/flash_cards_page.dart';

import '../../utils/action_utils.dart';
import '../../utils/render_utils.dart';
import '../../utils/test_context.dart';

extension WidgetTesterPumpExtension on WidgetTester {
  List<String> getCardTitles(FinderBase<SemanticsNode> list) {
    final semanticNodesList = list.evaluate().cast<SemanticsNode>().toList();
    return semanticNodesList.map((node) => node.label).toList();
  }
}

void main() {
  late TestContext context;

  setUpAll(WidgetsFlutterBinding.ensureInitialized);

  setUp(() async {
    context = TestContext();
    await context.init();
  });

  group('FlashCardsPage', () {
    testWidgets('filters flash cards by category', (tester) async {
      await tester.renderScaffold(FlashCardsPage(), context.providers);
      final cardList = find.semantics.byHint('Practice tips');
      final cardListItems = find.semantics.descendant(of: cardList, matching: find.semantics.byHint('Flash card'));
      final cardTitles = tester.getCardTitles(cardListItems);
      expect(cardTitles.every((title) => title.contains('Culture')), isTrue);

      await tester.tapAndSettle(find.bySemanticsLabel('Select category'));
      await tester.tapAndSettle(find.bySemanticsLabel('Journaling'));
      await tester.tapAndSettle(find.bySemanticsLabel('Apply'));

      final cardTitlesFiltered = tester.getCardTitles(cardListItems);
      expect(cardTitlesFiltered.every((title) => title.contains('Journaling')), isTrue);

      expect(cardTitlesFiltered.any((title) => title.contains('Culture')), isFalse);
    });
  });
}
