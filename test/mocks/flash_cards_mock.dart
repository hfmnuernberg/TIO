import 'package:tiomusic/domain/flash_cards/flash_cards.dart';
import 'package:tiomusic/domain/flash_cards/flash_cards_list.dart';
import 'package:tiomusic/services/flash_cards.dart';

class FlashCardsMock implements FlashCards {
  List<FlashCardModel> cards;

  FlashCardModel? nextRandomCard;

  FlashCardsMock({List<FlashCardModel>? cards}) : cards = cards ?? flashCards;

  @override
  List<FlashCardModel> load() => cards;

  @override
  FlashCardModel loadRandom() {
    if (nextRandomCard != null) {
      final card = nextRandomCard!;
      nextRandomCard = null;
      return card;
    }

    return cards.first;
  }
}
