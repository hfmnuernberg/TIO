// overriding keys do not change something; ignored because soft warning
// ignore_for_file: annotate_overrides

import 'package:tiomusic/l10n/flash_cards/flash_cards_localization.dart';

mixin GermanFlashCards on Object implements FlashCardsLocalization {
  String get flashCardDescription =>
      'überlasse jemand anderem die Führung. Er/Sie wird dich anleiten, indem er/sie dir Anweisungen gibt oder demonstriert, wie du üben kannst.';
  String get flashCardTitle => 'Wenn du heute übst,';

  String get flashCardsPageTitle => 'Lernkarten';
}
