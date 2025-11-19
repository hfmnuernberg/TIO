import 'dart:math';

import 'package:tiomusic/models/flash_cards.dart';
import 'package:tiomusic/domain/flash_cards/flash_cards_list.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/services/flash_cards.dart';

bool isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

FlashCardModel? findCardById(List<FlashCardModel> cards, String id) {
  for (final card in cards) {
    if (card.id == id) return card;
  }
  return null;
}

FlashCardModel pickNewCard(ProjectLibrary library, DateTime now, List<FlashCardModel> cards) {
  final seenCards = library.seenFlashCards;
  final unseenCards = <FlashCardModel>[];

  if (seenCards.length >= cards.length) seenCards.clear();

  for (final card in cards) {
    final alreadySeen = seenCards.any((seen) => seen.id == card.id);
    if (!alreadySeen) unseenCards.add(card);
  }

  if (unseenCards.isEmpty) {
    unseenCards.addAll(cards);
    seenCards.clear();
  }

  final currentCard = unseenCards[Random().nextInt(unseenCards.length)];

  seenCards.add(SeenFlashCard(id: currentCard.id, seenAt: now));

  return currentCard;
}

class FlashCardsImpl implements FlashCards {
  @override
  List<FlashCardModel> load() => List.unmodifiable(flashCards);

  @override
  FlashCardModel loadNext(ProjectLibrary library) {
    final now = DateTime.now();
    final cards = load();
    final seenCards = library.seenFlashCards;

    SeenFlashCard? todaysEntry;

    for (var i = seenCards.length - 1; i >= 0; i--) {
      final card = seenCards[i];

      if (isSameDay(card.seenAt, now)) {
        todaysEntry = card;
        break;
      }
    }

    if (todaysEntry != null) {
      final todayCard = findCardById(cards, todaysEntry.id);

      if (todayCard != null) {
        return todayCard;
      }
    }

    return pickNewCard(library, now, cards);
  }

  @override
  FlashCardModel regenerateNext(ProjectLibrary library) => pickNewCard(library, DateTime.now(), load());
}
