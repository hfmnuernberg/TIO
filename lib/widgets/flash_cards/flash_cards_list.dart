import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/domain/flash_cards/category.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/services/flash_cards.dart';
import 'package:tiomusic/widgets/flash_cards/flash_card.dart';

class FlashCardsList extends StatefulWidget {
  final FlashCardCategory? categoryFilter;

  const FlashCardsList({super.key, this.categoryFilter});

  @override
  State<FlashCardsList> createState() => _FlashCardsListState();
}

class _FlashCardsListState extends State<FlashCardsList> {
  late FlashCards flashCards;

  List<String> bookmarkedCardIds = [];

  @override
  void initState() {
    super.initState();
    flashCards = context.read<FlashCards>();
    unawaited(loadBookmarkedCardIds());
  }

  Future<void> loadBookmarkedCardIds() async {
    bookmarkedCardIds = await flashCards.getAllBookmarked();
    setState(() {});
  }

  Future<void> handleToggleBookmark(String cardId) async {
    await flashCards.updateBookmarks(cardId);
    loadBookmarkedCardIds();
  }

  @override
  Widget build(BuildContext context) {
    final cards = flashCards.getAll();
    final filteredCards = widget.categoryFilter == null
        ? cards
        : cards.where((card) => card.category == widget.categoryFilter).toList();

    return Semantics(
      container: true,
      hint: context.l10n.flashCardsPageTitle,
      child: ListView.separated(
        itemBuilder: (_, i) {
          final card = filteredCards[i];

          return FlashCard(
            category: card.category,
            description: card.description(context.l10n),
            isBookmarked: bookmarkedCardIds.contains(card.id),
            onToggle: () => handleToggleBookmark(card.id),
          );
        },
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemCount: filteredCards.length,
      ),
    );
  }
}
