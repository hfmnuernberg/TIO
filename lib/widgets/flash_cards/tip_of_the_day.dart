import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/domain/flash_cards/flash_card.dart' as domain;
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/pages/flash_cards/flash_cards_page.dart';
import 'package:tiomusic/services/flash_cards.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/widgets/flash_cards/flash_card.dart';

class TipOfTheDay extends StatefulWidget {
  const TipOfTheDay({super.key});

  @override
  State<TipOfTheDay> createState() => _TipOfTheDayState();
}

class _TipOfTheDayState extends State<TipOfTheDay> {
  late FlashCards flashCards;

  domain.FlashCard? card;
  List<String> bookmarkedCardIds = [];

  @override
  void initState() {
    super.initState();
    flashCards = context.read<FlashCards>();
    unawaited(loadTipOfTheDay());
    unawaited(loadBookmarkedCardIds());
  }

  Future<void> loadTipOfTheDay() async {
    card = await flashCards.getTipOfTheDay(DateTime.now());
    setState(() {});
  }

  Future<void> loadBookmarkedCardIds() async {
    bookmarkedCardIds = await flashCards.getAllBookmarked();
    setState(() {});
  }

  Future<void> regenerate() async {
    card = await flashCards.getTipOfTheDay();
    setState(() {});
  }

  Future<void> handleToggleBookmark(String cardId) async {
    bookmarkedCardIds.contains(cardId) ? bookmarkedCardIds.remove(cardId) : bookmarkedCardIds.add(cardId);
    setState(() {});
    await flashCards.updateBookmark(cardId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Material(
      color: ColorTheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    color: ColorTheme.surfaceTint,
                    size: TIOMusicParams.titleFontSize,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.tipOfTheDayTitle,
                    style: const TextStyle(color: ColorTheme.primary, fontSize: TIOMusicParams.titleFontSize),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            if (card == null)
              const Center(child: CircularProgressIndicator())
            else
              FlashCard(
                category: card!.category,
                description: card!.description(l10n),
                isBookmarked: bookmarkedCardIds.contains(card!.id),
                onToggle: () => handleToggleBookmark(card!.id),
              ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => const FlashCardsPage()))
                      .then((_) => loadBookmarkedCardIds()),
                  child: Text(l10n.tipOfTheDayViewMore, style: const TextStyle(color: ColorTheme.primary)),
                ),
                TextButton.icon(
                  onPressed: regenerate,
                  icon: const Icon(Icons.refresh, size: 18, color: ColorTheme.primary),
                  label: Text(l10n.tipOfTheDayRegenerate, style: const TextStyle(color: ColorTheme.primary)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
