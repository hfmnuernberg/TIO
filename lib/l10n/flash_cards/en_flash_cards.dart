// overriding keys do not change something; ignored because soft warning
// ignore_for_file: annotate_overrides

import 'package:tiomusic/l10n/flash_cards/flash_cards_localization.dart';

mixin EnglishFlashCards on Object implements FlashCardsLocalization {
  String get flashCardDescription =>
      'let someone else take the lead. He/She will guide you by giving instructions or demonstrating how to practice.';
  String get flashCardTitle => 'When you practice today,';

  String get flashCardsPageTitle => 'Flash cards';
}
