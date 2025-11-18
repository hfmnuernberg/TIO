import 'dart:math';

import 'package:tiomusic/models/flash_cards.dart';
import 'package:tiomusic/domain/flash_cards/flash_cards_list.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/services/flash_cards.dart';

class FlashCardsImpl implements FlashCards {
  @override
  List<FlashCardModel> load() => List.unmodifiable(flashCards);

  @override
  FlashCardModel loadRandom() {
    final cards = load();
    return cards[Random().nextInt(cards.length)];
  }


  @override
  FlashCardModel loadNext(ProjectLibrary library) {
    final cards = load();
    final totalCount = cards.length;

    final seenCards = library.seenFlashCards;

    if (seenCards.length >= totalCount) {
      seenCards.clear();
    }

    final unseenCards = <FlashCardModel>[];
    for (final card in cards) {
      if (!seenCards.contains(card.id)) {
        unseenCards.add(card);
      }
    }

    if (unseenCards.isEmpty) {
      unseenCards.addAll(cards);
      seenCards.clear();
    }

    final currentCard = unseenCards[Random().nextInt(unseenCards.length)];

    seenCards.add(currentCard.id);

    return currentCard;
  }
}
