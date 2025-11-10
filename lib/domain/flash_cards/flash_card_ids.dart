enum FlashCardCategory { relaxation, team, selfCare, vision, culture, mixUp, practicingTactics, journaling }

class FlashCardSpec {
  final String id;
  final FlashCardCategory category;

  const FlashCardSpec(this.id, this.category);
}

const List<FlashCardSpec> flashCardSpecs = [
  FlashCardSpec('descriptionAskSomeoneToObserveYou', FlashCardCategory.team),
  FlashCardSpec('descriptionBreakWaterBeauty', FlashCardCategory.selfCare),
  FlashCardSpec('descriptionBreathOutThreeTimes', FlashCardCategory.relaxation),
  FlashCardSpec('descriptionCloseEyesReleaseTension', FlashCardCategory.relaxation),
  FlashCardSpec('descriptionDaysOffCongratulations', FlashCardCategory.selfCare),
  FlashCardSpec('descriptionDescribeGoalTogether', FlashCardCategory.team),
  FlashCardSpec('descriptionLetSomeoneElseLead', FlashCardCategory.team),
  FlashCardSpec('descriptionMeditateFiveMinBefore', FlashCardCategory.relaxation),
  FlashCardSpec('descriptionPlayWithDroneSupport', FlashCardCategory.practicingTactics),
  FlashCardSpec('descriptionTellObstacleAndBrainstorm', FlashCardCategory.team),
];
