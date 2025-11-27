import 'package:tiomusic/domain/flash_cards/flash_card.dart';
import 'package:tiomusic/services/flash_cards.dart';
import 'package:tiomusic/util/log.dart';

class FlashCardsLogDecorator implements FlashCards {
  static final _logger = createPrefixLogger('FlashCards');

  final FlashCards _flashCards;

  FlashCardsLogDecorator(this._flashCards);

  @override
  Future<void> init() {
    _logger.t('init()');
    return _flashCards.init();
  }

  @override
  List<FlashCard> getAll() {
    final cards = _flashCards.getAll();
    _logger.t('getAll(): ${cards.length} cards');
    return cards;
  }

  @override
  Future<List<String>> getAllBookmarked() async {
    final cardIds = await _flashCards.getAllBookmarked();
    _logger.t('getAllBookmarked(): ${cardIds.length} cards');
    return cardIds;
  }

  @override
  Future<FlashCard> getTipOfTheDay([DateTime? date]) async {
    final card = await _flashCards.getTipOfTheDay(date);
    _logger.t('getTipOfTheDay($date): ${card.id}');
    return card;
  }

  @override
  Future<void> updateBookmark(String id) async {
    _logger.t('updateBookmark($id)');
    await _flashCards.updateBookmark(id);
  }
}
