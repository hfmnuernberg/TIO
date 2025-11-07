// overriding keys do not change something; ignored because soft warning
// ignore_for_file: annotate_overrides

import 'package:tiomusic/l10n/flash_cards/flash_cards_localization.dart';

mixin EnglishFlashCards on Object implements FlashCardsLocalization {
  String get flashCardDescription =>
      'let someone else take the lead. He/She will guide you by giving instructions or demonstrating how to practice.';
  String flashCardDescriptionById(String id) => _flashCardDescriptions[id] ?? id;

  static const Map<String, String> _flashCardDescriptions = {
    'breathOutThreeTimes': 'before entering the practice room, breathe out three times as deeply as you can.',
    'breakWaterBeauty': 'every 10 minutes, take a short break to drink a sip of water and discover something around you that you find beautiful.',
    'meditateFiveMinBefore': 'meditate in the practice room for 5 minutes before you start playing your instrument.',
    'closeEyesReleaseTension': 'pick up your instrument and close your eyes. Feel your entire body, from your toes to the top of your head, and release unnecessary tension. Build breakes into your piece to relax.',
    'daysOffCongratulations': "think about how many days off you'd need before you wanted to practice again. From now on, define that number of days as days off. For every day off that you still practice, you've exceeded your plan — congratulations!",
  };

  String get flashCardTitle => 'When you practice today,';

  String get flashCardsPageTitle => 'Flash cards';
}
