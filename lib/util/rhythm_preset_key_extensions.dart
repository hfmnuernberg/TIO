import 'package:tiomusic/l10n/app_localization.dart';
import 'package:tiomusic/widgets/metronome/rhythm_preset.dart';

extension RhythmPresetKeyExtension on RhythmPresetKey {
  String getLabel(AppLocalizations l10n) => switch (this) {
    RhythmPresetKey.oneFourth => l10n.metronomeRhythmPresetOneFourth,
    RhythmPresetKey.twoEighth => l10n.metronomeRhythmPresetTwoEighth,
    RhythmPresetKey.fourSixteenth => l10n.metronomeRhythmPresetFourSixteenth,
  };
}
