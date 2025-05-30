import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tiomusic/l10n/delegate.dart';

final localizationsDelegates = [...GlobalMaterialLocalizations.delegates, AppLocalizationsDelegate()];
const supportedLocales = [Locale('en', 'US'), Locale('de', 'DE')];
