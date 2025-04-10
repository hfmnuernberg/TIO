// overriding keys do not change something; ignored because soft warning
// ignore_for_file: annotate_overrides

import 'package:tiomusic/l10n/app_localization.dart';

class English extends AppLocalizations {
  String get appAboutDataProtection => 'Data protection';
  String get appAboutDataProtectionExplanation =>
      'We do not collect any of your data. Please note that your projects are only saved locally on your device, i.e. they are not saved in the app or in any cloud service or similar. If you decide to share individual content from within the app, this is possible via third-party services such as messenger etc. In such cases, only the data protection regulations of the third-party services used apply. You yourself are responsible for complying with applicable data protection or copyright regulations.';
  String get appAboutDeveloperOne => 'Developer: cultivate(software)';
  String get appAboutDeveloperTwo => 'Developer: Studio Fluffy';
  String get appAboutEditor => 'Editor: University of Music Nuremberg';
  String get appAboutFeatures => 'Features';
  String get appAboutImprint => 'Imprint';
  String get appAboutParagraphOne =>
      'TIO Music integrates numerous tools (tuner, metronome, media player, piano, image notes and text notes) in one app and enables the combined use of the individual tools. By creating projects, it is possible to save different configurations and thus make practicing and making music easier. The tools can also be used individually, for quick tuning of instruments or for recording samples. TIO Music was developed by musicians for musicians of all levels of experience, for amateurs and professionals. The app is and will remain completely free of charge and ad-free.';
  String get appAboutParagraphThree =>
      'This app was developed as part of the RE|LEVEL-project at Hochschule für Musik Nürnberg. RE|LEVEL is funded by Stiftung Innovation in der Hochschullehre.';
  String get appAboutParagraphTwo =>
      'We aim to continuously improve the app for you - so we look forward to your feedback!';
  String get appAboutTitle => 'About';
  String get appAboutVersion => 'App Version';
  String get appAboutVersionError => 'Could not load app version.';
  String get appTutorialToolIsland => 'Tap here to combine your tool with a metronome, tuner or media player';
  String get appTutorialToolSave => 'Tap here to copy your tool to another project';

  String get commonBpm => 'bpm';
  String get commonCancel => 'Cancel';
  String get commonDelete => 'Delete?';
  String get commonGotIt => 'Got it';
  String get commonInput => 'input';
  String get commonMinus => 'Minus button';
  String get commonNext => 'Next';
  String get commonNo => 'No';
  String get commonOctave => 'Octave';
  String get commonPlus => 'Plus button';
  String get commonReset => 'Reset';
  String get commonSlider => 'slider';
  String get commonSubmit => 'Submit';
  String get commonVolume => 'Volume';
  String get commonYes => 'Yes';

  String get feedbackCta => 'Fill out';
  String get feedbackHint => '(For now the survey is only available in German)';
  String get feedbackQuestion => 'Do you like TIO Music? Please take part in this survey!';
  String get feedbackTitle => 'Feedback survey';

  String get home => 'Home';
  String get homeAbout => 'About';
  String get homeFeedback => 'Feedback';

  String get image => 'Image';
  String get imageAbout => 'Image';
  String get imageAboutExplanation =>
      'You can upload pictures or note sheets to the app using the camera on your device.';
  String get imageDescription => 'take or load a picture';
  String get imageDoLater => 'Do it later';
  String get imageNoCameraFound => 'No camera found';
  String get imageNoCameraFoundHint => 'There is no camera available on this device.';
  String get imageNoImage => 'No image in this tool.';
  String get imagePickImage => 'Pick an image';
  String get imageSetAsProjectThumbnail => 'Set Project Thumbnail';
  String get imageSetAsThumbnail => 'Set as thumbnail';
  String get imageSetAsThumbnailQuestion =>
      'Do you want to use the image of this tool as your profile picture for this project?';
  String get imageShare => 'Share image';
  String get imageTakePhoto => 'Take a photo';
  String get imageUploadHint => 'Pick an image from your device or take a photo using the camera';
  String get imageUseAsThumbnailQuestion => 'Use image as project thumbnail';

  String get mainErrorDataLoading => 'Could not load user data!';
  String get mainOpenAnyway => 'Open anyway (all data is lost!)';
  String get mainRetry => 'Retry';
  String get mainSplashScreen => 'Splash Screen';

