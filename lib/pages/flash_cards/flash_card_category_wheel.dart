import 'package:flutter/material.dart';
import 'package:tiomusic/domain/flash_cards/category.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/util/color_constants.dart';

class FlashCardCategoryWheel extends StatefulWidget {
  final FlashCardCategory? initialCategory;
  final ValueChanged<FlashCardCategory?> onSelect;

  const FlashCardCategoryWheel({super.key, required this.initialCategory, required this.onSelect});

  @override
  State<FlashCardCategoryWheel> createState() => _FlashCardCategoryWheelState();
}

class _FlashCardCategoryWheelState extends State<FlashCardCategoryWheel> {
  late final FixedExtentScrollController controller;
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    final initialCategory = widget.initialCategory;
    final initialIndex = initialCategory == null ? 0 : FlashCardCategory.values.indexOf(initialCategory) + 1;

    currentIndex = initialIndex < 0 ? 0 : initialIndex;
    controller = FixedExtentScrollController(initialItem: currentIndex);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _handleSelectedIndex(int index) {
    setState(() => currentIndex = index);

    if (index == 0) {
      widget.onSelect(null);
    } else {
      final category = FlashCardCategory.values[index - 1];
      widget.onSelect(category);
    }
  }

  String _labelForCategory(FlashCardCategory? category) {
    if (category == null) return context.l10n.flashCardsAllCategories;
    return context.l10n.categoryLabel(category);
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: ColorTheme.surface, borderRadius: BorderRadius.circular(16)),
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        itemExtent: 40,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: _handleSelectedIndex,
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: FlashCardCategory.values.length + 1,
          builder: (context, index) {
            final category = index == 0 ? null : FlashCardCategory.values[index - 1];
            final isSelected = index == currentIndex;
            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                controller.animateToItem(index, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
                _handleSelectedIndex(index);
              },
              child: Center(
                child: Text(
                  _labelForCategory(category),
                  style: TextStyle(
                    color: isSelected ? ColorTheme.primary : ColorTheme.primary.withValues(alpha: 0.5),
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                    fontSize: isSelected ? 18 : 14,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
