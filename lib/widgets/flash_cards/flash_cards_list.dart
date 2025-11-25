import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/domain/flash_cards/category.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/services/flash_cards.dart';
import 'package:tiomusic/widgets/flash_cards/flash_card.dart';

class FlashCardsList extends StatelessWidget {
  final FlashCardCategory? categoryFilter;

  const FlashCardsList({super.key, this.categoryFilter});

  @override
  Widget build(BuildContext context) {
    final cards = context.read<FlashCards>().getAll();
    final filteredCards = categoryFilter == null
        ? cards
        : cards.where((card) => card.category == categoryFilter).toList();

    return Semantics(
      container: true,
      hint: context.l10n.flashCardsPageTitle,
      child: ListView.separated(
        itemBuilder: (_, i) =>
            FlashCard(category: filteredCards[i].category, description: filteredCards[i].description(context.l10n)),
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemCount: filteredCards.length,
      ),
    );
  }
}
