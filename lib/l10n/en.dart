// overriding keys do not change something; ignored because soft warning
// ignore_for_file: annotate_overrides

import 'package:tiomusic/l10n/app_localization.dart';

class English extends AppLocalizations {
  String get aboutPageAppVersion => 'App Version';
  String get aboutPageAppVersionError => 'Could not load app version.';
  String get aboutPageDataProtection => 'Data protection';
  String get aboutPageDataProtectionExplanation =>
      'We do not collect any of your data. Please note that your projects are only saved locally on your device, i.e. they are not saved in the app or in any cloud service or similar. If you decide to share individual content from within the app, this is possible via third-party services such as messenger etc. In such cases, only the data protection regulations of the third-party services used apply. You yourself are responsible for complying with applicable data protection or copyright regulations.';
  String get aboutPageDeveloper => 'Developer: Studio Fluffy';
  String get aboutPageEditor => 'Editor: University of Music Nuremberg';
  String get aboutPageFeatures => 'Features';
  String get aboutPageFirstParagraph =>
      'TIO Music integrates numerous tools (tuner, metronome, media player, piano, image notes and text notes) in one app and enables the combined use of the individual tools. By creating projects, it is possible to save different configurations and thus make practicing and making music easier. The tools can also be used individually, for quick tuning of instruments or for recording samples. TIO Music was developed by musicians for musicians of all levels of experience, for amateurs and professionals. The app is and will remain completely free of charge and ad-free.';
  String get aboutPageImage => 'Image';
  String get aboutPageImageExplanation =>
      'You can upload pictures or note sheets to the app using the camera on your device.';
  String get aboutPageImprint => 'Imprint';
  String get aboutPageMediaPlayer => 'Media player';
  String get aboutPageMediaPlayerExplanation =>
      'You can record, load and edit audio files and save configurations. In doing so, you can set your preferred volume, range (length and segment), playing speed and pitch. You can forward your projects to others using external messenger services.';
  String get aboutPageMetronome => 'Metronome';
  String get aboutPageMetronomeExplanation =>
      'The metronome allows you to save and recall your individual configurations (tempo, time signature, polyrhythms, random mute, sounds). You can also combine the metronome with the tuner and the media player.';
  String get aboutPagePiano => 'Piano';
  String get aboutPagePianoExplanation =>
      'You can use the built-in piano, select different sound modes and save your individual configurations.';
  String get aboutPageProjects => 'Projects';
  String get aboutPageProjectsExplanation =>
      'You can create projects and save the required settings there (settings for instrument tuning, metronome settings, etc.), so you can access them whenever you want.';
  String get aboutPageSecondParagraph =>
      'We aim to continuously improve the app for you - so we look forward to your feedback!';
  String get aboutPageText => 'Text';
  String get aboutPageTextExplanation =>
      'You can use your device to create text notes, e.g. for playing instructions, background information, song lyrics etc.';
  String get aboutPageThirdParagraph =>
      'This app was developed as part of the RE|LEVEL-project at Hochschule für Musik Nürnberg. RE|LEVEL is funded by Stiftung Innovation in der Hochschullehre.';
  String get aboutPageTitle => 'About';
  String get aboutPageTuner => 'Tuner';
  String get aboutPageTunerExplanation =>
      'You can tune your instruments to any concert pitch, play reference tones, save your individual configuration and combine the tuner with the metronome and media player.';

  String get commonCancel => 'Cancel';
  String get commonDelete => 'Delete?';
  String get commonNext => 'Next';
  String get commonNo => 'No';
  String get commonSubmit => 'Submit';
  String get commonYes => 'Yes';

  String get feedbackPageCta => 'Fill out';
  String get feedbackPageHint => '(For now the survey is only available in German)';
  String get feedbackPageQuestion => 'Do you like TIO Music? Please take part in this survey!';
  String get feedbackPageTitle => 'Feedback survey';

  String get home => 'Home';
  String get homeAbout => 'About';
  String get homeFeedback => 'Feedback';

  String get mediaPlayer => 'Media Player';

  String get metronome => 'Metronome';

  String get piano => 'Piano';

  String get projectDeleteAll => 'Delete all Tools';
  String get projectDeleteAllConfirmation => 'Do you really want to delete all tools in this project?';
  String get projectDeleteConfirmation => 'Do you really want to delete this tool?';
  String get projectEmpty => 'Choose Type of Tool';
  String get projectExport => 'Export Project';
  String get projectExportCancelled => 'Project export cancelled';
  String get projectExportError => 'Error exporting project';
  String get projectExportSuccess => 'Project exported successfully!';
  String get projectNew => 'Project title';
  String get projectNewTool => 'Tool title';

  String get projectsDeleteAll => 'Delete all Projects';
  String get projectsDeleteAllConfirmation => 'Do you really want to delete all projects?';
  String get projectsDeleteConfirmation => 'Do you really want to delete this project?';
  String get projectsImport => 'Import Project';
  String get projectsImportError => 'Error importing project';
  String get projectsImportNoFileSelected => 'No project file selected';
  String get projectsImportSuccess => 'Project imported successfully!';
  String get projectsNew => 'New Project';
  String get projectsNoProjects => 'Please click on "+" to create a new project.';

  String get surveyCta => 'Fill out';
  String get surveyQuestion =>
      'Do you like TIO Music? Please take part in this survey! (For now the survey is only available in German)';

  String get tuner => 'Tuner';

  String get tutorialAddProject => 'Tap here to create a new project';
  String get tutorialEditProjectTitle => 'Tap here to edit the title of your project';
  String get tutorialHowToUseTio =>
      'Welcome! You can use TIO in two ways.\n1. Create a project and add tools.\n2. Start with using a tool and save your specific settings to any project.';
  String get tutorialIncludeMultipleTools =>
      'Projects can include multiple tools\n(tuner, metronome, piano setting, media player, image and text),\neven several tools of the same type.';
  String get tutorialStart => 'Show Tutorial';
  String get tutorialStartUsingTool => 'Tap here to start using a tool';
}
