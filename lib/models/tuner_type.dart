import 'package:tiomusic/l10n/app_localization.dart';

enum TunerType { chromatic, guitar }

extension TunerTypeLabel on TunerType {
  String getLabel(AppLocalizations l10n) {
    switch (this) {
      case TunerType.chromatic:
        return l10n.tunerTypeChromatic;
      case TunerType.guitar:
        return l10n.tunerTypeGuitar;
    }
  }
}
