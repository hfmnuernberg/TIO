import 'dart:math';

import 'package:tiomusic/models/flash_cards.dart';
import 'package:tiomusic/domain/flash_cards/flash_cards_list.dart';
import 'package:tiomusic/services/flash_cards.dart';

class FlashCardsImpl implements FlashCards {
  @override
  List<FlashCardModel> load() => List.unmodifiable(flashCards);

  @override
  FlashCardModel loadRandom() {
    final cards = load();
    return cards[Random().nextInt(cards.length)];
  }
}
