import 'package:tiomusic/models/flash_cards.dart';

mixin FlashCards {
  List<FlashCardModel> load();

  FlashCardModel loadRandom();
}
