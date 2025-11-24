import 'package:flutter/material.dart';
import 'package:tiomusic/domain/flash_cards/category.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/widgets/confirm_setting_button.dart';
import 'package:tiomusic/widgets/flash_cards/flash_card_category_wheel.dart';
import 'package:tiomusic/widgets/parent_tool/modal_bottom_sheet.dart';

class CategoryFilterButton extends StatelessWidget {
  final FlashCardCategory? selectedCategory;
  final ValueChanged<FlashCardCategory?> onSelected;

  const CategoryFilterButton({super.key, this.selectedCategory, required this.onSelected});

  void _openCategoryFilter(BuildContext context) async {
    FlashCardCategory? tempCategory = selectedCategory;

    final result = await showModalBottomSheet<_CategoryFilterResult>(
      context: context,
      isScrollControlled: true,
      builder: (context) => ModalBottomSheet(
        label: context.l10n.flashCardsSelectCategory,
        heightFactor: 0.5,
        titleChildren: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              context.l10n.flashCardsSelectCategory,
              style: const TextStyle(fontSize: 22, color: ColorTheme.primary),
            ),
          ),
        ],
        contentChildren: [
          Expanded(
            child: Center(
              child: SizedBox(
                height: 220,
                width: 200,
                child: FlashCardCategoryWheel(
                  initialCategory: tempCategory,
                  onSelect: (category) => tempCategory = category,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TIOFlatButton(
                  onPressed: () => Navigator.of(context).pop(_CategoryFilterResult(tempCategory)),
                  text: context.l10n.commonApply,
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (result == null) return;

    onSelected(result.category);
  }

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () => _openCategoryFilter(context),
      icon: const Icon(Icons.filter_list),
      label: Text(context.l10n.flashCardsSelectCategory),
      style: TextButton.styleFrom(
        backgroundColor: ColorTheme.onPrimary,
        foregroundColor: ColorTheme.primary,
        iconColor: ColorTheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }
}

class _CategoryFilterResult {
  final FlashCardCategory? category;
  const _CategoryFilterResult(this.category);
}
