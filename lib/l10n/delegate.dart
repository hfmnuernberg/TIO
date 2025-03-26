import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tiomusic/l10n/de.dart';
import 'package:tiomusic/l10n/en.dart';
import 'package:tiomusic/l10n/l10n.dart';

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  @override
  Future<AppLocalizations> load(Locale locale) {
    return Future(() {
      if (locale.languageCode.toLowerCase().startsWith('de')) {
        Intl.defaultLocale = 'de_DE';
        return German();
      } else {
        Intl.defaultLocale = 'en_US';
        return English();
      }
    });
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;

  @override
  bool isSupported(Locale locale) => ['en', 'de'].contains(locale.languageCode.toLowerCase());
}
