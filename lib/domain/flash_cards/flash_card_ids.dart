import 'package:tiomusic/l10n/flash_cards/flash_cards_localization.dart';

enum FlashCardCategory { relaxation, team, selfCare, vision, culture, mixUp, practicingTactics, journaling }

class FlashCardSpec {
  final String id;
  final String Function(FlashCardsLocalization l10n) category;
  final String Function(FlashCardsLocalization l10n) description;

  const FlashCardSpec(this.id, this.category, this.description);
}

List<FlashCardSpec> flashCardSpecs = [
  FlashCardSpec('descriptionAskSomeoneToObserveYou', (l10n) => l10n.categoryTeam, (l10n) => l10n.descriptionAskSomeoneToObserveYou),
  FlashCardSpec('descriptionBreakWaterBeauty', (l10n) => l10n.categorySelfCare, (l10n) => l10n.descriptionBreakWaterBeauty),
  FlashCardSpec('descriptionBreathOutThreeTimes', (l10n) => l10n.categoryRelaxation, (l10n) => l10n.descriptionBreathOutThreeTimes),
  FlashCardSpec('descriptionCloseEyesReleaseTension', (l10n) => l10n.categoryRelaxation, (l10n) => l10n.descriptionCloseEyesReleaseTension),
  FlashCardSpec('descriptionDaysOffCongratulations', (l10n) => l10n.categorySelfCare, (l10n) => l10n.descriptionDaysOffCongratulations),
  FlashCardSpec('descriptionDescribeGoalTogether', (l10n) => l10n.categoryTeam, (l10n) => l10n.descriptionDescribeGoalTogether),
  FlashCardSpec('descriptionLetSomeoneElseLead', (l10n) => l10n.categoryTeam, (l10n) => l10n.descriptionLetSomeoneElseLead),
  FlashCardSpec('descriptionMeditateFiveMinBefore', (l10n) => l10n.categoryRelaxation, (l10n) => l10n.descriptionMeditateFiveMinBefore),
  FlashCardSpec('descriptionPlayWithDroneSupport', (l10n) => l10n.categoryPracticingTactics, (l10n) => l10n.descriptionPlayWithDroneSupport),
  FlashCardSpec('descriptionTellObstacleAndBrainstorm', (l10n) => l10n.categoryTeam, (l10n) => l10n.descriptionTellObstacleAndBrainstorm),
];
