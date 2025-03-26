import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/en.dart';
import 'package:tiomusic/l10n/app_localization.dart';

extension AppLocalizationsExtension on BuildContext {
  AppLocalizations get l10n {
    return Localizations.of<AppLocalizations>(this, AppLocalizations) ?? English();
  }
}
