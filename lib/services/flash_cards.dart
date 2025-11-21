import 'package:tiomusic/domain/flash_cards/flash_card.dart';

mixin FlashCards {
  List<FlashCard> getAll();

  Future<FlashCard> getTipOfTheDay([DateTime? date]);
}
