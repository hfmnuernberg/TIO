import 'package:tiomusic/domain/flash_cards/cards/culture.dart';
import 'package:tiomusic/domain/flash_cards/cards/journaling.dart';
import 'package:tiomusic/domain/flash_cards/cards/mix_up.dart';
import 'package:tiomusic/domain/flash_cards/cards/practicing.dart';
import 'package:tiomusic/domain/flash_cards/cards/relaxation.dart';
import 'package:tiomusic/domain/flash_cards/cards/self_care.dart';
import 'package:tiomusic/domain/flash_cards/cards/team.dart';
import 'package:tiomusic/domain/flash_cards/cards/vision.dart';
import 'package:tiomusic/domain/flash_cards/flash_card.dart';

final List<FlashCard> flashCards = [
  ...cultureFlashCards,
  ...journalingFlashCards,
  ...mixUpFlashCards,
  ...practicingFlashCards,
  ...relaxationFlashCards,
  ...selfCareFlashCards,
  ...teamFlashCards,
  ...visionFlashCards,
];
