import 'package:flutter/material.dart';
import 'package:tiomusic/domain/flash_cards/flash_card_category.dart';

extension FlashCardCategoryExtension on FlashCardCategory {
  IconData get icon => switch (this) {
    FlashCardCategory.relaxation => Icons.self_improvement,
    FlashCardCategory.team => Icons.group,
    FlashCardCategory.selfCare => Icons.volunteer_activism,
    FlashCardCategory.vision => Icons.filter_tilt_shift,
    FlashCardCategory.culture => Icons.museum,
    FlashCardCategory.mixUp => Icons.category,
    FlashCardCategory.practicing => Icons.auto_graph,
    FlashCardCategory.journaling => Icons.edit_note,
  };
}
