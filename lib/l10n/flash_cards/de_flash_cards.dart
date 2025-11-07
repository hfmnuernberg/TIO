// overriding keys do not change something; ignored because soft warning
// ignore_for_file: annotate_overrides

import 'package:tiomusic/l10n/flash_cards/flash_cards_localization.dart';

mixin GermanFlashCards on Object implements FlashCardsLocalization {
  String get flashCardDescription =>
      'überlasse jemand anderem die Führung. Er/Sie wird dich anleiten, indem er/sie dir Anweisungen gibt oder demonstriert, wie du üben kannst.';

  String get breathOutThreeTimes => 'bevor du den Übungsraum betrittst, atme dreimal so tief aus, wie du kannst.';
  String get breakWaterBeauty => 'nimm alle 10 Minuten eine kurze Pause, um einen Schluck Wasser zu trinken und etwas in deiner Umgebung zu entdecken, das du schön findest.';
  String get meditateFiveMinBefore => 'meditiere 5 Minuten lang im Übungsraum, bevor du anfängst, dein Instrument zu spielen.';
  String get closeEyesReleaseTension => 'nimm dein Instrument auf und schließe die Augen. Spüre deinen ganzen Körper, von den Zehen bis zum Scheitel, und löse unnötige Spannungen. Baue Pausen in dein Stück ein, um dich zu entspannen.';
  String get daysOffCongratulations => 'überlege dir, wie viele freie Tage du bräuchtest, bevor du wieder üben wolltest. Definiere ab jetzt diese Anzahl an Tagen als freie Tage. Für jeden freien Tag, an dem du trotzdem übst, hast du deinen Plan übertroffen — herzlichen Glückwunsch!';

  String flashCardDescriptionById(String id) {
    switch (id) {
      case 'breathOutThreeTimes': return breathOutThreeTimes;
      case 'breakWaterBeauty': return breakWaterBeauty;
      case 'meditateFiveMinBefore': return meditateFiveMinBefore;
      case 'closeEyesReleaseTension': return closeEyesReleaseTension;
      case 'daysOffCongratulations': return daysOffCongratulations;
      default: return id;
    }
  }

  String get flashCardTitle => 'Wenn du heute übst,';

  String get flashCardsPageTitle => 'Lernkarten';
}
