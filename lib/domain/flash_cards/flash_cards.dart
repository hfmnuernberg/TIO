import 'package:tiomusic/domain/flash_cards/flash_card_ids.dart';
import 'package:tiomusic/l10n/flash_cards/flash_cards_localization.dart';

class FlashCardModel {
  final String id;
  final String title;
  final String description;
  const FlashCardModel({required this.id, required this.title, required this.description});
}

class FlashCards {
  List<FlashCardModel> load(FlashCardsLocalization l10n) => flashCardIds
      .map((id) => FlashCardModel(id: id, title: l10n.flashCardTitle, description: l10n.flashCardDescriptionById(id)))
      .toList(growable: false);
}
