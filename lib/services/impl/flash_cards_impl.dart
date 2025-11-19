import 'dart:math';

import 'package:tiomusic/models/flash_cards.dart';
import 'package:tiomusic/domain/flash_cards/flash_cards_list.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/services/flash_cards.dart';

class FlashCardsImpl implements FlashCards {
  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  FlashCardModel? _findCardById(List<FlashCardModel> cards, String id) {
    for (final card in cards) {
      if (card.id == id) return card;
    }
    return null;
  }

  FlashCardModel _pickNewCard(ProjectLibrary library, DateTime now, List<FlashCardModel> cards) {
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

      if (_isSameDay(card.seenAt, now)) {
        todaysEntry = card;
        break;
      }
    }

    if (todaysEntry != null) {
      final todayCard = _findCardById(cards, todaysEntry.id);

      if (todayCard != null) {
        return todayCard;
      }
    }

    return _pickNewCard(library, now, cards);
  }

  @override
  FlashCardModel regenerateNext(ProjectLibrary library) => _pickNewCard(library, DateTime.now(), load());
}
