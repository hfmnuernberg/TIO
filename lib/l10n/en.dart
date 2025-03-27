// overriding keys do not change something; ignored because soft warning
// ignore_for_file: annotate_overrides

import 'package:tiomusic/l10n/app_localization.dart';

class English extends AppLocalizations {
  String get commonDelete => 'Delete?';
  String get commonNo => 'No';
  String get commonYes => 'Yes';

  String get home => 'Home';
  String get homeAbout => 'About';
  String get homeFeedback => 'Feedback';

  String get mediaPlayer => 'Media Player';

  String get metronome => 'Metronome';

  String get piano => 'Piano';

  String get projectsDeleteAll => 'Delete all Projects';
  String get projectsDeleteAllConfirmation => 'Do you really want to delete all projects?';
  String get projectsDeleteConfirmation => 'Do you really want to delete this project?';
  String get projectsImport => 'Import Project';
  String get projectsNew => 'New Project';
  String get projectsNoProjects => 'Please click on "+" to create a new project.';

  String get surveyCta => 'Fill out';
  String get surveyQuestion =>
      'Do you like TIO Music? Please take part in this survey! (For now the survey is only available in German)';

  String get tuner => 'Tuner';

  String get tutorialAddProject => 'Tap here to create a new project';
  String get tutorialHowToUseTio =>
      'Welcome! You can use TIO in two ways.\n1. Create a project and add tools.\n2. Start with using a tool and save your specific settings to any project.';
  String get tutorialIncludeMultipleTools =>
      'Projects can include multiple tools\n(tuner, metronome, piano setting, media player, image and text),\neven several tools of the same type.';
  String get tutorialStart => 'Show Tutorial';
  String get tutorialStartUsingTool => 'Tap here to start using a tool';
}
