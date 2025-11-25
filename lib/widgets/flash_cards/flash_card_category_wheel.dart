import 'package:flutter/material.dart';
import 'package:tiomusic/domain/flash_cards/category.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/flash_card_category_extension.dart';

class FlashCardCategoryWheel extends StatefulWidget {
  final FlashCardCategory? category;
  final ValueChanged<FlashCardCategory?> onSelect;

  const FlashCardCategoryWheel({super.key, required this.category, required this.onSelect});

  @override
  State<FlashCardCategoryWheel> createState() => _FlashCardCategoryWheelState();
}

class _FlashCardCategoryWheelState extends State<FlashCardCategoryWheel> {
  late final FixedExtentScrollController controller;
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    final initialCategory = widget.category;
    currentIndex = initialCategory == null ? 0 : FlashCardCategory.values.indexOf(initialCategory) + 1;
    controller = FixedExtentScrollController(initialItem: currentIndex);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void handleSelectedIndex(int index) {
    setState(() => currentIndex = index);

    if (index == 0) {
      widget.onSelect(null);
    } else {
      final category = FlashCardCategory.values[index - 1];
      widget.onSelect(category);
    }
  }

  String labelForCategory(FlashCardCategory? category) {
    return category == null ? context.l10n.flashCardsAllCategories : context.l10n.categoryLabel(category);
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: ColorTheme.surface, borderRadius: BorderRadius.circular(16)),
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        itemExtent: 40,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: handleSelectedIndex,
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: FlashCardCategory.values.length + 1,
          builder: (context, index) {
            final category = index == 0 ? null : FlashCardCategory.values[index - 1];
            final isSelected = index == currentIndex;

            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                controller.animateToItem(index, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
                handleSelectedIndex(index);
              },
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (category != null) ...[
                      Icon(category.icon, color: ColorTheme.surfaceTint, size: 14),
                      const SizedBox(width: 6),
                    ],
                    Flexible(
                      child: Text(
                        labelForCategory(category),
                        style: isSelected
                          ? TextStyle(color: ColorTheme.primary, fontWeight: FontWeight.w500, fontSize: 18)
                          : TextStyle(color: ColorTheme.primary.withValues(alpha: 0.5)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
