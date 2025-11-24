import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/domain/flash_cards/category.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/pages/flash_cards/flash_card_category_wheel.dart';
import 'package:tiomusic/services/flash_cards.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/widgets/confirm_setting_button.dart';
import 'package:tiomusic/widgets/flash_card/flash_card.dart';
import 'package:tiomusic/widgets/parent_tool/modal_bottom_sheet.dart';

class FlashCardsPage extends StatefulWidget {
  const FlashCardsPage({super.key});

  @override
  State<FlashCardsPage> createState() => _FlashCardsPageState();
}

class _FlashCardsPageState extends State<FlashCardsPage> {
  FlashCardCategory? selectedCategory;

  void openCategoryFilter() async {
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
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ColorTheme.surfaceTint),
            ),
          ),
        ],
        contentChildren: [
          Expanded(
            child: _CategoryFilterContent(
              initialCategory: selectedCategory,
              onChanged: (category) => tempCategory = category,
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
                  boldText: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (result == null) return;

    setState(() => selectedCategory = result.category);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      appBar: AppBar(
        title: Text(context.l10n.flashCardsPageTitle),
        backgroundColor: ColorTheme.surfaceBright,
        foregroundColor: ColorTheme.primary,
      ),
      backgroundColor: ColorTheme.primary92,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: openCategoryFilter,
                  icon: const Icon(Icons.filter_list),
                  label: Text(context.l10n.flashCardsSelectCategory),
                  style: TextButton.styleFrom(
                    backgroundColor: ColorTheme.onPrimary,
                    foregroundColor: ColorTheme.primary,
                    iconColor: ColorTheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: const BorderSide(color: ColorTheme.primary),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(child: _FlashCardsList(categoryFilter: selectedCategory)),
          ],
        ),
      ),
    );
  }
}

class _CategoryFilterResult {
  final FlashCardCategory? category;
  const _CategoryFilterResult(this.category);
}

class _CategoryFilterContent extends StatefulWidget {
  final FlashCardCategory? initialCategory;
  final ValueChanged<FlashCardCategory?> onChanged;

  const _CategoryFilterContent({this.initialCategory, required this.onChanged});

  @override
  State<_CategoryFilterContent> createState() => _CategoryFilterContentState();
}

class _CategoryFilterContentState extends State<_CategoryFilterContent> {
  FlashCardCategory? current;

  @override
  void initState() {
    super.initState();
    current = widget.initialCategory;
  }

  void handleSelect(FlashCardCategory? category) {
    setState(() => current = category);
    widget.onChanged(category);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 220,
        width: 200,
        child: FlashCardCategoryWheel(initialCategory: current, onSelect: handleSelect),
      ),
    );
  }
}

class _FlashCardsList extends StatelessWidget {
  final FlashCardCategory? categoryFilter;

  const _FlashCardsList({this.categoryFilter});

  @override
  Widget build(BuildContext context) {
    final cards = context.read<FlashCards>().getAll();
    final filteredCards = categoryFilter == null
        ? cards
        : cards.where((card) => card.category == categoryFilter).toList();
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 32 + bottomInset),
      itemBuilder: (_, i) =>
          FlashCard(category: filteredCards[i].category, description: filteredCards[i].description(context.l10n)),
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemCount: filteredCards.length,
    );
  }
}
