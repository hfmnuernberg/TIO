import 'package:tiomusic/l10n/app_localization.dart';
import 'package:tiomusic/models/tuner_type.dart';

extension TunerTypeLabel on TunerType {
  String getLabel(AppLocalizations l10n) => switch (this) {
    TunerType.chromatic => l10n.tunerTypeChromatic,
    TunerType.guitar => l10n.tunerTypeGuitar,
    TunerType.electricBass => l10n.tunerTypeElectricBass,
    TunerType.doubleBass => l10n.tunerTypeDoubleBass,
    TunerType.ukulele => l10n.tunerTypeUkulele,
    TunerType.violin => l10n.tunerTypeViolin,
    TunerType.viola => l10n.tunerTypeViola,
  };
}
