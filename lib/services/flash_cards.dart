import 'package:tiomusic/domain/flash_cards/flash_card.dart';

mixin FlashCards {
  Future<void> init();

  List<FlashCard> getAll();

  Future<List<String>> getAllBookmarked();

  Future<FlashCard> getTipOfTheDay([DateTime? date]);

  Future<void> updateBookmark(String id);
}
