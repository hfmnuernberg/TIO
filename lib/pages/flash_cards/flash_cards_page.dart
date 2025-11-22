import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/domain/flash_cards/category.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/pages/flash_cards/flash_card_category_wheel.dart';
import 'package:tiomusic/services/flash_cards.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/widgets/flash_card/flash_card.dart';

class FlashCardsPage extends StatefulWidget {
  const FlashCardsPage({super.key});

  @override
  State<FlashCardsPage> createState() => _FlashCardsPageState();
}

class _FlashCardsPageState extends State<FlashCardsPage> {
  FlashCardCategory? _selectedCategory;

  void _openCategoryFilter() async {
    final result = await showModalBottomSheet<FlashCardCategory?>(
      context: context,
      builder: (context) => _CategoryFilterBottomSheet(initialCategory: _selectedCategory),
    );

    setState(() => _selectedCategory = result);
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
                  onPressed: _openCategoryFilter,
                  icon: const Icon(Icons.filter_list),
                  label: const Text('Filter category'),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: const BorderSide(),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(child: _FlashCardsList(categoryFilter: _selectedCategory)),
          ],
        ),
      ),
    );
  }
}

class _CategoryFilterBottomSheet extends StatefulWidget {
  final FlashCardCategory? initialCategory;

  const _CategoryFilterBottomSheet({this.initialCategory});

  @override
  State<_CategoryFilterBottomSheet> createState() => _CategoryFilterBottomSheetState();
}

class _CategoryFilterBottomSheetState extends State<_CategoryFilterBottomSheet> {
  FlashCardCategory? _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialCategory;
  }

  void _handleSelect(FlashCardCategory? category) => setState(() => _current = category);

  void _apply() => Navigator.of(context).pop(_current);

  void _clear() => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select category',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: ColorTheme.primary),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: FlashCardCategoryWheel(initialCategory: _current, onSelect: _handleSelect),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(onPressed: _clear, child: const Text('Clear')),
                ElevatedButton(onPressed: _apply, child: const Text('Apply')),
              ],
            ),
          ],
        ),
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
