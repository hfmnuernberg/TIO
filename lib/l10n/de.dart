// overriding keys do not change something; ignored because soft warning
// ignore_for_file: annotate_overrides

import 'package:tiomusic/l10n/app_localization.dart';

class German extends AppLocalizations {
  String get home => 'Startseite';

  // projects
  String get newTitle => 'Neues Projekt';

  String get backgroundText => 'Bitte klicke auf das "+" um ein neues Projekt zu erstellen.';

  String get delete => 'Löschen?';
  String get deleteAllProjectsQuestion => 'Möchtest du wirklich alle Projekte löschen?';
  String get deleteSingleProjectQuestion => 'Möchtest du dieses Projekt wirklich löschen?';
  String get yes => 'Ja';
  String get no => 'Nein';

  String get askForSurvey => 'Gefällt dir TIO Music? Bitte nimm an dieser Umfrage teil!';
  String get fillOutButton => 'Ausfüllen';

  // tools
  String get metronome => 'Metronom';
  String get mediaPlayer => 'Media Player';
  String get tuner => 'Stimmgerät';
  String get piano => 'Klavier';

  // walkthrough

  // menu
  String get about => 'Über TIO Music';
  String get feedback => 'Feedback';
  String get importProject => 'Projekt importieren';
  String get deleteAllProjects => 'Alle Projekte löschen';
  String get showWalkthrough => 'Anleitung anzeigen';
}
