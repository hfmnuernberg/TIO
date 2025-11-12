import 'package:tiomusic/domain/flash_cards/flash_cards_list.dart';
import 'package:tiomusic/l10n/flash_cards/flash_cards_localization.dart';

enum FlashCardCategory { relaxation, team, selfCare, vision, culture, mixUp, practicingTactics, journaling }

class FlashCardModel {
  final String Function(FlashCardsLocalization l10n) category;
  final String Function(FlashCardsLocalization l10n) description;

  const FlashCardModel(this.category, this.description);
}

class FlashCards {
  List<FlashCardModel> load() => List.unmodifiable(flashCards);
}
