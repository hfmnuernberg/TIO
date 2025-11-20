import 'package:tiomusic/models/flash_cards.dart';
import 'package:tiomusic/domain/flash_cards/flash_cards_list.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/services/impl/flash_cards_impl.dart';

class FlashCardsMock extends FlashCardsImpl {
  List<FlashCardModel> cards;

  FlashCardModel? nextRandomCard;

  FlashCardsMock({List<FlashCardModel>? cards}) : cards = cards ?? flashCards;

  @override
  List<FlashCardModel> load() => cards;

  FlashCardModel _consumeNextCard(ProjectLibrary library, FlashCardModel Function() realImplementation) {
    if (nextRandomCard != null) {
      final card = nextRandomCard!;
      nextRandomCard = null;

      library.seenFlashCards.add(SeenFlashCard(id: card.id, seenAt: DateTime.now()));

      return card;
    }
    return realImplementation();
  }

  @override
  FlashCardModel loadNext(ProjectLibrary library) => _consumeNextCard(library, () => super.loadNext(library));

  @override
  FlashCardModel regenerateNext(ProjectLibrary library) =>
      _consumeNextCard(library, () => super.regenerateNext(library));
}
