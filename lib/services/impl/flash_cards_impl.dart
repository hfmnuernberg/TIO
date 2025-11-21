import 'dart:math';

import 'package:collection/collection.dart';
import 'package:tiomusic/domain/flash_cards/flash_card.dart';
import 'package:tiomusic/domain/flash_cards/flash_cards_list.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/models/seen_flash_card.dart';
import 'package:tiomusic/services/flash_cards.dart';
import 'package:tiomusic/services/project_repository.dart';

class FlashCardsImpl implements FlashCards {
  final ProjectRepository _projectRepo;
  final Random _random;

  FlashCardsImpl(this._projectRepo, [Random? random]) : _random = random ?? Random();

  @override
  List<FlashCard> getAll() => List.unmodifiable(flashCards);

  @override
  Future<FlashCard> getTipOfTheDay([DateTime? date]) async {
    final library = await _projectRepo.loadLibrary();
    final allCards = getAll();
    final suggestedCards = library.seenFlashCards;

    if (date != null) {
      final todaysCard = _getTodaysCard(allCards, suggestedCards, date);
      if (todaysCard != null) return todaysCard;
    }

    if (suggestedCards.length == allCards.length) suggestedCards.clear();

    FlashCard? newCard = _getNewCard(allCards, suggestedCards);

    await _rememberSuggestedCard(newCard!, library);

    return newCard;
  }

  FlashCard? _getTodaysCard(List<FlashCard> allCards, List<SeenFlashCard> suggestedCards, DateTime date) {
    final todaysCard = suggestedCards.firstWhereOrNull((suggested) => _isSameDay(suggested.seenAt, date));
    return todaysCard == null ? null : allCards.firstWhere((card) => card.id == todaysCard.id);
  }

  FlashCard? _getNewCard(List<FlashCard> allCards, List<SeenFlashCard> suggestedCards) {
    final remainingCards = allCards
        .whereNot((card) => suggestedCards.any((suggested) => suggested.id == card.id))
        .toList();

    return remainingCards.isEmpty ? null : remainingCards[_random.nextInt(remainingCards.length)];
  }

  Future<void> _rememberSuggestedCard(FlashCard card, ProjectLibrary library) async {
    library.seenFlashCards.add(SeenFlashCard(id: card.id, seenAt: DateTime.now()));
    await _projectRepo.saveLibrary(library);
  }

  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}
