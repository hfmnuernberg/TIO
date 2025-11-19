import 'package:tiomusic/models/flash_cards.dart';
import 'package:tiomusic/models/project_library.dart';

mixin FlashCards {
  List<FlashCardModel> load();

  FlashCardModel loadNext(ProjectLibrary library);

  FlashCardModel regenerateNext(ProjectLibrary library);
}
