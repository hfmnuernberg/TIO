import 'package:tiomusic/models/flash_cards.dart';
import 'package:tiomusic/domain/flash_cards/flash_cards_list.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/services/flash_cards.dart';

class FlashCardsMock implements FlashCards {
  List<FlashCardModel> cards;

  FlashCardModel? nextRandomCard;

  FlashCardsMock({List<FlashCardModel>? cards}) : cards = cards ?? flashCards;

  @override
  List<FlashCardModel> load() => cards;

  FlashCardModel _consumeNextCard() {
    if (nextRandomCard != null) {
      final card = nextRandomCard!;
      nextRandomCard = null;
      return card;
    }
    return cards.first;
  }

  @override
  FlashCardModel loadNext(ProjectLibrary library) => _consumeNextCard();

  @override
  FlashCardModel regenerateNext(ProjectLibrary library) => _consumeNextCard();
}
