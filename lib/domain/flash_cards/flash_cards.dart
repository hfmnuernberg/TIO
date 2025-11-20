import 'package:flutter/material.dart';
import 'package:tiomusic/domain/flash_cards/flash_cards_list.dart';
import 'package:tiomusic/l10n/flash_cards/flash_cards_localization.dart';

enum FlashCardCategory {
  relaxation(Icons.self_improvement),
  team(Icons.group),
  selfCare(Icons.volunteer_activism),
  vision(Icons.filter_tilt_shift),
  culture(Icons.museum),
  mixUp(Icons.category),
  practicingTactics(Icons.auto_graph),
  journaling(Icons.edit_note);

  final IconData icon;
  const FlashCardCategory(this.icon);
}

class FlashCardModel {
  final FlashCardCategory category;
  final String Function(FlashCardsLocalization l10n) description;

  const FlashCardModel(this.category, this.description);
}

class FlashCards {
  List<FlashCardModel> load() => List.unmodifiable(flashCards);
}
