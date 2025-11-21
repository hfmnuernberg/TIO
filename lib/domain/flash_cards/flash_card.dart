import 'package:tiomusic/domain/flash_cards/flash_card_category.dart';
import 'package:tiomusic/l10n/flash_cards/flash_cards_localization.dart';

class FlashCard {
  final String id;
  final FlashCardCategory category;
  // TODO(davidbieder): domain class shouldn't know about l10n
  final String Function(FlashCardsLocalization l10n) description;

  const FlashCard(this.id, this.category, this.description);
}