  String get mediaPlayer => 'Media Player';
  String get mediaPlayerAbout => 'Media player';
  String get mediaPlayerAboutExplanation =>
      'You can record, load and edit audio files and save configurations. In doing so, you can set your preferred volume, range (length and segment), playing speed and pitch. You can forward your projects to others using external messenger services.';
  String get mediaPlayerAddMarker => 'Add Marker';
  String get mediaPlayerBasicBeat => 'Basic Beat';
  String get mediaPlayerDescription => 'record and play';
  String get mediaPlayerEditMarkers => 'Edit Markers';
  String get mediaPlayerErrorFileAccessible => 'File is not accessible.';
  String get mediaPlayerErrorFileAccessibleDescription =>
      "Maybe the file needs to be downloaded first if it doesn't exist locally on your phone.";
  String get mediaPlayerErrorFileFormat => 'File format not supported';
  String get mediaPlayerErrorFileOpen => 'File could not be opened.';
  String get mediaPlayerErrorFileOpenDescription =>
      'Something went wrong while trying to open the file. Please try again.';
  String get mediaPlayerFactor => 'Factor';
  String get mediaPlayerFactorAndBpm => 'Factor and BPM slider';
  String get mediaPlayerFile => 'File';
  String get mediaPlayerLoadAudioFile => 'Load Audio File';
  String get mediaPlayerLooping => 'Looping';
  String get mediaPlayerMarkers => 'Markers';
  String get mediaPlayerOverwriteSound => 'Overwrite?';
  String get mediaPlayerOverwriteSoundQuestion =>
      'Do you want to overwrite the current audio file and start recording?';
  String get mediaPlayerPitch => 'Pitch';
  String get mediaPlayerRecording => 'Recording...';
  String get mediaPlayerRemoveMarker => 'Remove Selected Marker';
  String get mediaPlayerSecShort => 'sec';
  String get mediaPlayerSemitonesLabel => 'semitones';
  String get mediaPlayerSetBasicBeat => 'Set Basic Beat';
  String get mediaPlayerSetPitch => 'Set Pitch';
  String get mediaPlayerSetSpeed => 'Set Speed';
  String get mediaPlayerSetTrim => 'Set Trim';
  String get mediaPlayerShareAudioFile => 'Share audio file';
  String get mediaPlayerSpeed => 'Speed';
  String get mediaPlayerTapToTempo => 'Tap to tempo';
  String get mediaPlayerTrim => 'Trim';
  String get mediaPlayerTutorialAdjust => 'Tap here to adjust your sound file';
  String get mediaPlayerTutorialJumpTo => 'Tap anywhere to jump to that part of your sound file';
  String get mediaPlayerTutorialStartStop => 'Tap here to start and stop recording or to play a sound file';

  String mediaPlayerErrorFileFormatDescription(String format) =>
      'The file format "$format" is not supported. Please choose a different file.';
  String mediaPlayerSemitones(int value) => '$value semitone${value.abs() == 1 ? '' : 's'}';

  String get metronome => 'Metronome';
  String get metronomePrimary => 'Metronome 1';
  String get metronomeSecondary => 'Metronome 2';
  String get metronomeAbout => 'Metronome';
  String get metronomeAboutExplanation =>
      'The metronome allows you to save and recall your individual configurations (tempo, time signature, polyrhythms, random mute, sounds). You can also combine the metronome with the tuner and the media player.';
  String get metronomeAccented => 'Accented';
  String get metronomeBeatMain => 'Main Beat';
  String get metronomeBeatPoly => 'Poly Beat';
  String get metronomeClearAllRhythms => 'Clear all rhythms';
  String get metronomeDescription => 'create a rhythm';
  String get metronomeNumberOfBeats => 'Number of Beats';
  String get metronomeNumberOfPolyBeats => 'Number of Poly Beats';
  String get metronomeRandomMute => 'Random Mute';
  String get metronomeRandomMuteChance => 'mute chance';
  String get metronomeRandomMuteProbability => 'Probability in %';
  String get metronomeSetBpm => 'Set BPM';
  String get metronomeSetRandomMute => 'Set Random Mute';
  String get metronomeSetSoundsPrimary => 'Set Metronome Sounds';
  String get metronomeSetSoundsSecondary => 'Set 2nd Metronome Sounds';
  String get metronomeSound => 'Sound';
  String get metronomeSoundMain => 'Main';
  String get metronomeSoundPoly => 'Poly-Sound';
  String get metronomeSoundPolyShort => 'Poly';
  String get metronomeSoundPrimary => 'Sound 1';
  String get metronomeSoundSecondary => 'Sound 2';
  String get metronomeTutorialAddNew => 'Tap here to add a second metronome';
  String get metronomeTutorialAdjust => 'Tap here to adjust the metronome settings';
  String get metronomeTutorialEditBeats => 'Tap a beat to switch between accented, unaccented and muted';
  String get metronomeTutorialRelocate =>
      'Hold and drag sideways to relocate,\nswipe upwards to delete\nor tap to edit';
  String get metronomeTutorialStartStop => 'Tap here to start and stop the metronome';
  String get metronomeUnaccented => 'Unaccented';

