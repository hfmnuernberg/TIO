import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/flash_cards/flash_cards_localization.dart';

enum FlashCardCategory {
  relaxation(Icons.self_improvement),
  team(Icons.group),
  selfCare(Icons.volunteer_activism),
  vision(Icons.filter_tilt_shift),
  culture(Icons.museum),
  mixUp(Icons.category),
  practicing(Icons.auto_graph),
  journaling(Icons.edit_note);

  final IconData icon;
  const FlashCardCategory(this.icon);
}

class FlashCardModel {
  final String id;
  final FlashCardCategory category;
  final String Function(FlashCardsLocalization l10n) description;

  const FlashCardModel(this.id, this.category, this.description);
}
