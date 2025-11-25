import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiomusic/domain/flash_cards/category.dart';
import 'package:tiomusic/widgets/flash_cards/flash_card_category_wheel.dart';

import '../../utils/action_utils.dart';
import '../../utils/render_utils.dart';

class StatefulFlashCardCategoryWheel extends StatefulWidget {
  final FlashCardCategory? initialCategory;

  const StatefulFlashCardCategoryWheel({super.key, this.initialCategory});

  @override
  State<StatefulFlashCardCategoryWheel> createState() => _StatefulFlashCardCategoryWheelState();
}

class _StatefulFlashCardCategoryWheelState extends State<StatefulFlashCardCategoryWheel> {
  FlashCardCategory? category;

  @override
  void initState() {
    super.initState();
    category = widget.initialCategory;
  }

  void _handleSelect(FlashCardCategory? category) {
    setState(() => this.category = category);
  }

  @override
  Widget build(BuildContext context) {
    final activeCategory = category?.name ?? 'all';

    return Column(
      children: [
        Semantics(label: 'Category display', value: activeCategory, excludeSemantics: true, child: Text(activeCategory)),
        Expanded(child: FlashCardCategoryWheel(initialCategory: category, onSelect: _handleSelect)),
      ],
    );
  }
}

void main() {
  setUpAll(WidgetsFlutterBinding.ensureInitialized);

  group('FlashCardCategoryWheel', () {
    testWidgets('shows all categories when no initial category is given', (tester) async {
      await tester.renderWidget(const StatefulFlashCardCategoryWheel());

      expect(tester.getSemantics(find.bySemanticsLabel('Category display')).value, 'all');
    });

    testWidgets('shows given category when initial category is provided', (tester) async {
      await tester.renderWidget(const StatefulFlashCardCategoryWheel(initialCategory: FlashCardCategory.culture));

      expect(tester.getSemantics(find.bySemanticsLabel('Category display')).value, 'culture');
    });

    testWidgets('changes category when tapping another category', (tester) async {
      await tester.renderWidget(const StatefulFlashCardCategoryWheel());
      expect(tester.getSemantics(find.bySemanticsLabel('Category display')).value, 'all');

      await tester.tapAndSettle(find.bySemanticsLabel('Journaling'));

      expect(tester.getSemantics(find.bySemanticsLabel('Category display')).value, 'journaling');
    });

    testWidgets('changes category when dragging to next category', (tester) async {
      await tester.renderWidget(const StatefulFlashCardCategoryWheel());

      await tester.dragFromCenterToTargetAndSettle(find.bySemanticsLabel('All categories'), const Offset(0, -100));

      expect(tester.getSemantics(find.bySemanticsLabel('Category display')).value, 'journaling');
    });

    testWidgets('shows all categories when tapping on all categories', (tester) async {
      await tester.renderWidget(const StatefulFlashCardCategoryWheel(initialCategory: FlashCardCategory.culture));
      expect(tester.getSemantics(find.bySemanticsLabel('Category display')).value, 'culture');

      await tester.tapAndSettle(find.bySemanticsLabel('All categories'));

      expect(tester.getSemantics(find.bySemanticsLabel('Category display')).value, 'all');
    });
  });
}
