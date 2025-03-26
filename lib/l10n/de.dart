// overriding keys do not change something; ignored because soft warning
// ignore_for_file: annotate_overrides

import 'package:tiomusic/l10n/app_localization.dart';

class German extends AppLocalizations {
  String get commonDelete => 'Löschen?';
  String get commonNo => 'Nein';
  String get commonYes => 'Ja';

  String get home => 'Startseite';
  String get homeAbout => 'Über TIO Music';
  String get homeFeedback => 'Feedback';

  String get mediaPlayer => 'Media Player';

  String get metronome => 'Metronom';

  String get piano => 'Klavier';

  String get projectsDeleteAll => 'Alle Projekte löschen';
  String get projectsDeleteAllConfirmation => 'Möchtest du wirklich alle Projekte löschen?';
  String get projectsDeleteConfirmation => 'Möchtest du dieses Projekt wirklich löschen?';
  String get projectsImport => 'Projekt importieren';
  String get projectsNew => 'Neues Projekt';
  String get projectsNoProjects => 'Bitte klicke auf das "+" um ein neues Projekt zu erstellen.';

  String get surveyCta => 'Ausfüllen';
  String get surveyQuestion => 'Gefällt dir TIO Music? Bitte nimm an dieser Umfrage teil!';

  String get tuner => 'Stimmgerät';

  String get walkthroughAddProject => 'Tippe hier um ein neues Projekt zu erstellen';
  String get walkthroughHowToUseTio =>
      'Willkommen! Du kannst TIO auf zwei Arten verwenden.\n1. Erstelle ein Projekt und füge Werkzeuge hinzu.\n2. Starte mit der Verwendung eines Werkzeugs und speichere deine spezifischen Einstellungen in einem Projekt.';
  String get walkthroughIncludeMultipleTools =>
      'Projekte können mehrere Werkzeuge enthalten\n(Stimmgerät, Metronom, Klaviereinstellungen, Media Player, Bild und Text),\nsogar mehrere Werkzeuge des gleichen Typs.';
  String get walkthroughStart => 'Tutorial anzeigen';
  String get walkthroughStartUsingTool => 'Tippe hier um ein Werkzeug zu verwenden';
}
