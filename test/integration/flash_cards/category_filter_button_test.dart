import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiomusic/domain/flash_cards/category.dart';
import 'package:tiomusic/widgets/flash_cards/category_filter_button.dart';

import '../../utils/action_utils.dart';
import '../../utils/render_utils.dart';
import '../../utils/test_context.dart';

void main() {
  late TestContext context;

  setUpAll(WidgetsFlutterBinding.ensureInitialized);

  setUp(() async {
    context = TestContext();
    await context.init();
  });

  group('CategoryFilterButton', () {
    testWidgets('set category to selected category when selected', (tester) async {
      FlashCardCategory? selected;
      await tester.renderScaffold(CategoryFilterButton(onSelected: (c) => selected = c), context.providers);

      await tester.tapAndSettle(find.bySemanticsLabel('Select category'));
      await tester.tapAndSettle(find.bySemanticsLabel('Journaling'));
      await tester.tapAndSettle(find.bySemanticsLabel('Apply'));

      expect(selected, FlashCardCategory.journaling);
    });

    testWidgets('set category to null when all categories option is selected', (tester) async {
      FlashCardCategory? selected = FlashCardCategory.culture;
      await tester.renderScaffold(CategoryFilterButton(onSelected: (c) => selected = c), context.providers);

      await tester.tapAndSettle(find.bySemanticsLabel('Select category'));
      await tester.tapAndSettle(find.bySemanticsLabel('All categories'));
      await tester.tapAndSettle(find.bySemanticsLabel('Apply'));

      expect(selected, isNull);
    });
  });
}
