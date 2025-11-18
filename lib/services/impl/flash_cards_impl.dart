import 'dart:math';

import 'package:tiomusic/models/flash_cards.dart';
import 'package:tiomusic/domain/flash_cards/flash_cards_list.dart';
import 'package:tiomusic/services/flash_cards.dart';

class FlashCardsImpl implements FlashCards {
  final Random _random;

  FlashCardsImpl({Random? random}) : _random = random ?? Random();

  @override
  List<FlashCardModel> load() => List.unmodifiable(flashCards);

  @override
  FlashCardModel loadRandom() {
    final cards = load();
    return cards[_random.nextInt(cards.length)];
  }
}
