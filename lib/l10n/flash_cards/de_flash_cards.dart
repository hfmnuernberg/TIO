// overriding keys do not change something; ignored because soft warning
// ignore_for_file: annotate_overrides

import 'package:tiomusic/l10n/flash_cards/flash_cards_localization.dart';

mixin GermanFlashCards on Object implements FlashCardsLocalization {
  String get categoryCulture => 'Kultur';
  String get categoryJournaling => 'Tagebuch';
  String get categoryMixUp => 'Abwechslung';
  String get categoryPracticingTactics => 'Übungstaktik';
  String get categoryRelaxation => 'Entspannung';
  String get categorySelfCare => 'Selbstfürsorge';
  String get categoryTeam => 'Team';
  String get categoryVision => 'Vision';

  String get descriptionAskSomeoneToObserveYou =>
      'bitte jemanden, dich beim Üben zu beobachten. Welchen Rat kann er oder sie dir geben?';
  String get descriptionBreakWaterBeauty =>
      'nimm alle 10 Minuten eine kurze Pause, um einen Schluck Wasser zu trinken und etwas in deiner Umgebung zu entdecken, das du schön findest.';
  String get descriptionBreathOutThreeTimes =>
      'bevor du den Übungsraum betrittst, atme dreimal so tief aus, wie du kannst.';
  String get descriptionCloseEyesReleaseTension =>
      'nimm dein Instrument auf und schließe die Augen. Spüre deinen ganzen Körper, von den Zehen bis zum Scheitel, und löse unnötige Spannungen. Baue Pausen in dein Stück ein, um dich zu entspannen.';
  String get descriptionDaysOffCongratulations =>
      'überlege dir, wie viele freie Tage du bräuchtest, bevor du wieder üben wolltest. Definiere ab jetzt diese Anzahl an Tagen als freie Tage. Für jeden freien Tag, an dem du trotzdem übst, hast du deinen Plan übertroffen — herzlichen Glückwunsch!';
  String get descriptionDescribeGoalTogether =>
      'beschreibe jemandem ein Ziel und überlegt gemeinsam, wie ihr es erreichen könnt.';
  String get descriptionLetSomeoneElseLead =>
      'überlasse jemand anderem die Führung. Er oder sie wird dich anleiten, indem er oder sie Anweisungen gibt oder demonstriert, wie du üben kannst.';
  String get descriptionMeditateFiveMinBefore =>
      'meditiere 5 Minuten lang im Übungsraum, bevor du anfängst, dein Instrument zu spielen.';
  String get descriptionPlayWithDroneSupport =>
      'bitte jemanden, während du übst, den Grundton der Phrase als Bordunton zu spielen. Spiele dein Stück mit offenen Ohren.';
  String get descriptionTellObstacleAndBrainstorm =>
      'erzähle jemandem von einem deiner Hindernisse und sucht gemeinsam nach Lösungen.';

  String flashCardDescriptionById(String id) => switch (id) {
    'descriptionAskSomeoneToObserveYou' => descriptionAskSomeoneToObserveYou,
    'descriptionBreakWaterBeauty' => descriptionBreakWaterBeauty,
    'descriptionBreathOutThreeTimes' => descriptionBreathOutThreeTimes,
    'descriptionCloseEyesReleaseTension' => descriptionCloseEyesReleaseTension,
    'descriptionDaysOffCongratulations' => descriptionDaysOffCongratulations,
    'descriptionDescribeGoalTogether' => descriptionDescribeGoalTogether,
    'descriptionLetSomeoneElseLead' => descriptionLetSomeoneElseLead,
    'descriptionMeditateFiveMinBefore' => descriptionMeditateFiveMinBefore,
    'descriptionPlayWithDroneSupport' => descriptionPlayWithDroneSupport,
    'descriptionTellObstacleAndBrainstorm' => descriptionTellObstacleAndBrainstorm,
    _ => id,
  };

  String get flashCardTitle => 'Wenn du heute übst,';

  String get flashCardsPageTitle => 'Übungstipps';
}
