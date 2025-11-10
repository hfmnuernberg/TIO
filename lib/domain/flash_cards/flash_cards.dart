import 'package:tiomusic/domain/flash_cards/flash_card_ids.dart';
import 'package:tiomusic/l10n/flash_cards/flash_cards_localization.dart';

extension FlashCardCategoryL10n on FlashCardCategory {
  String label(FlashCardsLocalization l10n) => switch (this) {
    FlashCardCategory.relaxation => l10n.categoryRelaxation,
    FlashCardCategory.team => l10n.categoryTeam,
    FlashCardCategory.selfCare => l10n.categorySelfCare,
    FlashCardCategory.vision => l10n.categoryVision,
    FlashCardCategory.culture => l10n.categoryCulture,
    FlashCardCategory.mixUp => l10n.categoryMixUp,
    FlashCardCategory.practicingTactics => l10n.categoryPracticingTactics,
    FlashCardCategory.journaling => l10n.categoryJournaling,
  };
}

class FlashCardModel {
  final String id;
  final String description;
  final FlashCardCategory category;

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
        description: l10n.flashCardDescriptionById(spec.id),
        category: spec.category,
      ))
      .toList(growable: false);
}
