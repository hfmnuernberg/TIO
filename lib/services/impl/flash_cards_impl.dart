import 'dart:math';

import 'package:tiomusic/models/flash_cards.dart';
import 'package:tiomusic/domain/flash_cards/flash_cards_list.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/services/flash_cards.dart';

class FlashCardsImpl implements FlashCards {
  @override
  List<FlashCardModel> load() => List.unmodifiable(flashCards);

  @override
  FlashCardModel loadNext(ProjectLibrary library) {
    final cards = load();
    final seenCards = library.seenFlashCards;
    final unseenCards = <FlashCardModel>[];

    if (seenCards.length >= cards.length) {
      seenCards.clear();
    }

    for (final card in cards) {
      final alreadySeen = seenCards.any((seen) => seen.id == card.id);
      if (!alreadySeen) unseenCards.add(card);
    }

    if (unseenCards.isEmpty) {
      unseenCards.addAll(cards);
      seenCards.clear();
    }

    final currentCard = unseenCards[Random().nextInt(unseenCards.length)];

    seenCards.add(SeenFlashCard(id: currentCard.id, seenAt: DateTime.now()));

    return currentCard;
  }
}
