import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/en.dart';
import 'package:tiomusic/l10n/l10n.dart';

extension AppLocalizationsExtension on BuildContext {
  AppLocalizations get l10n {
    return Localizations.of<AppLocalizations>(this, AppLocalizations) ?? English();
  }
}
