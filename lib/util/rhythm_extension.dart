import 'package:tiomusic/l10n/app_localization.dart';
import 'package:tiomusic/models/rhythm.dart';

extension RhythmExtension on Rhythm {
  String getLabel(AppLocalizations l10n) => switch (this) {
    Rhythm.quarter => l10n.metronomeRhythmQuarter,
    Rhythm.eighths => l10n.metronomeRhythmEighths,
    Rhythm.eighthRestFollowedByEighth => l10n.metronomeRhythmEighthRestFollowedByEighth,
    Rhythm.triplets => l10n.metronomeRhythmTriplets,
    Rhythm.sixteenths => l10n.metronomeRhythmSixteenths,
    Rhythm.sixteenthFollowedByDottedEighth => l10n.metronomeRhythmSixteenthFollowedByDottedEighth,
    Rhythm.dottedEighthFollowedBySixteenth => l10n.metronomeRhythmDottedEighthFollowedBySixteenth,
  };
}
