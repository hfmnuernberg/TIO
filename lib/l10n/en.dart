// overriding keys do not change something; ignored because soft warning
// ignore_for_file: annotate_overrides

import 'package:tiomusic/l10n/app_localization.dart';

class English extends AppLocalizations {
  String get home => 'Home';

  // projects
  String get newTitle => 'New Project';

  String get backgroundText => 'Please click on "+" to create a new project.';

  String get delete => 'Delete?';
  String get deleteAllProjectsQuestion => 'Do you really want to delete all projects?';
  String get deleteSingleProjectQuestion => 'Do you really want to delete this project?';
  String get yes => 'Yes';
  String get no => 'No';

  String get askForSurvey =>
      'Do you like TIO Music? Please take part in this survey! (For now the survey is only available in German)';
  String get fillOutButton => 'Fill out';

  // tools
  String get metronome => 'Metronome';
  String get mediaPlayer => 'Media Player';
  String get tuner => 'Tuner';
  String get piano => 'Piano';

  // walkthrough
  String get walkthroughAddProject => 'Tap here to create a new project';
  String get walkthroughStartUsingTool => 'Tap here to start using a tool';
  String get walkthroughHowToUseTio =>
      'Welcome! You can use TIO in two ways.\n1. Create a project and add tools.\n2. Start with using a tool and save your specific settings to any project.';
  String get walkthroughIncludeMultipleTools =>
      'Projects can include multiple tools\n(tuner, metronome, piano setting, media player, image and text),\neven several tools of the same type.';

  // menu
  String get about => 'About';
  String get feedback => 'Feedback';
  String get importProject => 'Import Project';
  String get deleteAllProjects => 'Delete all Projects';
  String get showWalkthrough => 'Show Walkthrough';
}
