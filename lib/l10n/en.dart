// overriding keys do not change something; ignored because soft warning
// ignore_for_file: annotate_overrides

import 'package:tiomusic/l10n/app_localization.dart';

class English extends AppLocalizations {
  String get aboutAppVersion => 'App Version';
  String get aboutAppVersionError => 'Could not load app version.';
  String get aboutDataProtection => 'Data protection';
  String get aboutDataProtectionExplanation =>
      'We do not collect any of your data. Please note that your projects are only saved locally on your device, i.e. they are not saved in the app or in any cloud service or similar. If you decide to share individual content from within the app, this is possible via third-party services such as messenger etc. In such cases, only the data protection regulations of the third-party services used apply. You yourself are responsible for complying with applicable data protection or copyright regulations.';
  String get aboutDeveloperOne => 'Developer: cultivate(software)';
  String get aboutDeveloperTwo => 'Developer: Studio Fluffy';
  String get aboutEditor => 'Editor: University of Music Nuremberg';
  String get aboutFeatures => 'Features';
  String get aboutFirstParagraph =>
      'TIO Music integrates numerous tools (tuner, metronome, media player, piano, image notes and text notes) in one app and enables the combined use of the individual tools. By creating projects, it is possible to save different configurations and thus make practicing and making music easier. The tools can also be used individually, for quick tuning of instruments or for recording samples. TIO Music was developed by musicians for musicians of all levels of experience, for amateurs and professionals. The app is and will remain completely free of charge and ad-free.';
  String get aboutImage => 'Image';
  String get aboutImageExplanation =>
      'You can upload pictures or note sheets to the app using the camera on your device.';
  String get aboutImprint => 'Imprint';
  String get aboutMediaPlayer => 'Media player';
  String get aboutMediaPlayerExplanation =>
      'You can record, load and edit audio files and save configurations. In doing so, you can set your preferred volume, range (length and segment), playing speed and pitch. You can forward your projects to others using external messenger services.';
  String get aboutMetronome => 'Metronome';
  String get aboutMetronomeExplanation =>
      'The metronome allows you to save and recall your individual configurations (tempo, time signature, polyrhythms, random mute, sounds). You can also combine the metronome with the tuner and the media player.';
  String get aboutPiano => 'Piano';
  String get aboutPianoExplanation =>
      'You can use the built-in piano, select different sound modes and save your individual configurations.';
  String get aboutProjects => 'Projects';
  String get aboutProjectsExplanation =>
      'You can create projects and save the required settings there (settings for instrument tuning, metronome settings, etc.), so you can access them whenever you want.';
  String get aboutSecondParagraph =>
      'We aim to continuously improve the app for you - so we look forward to your feedback!';
  String get aboutText => 'Text';
  String get aboutTextExplanation =>
      'You can use your device to create text notes, e.g. for playing instructions, background information, song lyrics etc.';
  String get aboutThirdParagraph =>
      'This app was developed as part of the RE|LEVEL-project at Hochschule für Musik Nürnberg. RE|LEVEL is funded by Stiftung Innovation in der Hochschullehre.';
  String get aboutTitle => 'About';
  String get aboutTuner => 'Tuner';
  String get aboutTunerExplanation =>
      'You can tune your instruments to any concert pitch, play reference tones, save your individual configuration and combine the tuner with the metronome and media player.';

  String get commonCancel => 'Cancel';
  String get commonDelete => 'Delete?';
  String get commonNext => 'Next';
  String get commonNo => 'No';
  String get commonSubmit => 'Submit';
  String get commonYes => 'Yes';

  String get feedbackCta => 'Fill out';
  String get feedbackHint => '(For now the survey is only available in German)';
  String get feedbackQuestion => 'Do you like TIO Music? Please take part in this survey!';
  String get feedbackTitle => 'Feedback survey';

  String get home => 'Home';
  String get homeAbout => 'About';
  String get homeFeedback => 'Feedback';

  String get mediaPlayer => 'Media Player';
  String get mediaPlayerTutorialAdjust => 'Tap here to adjust your sound file';
  String get mediaPlayerTutorialJumpTo => 'Tap anywhere to jump to that part of your sound file';
  String get mediaPlayerTutorialStartStop => 'Tap here to start and stop recording or to play a sound file';

  String get metronome => 'Metronome';
  String get metronomeTutorialAddNew => 'Tap here to add a second metronome';
  String get metronomeTutorialAdjust => 'Tap here to adjust the metronome settings';
  String get metronomeTutorialEditBeats => 'Tap a beat to switch between accented, unaccented and muted';
  String get metronomeTutorialRelocate =>
      'Hold and drag sideways to relocate,\nswipe upwards to delete\nor tap to edit';
  String get metronomeTutorialStartStop => 'Tap here to start and stop the metronome';

  String get piano => 'Piano';
  String get pianoTutorialAdjust => 'Tap here to adjust concert pitch, volume, and sound';
  String get pianoTutorialChangeKeyOrOctave => 'Tap the left or right arrows to move up or down per key or per octave';

  String get projectDeleteAllTools => 'Delete all Tools';
  String get projectDeleteAllToolsConfirmation => 'Do you really want to delete all tools in this project?';
  String get projectDeleteToolConfirmation => 'Do you really want to delete this tool?';
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

  String get tuner => 'Tuner';
  String get tunerTutorialAdjust => 'Tap here to adjust the concert pitch or play a reference tone';
  String get tunerTutorialStartStop => 'Tap here to start and stop the tuner';

  String get appTutorialQuickToolSave => 'Tap here to save the tool to a project';
  String get appTutorialToolEditTitle => 'Tap here to edit the title of your tool';
  String get appTutorialToolIsland => 'Tap here to combine your tool with a metronome, tuner or media player';
  String get appTutorialToolSave => 'Tap here to copy your tool to another project';

  String get projectsTutorialAddProject => 'Tap here to create a new project';
  String get projectsTutorialCanIncludeMultipleTools => 'Projects can include multiple tools\n(tuner, metronome, piano setting, media player, image and text),\neven several tools of the same type.';
  String get projectsTutorialHowToUseTio => 'Welcome! You can use TIO in two ways.\n1. Create a project and add tools.\n2. Start with using a tool and save your specific settings to any project.';
  String get projectsTutorialStart => 'Show Tutorial';
  String get projectsTutorialStartUsingTool => 'Tap here to start using a tool';

  String get projectTutorialEditTitle => 'Tap here to edit the title of your project';
}
