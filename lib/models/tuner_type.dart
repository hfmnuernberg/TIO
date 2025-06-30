import 'package:tiomusic/l10n/app_localization.dart';

enum TunerType { chromatic, guitar }

extension TunerTypeLabel on TunerType {
  String getLabel(AppLocalizations l10n) => switch (this) {
    TunerType.chromatic => l10n.tunerTypeChromatic,
    TunerType.guitar => l10n.tunerTypeGuitar,
  };
}
