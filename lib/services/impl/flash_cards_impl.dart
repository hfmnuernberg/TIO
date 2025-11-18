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

    final seenFlashCards = library.seenFlashCards;

    if (seenFlashCards.length >= totalCount) {
      seenFlashCards.clear();
    }

    final unseenFlashCards = <int>[];
    for (var i = 0; i < totalCount; i++) {
      if (!seenFlashCards.contains(i)) {
        unseenFlashCards.add(i);
      }
    }

    if (unseenFlashCards.isEmpty) {
      for (var i = 0; i < totalCount; i++) {
        unseenFlashCards.add(i);
      }
      seenFlashCards.clear();
    }

    final currentIndex = unseenFlashCards[Random().nextInt(unseenFlashCards.length)];
    seenFlashCards.add(currentIndex);

    return cards[currentIndex];
  }
}