  String metronomeSegment(int value) => '$value segment${value == 1 ? '' : 's'}';

  String get piano => 'Piano';
  String get pianoAbout => 'Piano';
  String get pianoAboutExplanation =>
      'You can use the built-in piano, select different sound modes and save your individual configurations.';
  String get pianoConcertPitchInHz => 'Concert Pitch in Hz';
  String get pianoDescription => 'become the next Herbie Hancock';
  String get pianoInstrumentElectricPiano1 => 'Electric Piano 1';
  String get pianoInstrumentElectricPiano2 => 'Electric Piano 2';
  String get pianoInstrumentGrandPiano1 => 'Grand Piano 1';
  String get pianoInstrumentGrandPiano2 => 'Grand Piano 2';
  String get pianoInstrumentHarpsichord => 'Harpsichord';
  String get pianoInstrumentPipeOrgan => 'Pipe Organ';
  String get pianoLowestKey => 'Lowest Key';
  String get pianoSetConcertPitch => 'Set Concert Pitch';
  String get pianoSetSound => 'Set Piano Sound';
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
  String get projectTutorialEditTitle => 'Tap here to edit the title of your project';

  String get projectsAbout => 'Projects';
  String get projectsAboutExplanation =>
      'You can create projects and save the required settings there (settings for instrument tuning, metronome settings, etc.), so you can access them whenever you want.';
  String get projectsDeleteAll => 'Delete all Projects';
  String get projectsDeleteAllConfirmation => 'Do you really want to delete all projects?';
  String get projectsDeleteConfirmation => 'Do you really want to delete this project?';
  String get projectsImport => 'Import Project';
  String get projectsImportError => 'Error importing project';
  String get projectsImportNoFileSelected => 'No project file selected';
  String get projectsImportSuccess => 'Project imported successfully!';
  String get projectsNew => 'New Project';
  String get projectsNoProjects => 'Please click on "+" to create a new project.';
  String get projectsTutorialAddProject => 'Tap here to create a new project';
  String get projectsTutorialCanIncludeMultipleTools =>
      'Projects can include multiple tools\n(tuner, metronome, piano setting, media player, image and text),\neven several tools of the same type.';
  String get projectsTutorialHowToUseTio =>
      'Welcome! You can use TIO in two ways.\n1. Create a project and add tools.\n2. Start with using a tool and save your specific settings to any project.';
  String get projectsTutorialStart => 'Show Tutorial';
  String get projectsTutorialStartUsingTool => 'Tap here to start using a tool';

  String get text => 'Text';
  String get textAbout => 'Text';
  String get textAboutExplanation =>
      'You can use your device to create text notes, e.g. for playing instructions, background information, song lyrics etc.';
  String get textDescription => 'write down your notes';

  String get toolEmpty => 'Empty';
  String get toolNewProjectTitle => 'Project title';
  String get toolNewTitle => 'Tool title';
  String get toolNoOtherToolAvailable =>
      'There is no other tool in this project. Please save another tool first to use it as an island.';
  String get toolQuickTool => 'Quick Tool';
  String get toolQuickToolSave => 'Save Quick Tool?';
  String get toolSave => 'Save in ...';
  String get toolSaveCopy => 'Save copy in ...';
  String get toolSaveInNewProject => 'Save in new project';
  String get toolTitleCopy => 'copy';
  String get toolTutorialEditTitle => 'Tap here to edit the title of your tool';
  String get toolTutorialSave => 'Tap here to save the tool to a project';
  String get toolUseBookmarkToSave => 'Use bookmark to save a tool';

  String toolHasNoIslandView(String tool) => '$tool has no Island View!';

  String get tuner => 'Tuner';
  String get tunerAbout => 'Tuner';
  String get tunerAboutExplanation =>
      'You can tune your instruments to any concert pitch, play reference tones, save your individual configuration and combine the tuner with the metronome and media player.';
  String get tunerConcertPitch => 'Concert Pitch';
  String get tunerConcertPitchInHz => 'Concert Pitch in Hz';
  String get tunerDescription => 'tune your instrument';
  String get tunerFrequency => 'Frequency';
  String get tunerPlayReference => 'Play Reference';
  String get tunerSetConcertPitch => 'Set Concert Pitch';
  String get tunerTutorialAdjust => 'Tap here to adjust the concert pitch or play a reference tone';
  String get tunerTutorialStartStop => 'Tap here to start and stop the tuner';
}
