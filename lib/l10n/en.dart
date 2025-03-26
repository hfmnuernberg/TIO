// overriding keys do not change something; ignored because soft warning
// ignore_for_file: annotate_overrides

import 'package:tiomusic/l10n/app_localization.dart';

class English extends AppLocalizations {
  String get home => 'Home';

  // projects
  String get newTitle => 'New Project';

  String get backgroundText => 'Please click on "+" to create a new project.';

  String get delete => 'Delete?';
  String get deleteAllProjects => 'Do you really want to delete all projects?';
  String get deleteSingleProject => 'Do you really want to delete this project?';
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
}
