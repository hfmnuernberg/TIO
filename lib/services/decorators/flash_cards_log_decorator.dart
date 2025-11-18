import 'package:tiomusic/models/flash_cards.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/services/flash_cards.dart';
import 'package:tiomusic/util/log.dart';

class FlashCardsLogDecorator implements FlashCards {
  static final _logger = createPrefixLogger('FlashCards');

  final FlashCards _flashCards;

  FlashCardsLogDecorator(this._flashCards);

  @override
  List<FlashCardModel> load() {
    final cards = _flashCards.load();
    _logger.t('load(): ${cards.length} cards');
    return cards;
  }

  @override
  FlashCardModel loadRandom() {
    final card = _flashCards.loadRandom();
    _logger.t('loadRandom(): ${card.category}');
    return card;
  }

  @override
  FlashCardModel loadNext(ProjectLibrary library) {
    final card = _flashCards.loadNext(library);
    _logger.t('loadNext(): ${card.category}');
    return card;
  }
}
