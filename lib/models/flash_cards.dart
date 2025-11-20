import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/flash_cards/flash_cards_localization.dart';

enum FlashCardCategory {
  relaxation(Icons.self_improvement),
  team(Icons.diversity_1),
  selfCare(Icons.health_and_safety),
  vision(Icons.tips_and_updates),
  culture(Icons.museum),
  mixUp(Icons.category),
  practicing(Icons.playlist_add_check),
  journaling(Icons.auto_stories);

  final IconData icon;
  const FlashCardCategory(this.icon);
}

class FlashCardModel {
  final String id;
  final FlashCardCategory category;
  final String Function(FlashCardsLocalization l10n) description;

  const FlashCardModel(this.id, this.category, this.description);
}
