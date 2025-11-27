import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/domain/flash_cards/category.dart';
import 'package:tiomusic/domain/flash_cards/flash_card.dart' as domain;
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/services/flash_cards.dart';
import 'package:tiomusic/widgets/flash_cards/flash_card.dart';

class FlashCardsList extends StatefulWidget {
  final FlashCardCategory? categoryFilter;
  final bool bookmarkFilterActive;

  const FlashCardsList({super.key, this.categoryFilter, required this.bookmarkFilterActive});

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
    bookmarkedCardIds.contains(cardId) ? bookmarkedCardIds.remove(cardId) : bookmarkedCardIds.add(cardId);
    setState(() {});
    await flashCards.updateBookmark(cardId);
  }

  List<domain.FlashCard> filterCards() {
    final cards = flashCards.getAll();

    return cards.where((card) {
      final matchesCategory = widget.categoryFilter == null || card.category == widget.categoryFilter;
      final matchesBookmark = !widget.bookmarkFilterActive || bookmarkedCardIds.contains(card.id);
      return matchesCategory && matchesBookmark;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final filteredCards = filterCards();

    return Semantics(
      container: true,
      hint: context.l10n.flashCardsPageTitle,
      child: ListView.separated(
        padding: EdgeInsets.only(bottom: 32 + bottomInset),
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
