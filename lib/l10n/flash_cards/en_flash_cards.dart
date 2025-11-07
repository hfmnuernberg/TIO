// overriding keys do not change something; ignored because soft warning
// ignore_for_file: annotate_overrides

import 'package:tiomusic/l10n/flash_cards/flash_cards_localization.dart';

mixin EnglishFlashCards on Object implements FlashCardsLocalization {
  String get descriptionAskSomeoneToObserveYou =>
      'ask someone to observe you while practicing. What advice can he/she give you?';
  String get descriptionBreakWaterBeauty =>
      'every 10 minutes, take a short break to drink a sip of water and discover something around you that you find beautiful.';
  String get descriptionBreathOutThreeTimes =>
      'before entering the practice room, breathe out three times as deeply as you can.';
  String get descriptionCloseEyesReleaseTension =>
      'pick up your instrument and close your eyes. Feel your entire body, from your toes to the top of your head, and release unnecessary tension. Build breakes into your piece to relax.';
  String get descriptionDaysOffCongratulations =>
      "think about how many days off you'd need before you wanted to practice again. From now on, define that number of days as days off. For every day off that you still practice, you've exceeded your plan — congratulations!";
  String get descriptionDescribeGoalTogether => 'describe a goal to someone and think about ways to get there.';
  String get descriptionLetSomeoneElseLead =>
      'let someone else take the lead. He/She will guide you by giving instructions or demonstrating how to practice.';
  String get descriptionMeditateFiveMinBefore =>
      'meditate in the practice room for 5 minutes before you start playing your instrument.';
  String get descriptionPlayWithDroneSupport =>
      'get someone to play the tonic of the phrase as a drone while you practice. Play your piece with open ears.';
  String get descriptionTellObstacleAndBrainstorm =>
      'tell someone about one of your obstacles and brainstorm solutions together.';

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

  String get flashCardTitle => 'When you practice today,';

  String get flashCardsPageTitle => 'Practice tips';
}
