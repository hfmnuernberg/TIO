import 'package:tiomusic/domain/flash_cards/flash_cards.dart';

mixin FlashCards {
  List<FlashCardModel> load();

  FlashCardModel loadRandom();
}
