import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/domain/flash_cards/category.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/widgets/flash_card/category_filter_button.dart';
import 'package:tiomusic/services/flash_cards.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/widgets/flash_card/flash_card.dart';

class FlashCardsPage extends StatefulWidget {
  const FlashCardsPage({super.key});

  @override
  State<FlashCardsPage> createState() => _FlashCardsPageState();
}

class _FlashCardsPageState extends State<FlashCardsPage> {
  FlashCardCategory? selectedCategory;

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
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: CategoryFilterButton(
                  selectedCategory: selectedCategory,
                  onSelected: (category) => setState(() => selectedCategory = category),
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
