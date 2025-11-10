import 'package:tiomusic/domain/flash_cards/flash_card_ids.dart';
import 'package:tiomusic/l10n/flash_cards/flash_cards_localization.dart';

class FlashCardModel {
  final String id;
  final String description;
  final String category;

  const FlashCardModel({
    required this.id,
    required this.description,
    required this.category,
  });
}

class FlashCards {
  List<FlashCardModel> load(FlashCardsLocalization l10n) => flashCardSpecs
      .map((spec) => FlashCardModel(
        id: spec.id,
        description: spec.description(l10n),
        category: spec.category(l10n),
      ))
      .toList(growable: false);
}
