// overriding keys do not change something; ignored because soft warning
// ignore_for_file: annotate_overrides

import 'package:intl/intl.dart';
import 'package:tiomusic/l10n/app_localization.dart';

class English extends AppLocalizations {
  String get locale => 'en';

  String get appAboutDataProtection => 'Data protection';
  String get appAboutDataProtectionExplanation =>
      'We do not collect any of your data. Please note that your projects are only saved locally on your device, i.e. they are not saved in the app or in any cloud service or similar. If you decide to share individual content from within the app, this is possible via third-party services such as messenger etc. In such cases, only the data protection regulations of the third-party services used apply. You yourself are responsible for complying with applicable data protection or copyright regulations.';
  String get appAboutDeveloperOne => 'Developer: cultivate(software)';
  String get appAboutDeveloperTwo => 'Developer: Studio Fluffy';
  String get appAboutEditor => 'Editor: Hochschule für Musik Nürnberg';
  String get appAboutFeatures => 'Features';
  String get appAboutImprint => 'Imprint';
  String get appAboutParagraphOne =>
      'TIO Music integrates numerous tools (tuner, metronome, media player, piano, image notes and text notes) in one app and enables the combined use of the individual tools. By creating projects, it is possible to save different configurations and thus make practicing and making music easier. The tools can also be used individually, e.g. for quick tuning of instruments or for recording samples. TIO Music was developed by musicians for musicians of all levels of experience. The app is and will remain completely free of charge and ad-free.';
  String get appAboutParagraphThree =>
      'This app was developed as part of the RE|LEVEL-project at Hochschule für Musik Nürnberg. RE|LEVEL is funded by Stiftung Innovation in der Hochschullehre.';
  String get appAboutParagraphTwo =>
      'We aim to continuously improve the app for you - so we look forward to your feedback!';
  String get appAboutTitle => 'About';
  String get appAboutVersion => 'App Version';
  String get appAboutVersionError => 'Could not load app version.';
  String get appTutorialToolSave => 'Tap here to copy your tool to another project.';

  String get commonBasicBeat => 'Basic beat';
  String get commonBasicBeatSetting => 'Set basic beat';
  String get commonBpm => 'BPM';
  String get commonCancel => 'Cancel';
  String get commonDelete => 'Delete?';
  String get commonGotIt => 'Got it';
  String get commonInput => 'Input';
  String get commonMinus => 'Minus button';
  String get commonNext => 'Next';
  String get commonNo => 'No';
  String get commonOctave => 'Octave';
  String get commonPlus => 'Plus button';
  String get commonProceed => 'Proceed';
  String get commonReorder => 'Reorder';
  String get commonReset => 'Reset';
  String get commonSetVolume => 'Set Volume';
  String get commonSlider => 'Slider';
  String get commonSubmit => 'Submit';
  String get commonTextField => 'Text field';
  String get commonVolume => 'Volume';
  String get commonVolumeHintLow =>
      'The device volume is low. If necessary, increase the device volume in addition to the tool volume.';
  String get commonVolumeHintMid =>
      'If you struggle to hear the tool in your current environment, consider connecting your device to an external speaker (e.g., via Bluetooth).';
  String get commonVolumeHintMuted => 'The device is muted. Unmute the device to hear the tool.';
  String get commonYes => 'Yes';

  String get feedbackCta => 'Fill out';
  String get feedbackQuestion => 'Do you like TIO Music? Please take part in this survey!';
  String get feedbackTitle => 'Feedback survey';

  String get flashCardsDescription =>
      'let someone else take the lead. He/She will guide you by giving instructions or demonstrating how to practice.';
  String get flashCardsPageTitle => 'Flash Cards';
  String get flashCardsTitle => 'When you practice today,';

  String get home => 'Home';
  String get homeAbout => 'About';
  String get homeFeedback => 'Feedback';

  String get image => 'Image';
  String get imageAbout => 'Image';
  String get imageAboutExplanation =>
      'You can upload pictures or note sheets to the app using the camera on your device.';
  String get imageDescription => 'Take or load a picture';
  String get imageDoLater => 'Do it later';
  String get imageNoCameraFound => 'No camera found';
  String get imageNoCameraFoundHint => 'There is no camera available on this device.';
  String get imagePickImage => 'Pick image(s)';
  String get imagePickNewImage => 'Pick new image(s)';
  String get imagePickOrTakeImage => 'Please select an image or take a photo.';
  String get imageSetAsProjectThumbnail => 'Set project thumbnail';
  String get imageSetAsThumbnail => 'Set as thumbnail';
  String get imageSetAsThumbnailQuestion =>
      'Do you want to use the image of this tool as your profile picture for this project?';
  String get imageShare => 'Share image';
  String get imageTakePhoto => 'Take a photo';
  String get imageTakeNewPhoto => 'Take new photo';
  String get imageUploadHint =>
      'Pick one or more images from your device or take a photo using the camera.\n\nYou can upload up to 10 images at once. The first image will be saved here, and a separate image tool will be created for all subsequent images.';
  String get imageUseAsThumbnailQuestion => 'Use the first image as project thumbnail?';

  String get mainErrorDataLoading => 'Could not load user data!';
  String get mainOpenAnyway => 'Open anyway (all data is lost!)';
  String get mainRetry => 'Retry';
  String get mainSplashScreen => 'Splash screen';

  String get mediaPlayer => 'Media Player';
  String get mediaPlayerAbout => 'Media Player';
  String get mediaPlayerAboutExplanation =>
      'You can record, load and edit audio files and save configurations. In doing so, you can set your preferred volume, range (length and segment), playing speed and pitch. You can forward your projects to others using external messenger services.';
  String get mediaPlayerAddMarker => 'Add marker';
  String get mediaPlayerDescription => 'Make recordings or load audio files, listen to them and edit them.';
  String get mediaPlayerEditMarkers => 'Edit markers';
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
  String get mediaPlayerMarker => 'Marker';
  String get mediaPlayerMarkers => 'Markers';
  String get mediaPlayerOpenFileSystem => 'Open files';
  String get mediaPlayerOpenMediaLibrary => 'Open media library';
  String get mediaPlayerOverwriteSound => 'Overwrite?';
  String get mediaPlayerOverwriteWithAudioQuestion =>
      'Do you want to overwrite the current audio file and choose another one?';
  String get mediaPlayerOverwriteWithRecordingQuestion =>
      'Do you want to overwrite the current audio file and start recording?';
  String get mediaPlayerPause => 'Pause';
  String get mediaPlayerPitch => 'Pitch';
  String get mediaPlayerPlay => 'Play';
  String get mediaPlayerRecording => 'Recording...';
  String get mediaPlayerRemoveMarker => 'Remove selected marker';
  String get mediaPlayerRepeatAll => 'Repeat all media player';
  String get mediaPlayerRepeatOff => 'Repeat no media player';
  String get mediaPlayerRepeatOne => 'Repeat media player';
  String get mediaPlayerSecShort => 'Sec';
  String get mediaPlayerSemitonesLabel => 'Semitones';
  String get mediaPlayerSetPitch => 'Set pitch';
  String get mediaPlayerSetSpeed => 'Set tempo';
  String get mediaPlayerSetTrim => 'Set trim';
  String get mediaPlayerShareAudioFile => 'Share audio file';
  String get mediaPlayerSpeed => 'Tempo';
  String get mediaPlayerTapToTempo => 'Tap to tempo';
  String get mediaPlayerTooManyFilesDescription =>
      'Due to technical limitations, only 10 files can be loaded at once.\n\nPlease repeat the process for any files that were not loaded this time.';
  String get mediaPlayerTooManyFilesTitle => 'Too many files';
  String get mediaPlayerTrim => 'Trim';
  String get mediaPlayerTutorialAdjust =>
      'Tap here to adjust your audio file. You can set the volume and the basic beat, trim your file and set markers, as well as change the pitch and tempo afterwards.';
  String get mediaPlayerTutorialIslandTool =>
      'Tap here to combine your Media Player with a Tuner or Metronome.\n\nYou can link your Media Player with an existing tool or create a new tool and link it.';
  String get mediaPlayerTutorialJumpTo => 'Tap anywhere to jump to that part of your sound file.';
  String get mediaPlayerTutorialRepeat =>
      'Enable repeated playback for this media player. By tapping again, you can also play all media players in this project that contain a sound file one after another.';
  String get mediaPlayerTutorialStartStop => 'Tap here to start and stop recording or to play a sound file.';

  String mediaPlayerErrorFileFormatDescription(String format) =>
      'The file format "$format" is not supported. Please choose a different file.';
  String mediaPlayerSemitones(int value) => '$value semitone${value.abs() == 1 ? '' : 's'}';

  String get metronome => 'Metronome';
  String get metronomePrimary => 'Metronome 1';
  String get metronomeSecondary => 'Metronome 2';
  String get metronomeAbout => 'Metronome';
  String get metronomeAboutExplanation =>
      'The metronome allows you to save and recall your individual configurations (tempo, time signature, polyrhythms, random mute, sounds, etc.). You can also combine the metronome with other tools.';
  String get metronomeAccented => 'Accented';
  String get metronomeBeatMain => 'Main beat';
  String get metronomeBeatPoly => 'Poly beat';
  String get metronomeClearAllRhythms => 'Clear all rhythms';
  String get metronomeDescription => 'Create a rhythm';
  String get metronomeNumberOfBeats => 'Number of beats';
  String get metronomeNumberOfPolyBeats => 'Number of poly beats';
  String get metronomeRandomMute => 'Random mute';
  String get metronomeRandomMuteChance => 'Mute chance';
  String get metronomeRandomMuteProbability => 'Probability in %';
  String get metronomeResetDialogHint =>
      'ATTENTION: This will reset the metronome rhythm and sound to its default settings. All your current settings will be lost. Do you want to continue?';
  String get metronomeResetDialogTitle => 'Reset metronome?';
  String get metronomeRhythmDottedEighthFollowedBySixteenth => 'Dotted Eighth followed by Sixteenths';
  String get metronomeRhythmEighthRestFollowedByEighth => 'Eighth rest followed by Eighth';
  String get metronomeRhythmEighths => 'Eighths';
  String get metronomeRhythmPattern => 'Rhythm pattern';
  String get metronomeRhythmQuarter => 'Quarter';
  String get metronomeRhythmSixteenthFollowedByDottedEighth => 'Sixteenths followed by dotted Eighth';
  String get metronomeRhythmSixteenths => 'Sixteenths';
  String get metronomeRhythmTriplets => 'Triplets';
  String get metronomeSetBpm => 'Set BPM';
  String get metronomeSetRandomMute => 'Set random mute';
  String get metronomeSetSoundsPrimary => 'Set metronome sounds';
  String get metronomeSetSoundsSecondary => 'Set 2nd metronome sounds';
  String get metronomeSimpleModeOff => 'Switch to advanced mode';
  String get metronomeSimpleModeOn => 'Switch to simple mode';
  String get metronomeSound => 'Sound';
  String get metronomeSoundMain => 'Main';
  String get metronomeSoundPoly => 'Poly sound';
  String get metronomeSoundPolyShort => 'Poly';
  String get metronomeSoundPrimary => 'Sound 1';
  String get metronomeSoundSecondary => 'Sound 2';
  String get metronomeSoundTypeBlup => 'blup';
  String get metronomeSoundTypeBop => 'bop';
  String get metronomeSoundTypeClap => 'clap';
  String get metronomeSoundTypeClick => 'click';
  String get metronomeSoundTypeClock => 'clock';
  String get metronomeSoundTypeCowbell => 'cowbell';
  String get metronomeSoundTypeDigiClick => 'digi click';
  String get metronomeSoundTypeHeart => 'heartbeat';
  String get metronomeSoundTypeKick => 'kick';
  String get metronomeSoundTypeNoise => 'noise';
  String get metronomeSoundTypePing => 'ping';
  String get metronomeSoundTypePling => 'pling';
  String get metronomeSoundTypeRim => 'rim';
  String get metronomeSoundTypeTick => 'tick';
  String get metronomeSoundTypeWood => 'wood';
  String get metronomeTutorialAddNew => 'Tap here to add a second metronome.';
  String get metronomeTutorialAdjust => 'Tap here to adjust the metronome settings.';
  String get metronomeTutorialIslandTool =>
      'Tap here to combine your Metronome with a Tuner or Media Player.\n\nYou can link your Metronome with an existing tool or create a new tool and link it.';
  String get metronomeTutorialModeAdvanced =>
      'Hold and drag sideways to relocate a bar, swipe upwards to delete a bar, or tap to edit the selected bar.';
  String get metronomeTutorialModeChange =>
      'You can switch between basic and advanced mode using the menu in the top right corner.';
  String get metronomeTutorialModeSimple => 'Here you can set the basic beats and the rhythm pattern.';
  String get metronomeTutorialEditBeats => 'Tap a beat to switch between accented, unaccented and muted.';
  String get metronomeTutorialStartStop => 'Tap here to start and stop the metronome.';
  String get metronomeUnaccented => 'Unaccented';

  String metronomeSegment(int value) => '$value ${value == 1 ? 'segment' : 'segments'}';

  String get piano => 'Piano';
  String get pianoAbout => 'Piano';
  String get pianoAboutExplanation =>
      'You can use the built-in piano, select different sound modes and save your individual configurations.';
  String get pianoConcertPitchInHz => 'Concert Pitch in Hz';
  String get pianoDescription => 'No piano around? Try out a piece or play some chords.';
  String get pianoInstrumentElectricPiano1 => 'Electric Piano 1';
  String get pianoInstrumentElectricPiano2 => 'Electric Piano 2';
  String get pianoInstrumentElectricPianoHold => 'Electric Piano (H)';
  String get pianoInstrumentGrandPiano1 => 'Grand Piano 1';
  String get pianoInstrumentGrandPiano2 => 'Grand Piano 2';
  String get pianoInstrumentHarpsichord => 'Harpsichord';
  String get pianoInstrumentPipeOrgan => 'Pipe Organ (H)';
  String get pianoLowestKey => 'Lowest piano key';
  String get pianoSetConcertPitch => 'Set concert pitch';
  String get pianoSetSound => 'Set piano sound';
  String get pianoTutorialAdjust =>
      'Tap here to adjust concert pitch, volume, and sound. If you have selected a sound with a hold function, the H button will no longer appear grayed out.';
  String get pianoTutorialChangeKeyOrOctave => 'Tap the left or right arrows to move up or down per key or per octave.';
  String get pianoTutorialIslandTool =>
      'Tap here to combine your Piano with a Tuner, Media Player, or Metronome.\n\nYou can link your Piano with an existing tool or create a new tool and link it.';

  String get projectDelete => 'Delete project';
  String get projectDeleteTool => 'Delete tool';
  String get projectDeleteAllTools => 'Delete all tools';
  String get projectDeleteAllToolsConfirmation => 'Do you really want to delete all tools in this project?';
  String get projectDeleteToolConfirmation => 'Do you really want to delete this tool?';
  String get projectDetails => 'Project details';
  String get projectEditTools => 'Edit tools';
  String get projectEditToolsDone => 'Finish editing';
  String get projectEmpty => 'Choose type of tool';
  String get projectExport => 'Export project';
  String get projectExportCancelled => 'Project export cancelled';
  String get projectExportError => 'Error exporting project';
  String get projectExportSuccess => 'Project exported successfully!';
  String get projectMenu => 'Project menu';
  String get projectNew => 'Project title';
  String get projectNewTool => 'Tool title';
  String get projectToolList => 'Tool list';
  String get projectToolListEmpty => 'Empty tool list';
  String get projectTutorialChangeToolOrder =>
      'Tap the plus icon to add a new tool or the pencil icon to edit the tools.';
  String get projectTutorialEditTitle => 'Tap here to edit the title of your project.';

  String get projectsAbout => 'Projects';
  String get projectsAboutExplanation =>
      "All elements can be collectively saved in projects. You don't need to set the metronome or adjust your tuner each time. You can easily continue from where you left off last time.";
  String get projectsAddNew => 'Add new project';
  String get projectsDeleteAll => 'Delete all projects';
  String get projectsDeleteAllConfirmation => 'Do you really want to delete all projects?';
  String get projectsDeleteConfirmation => 'Do you really want to delete this project?';
  String get projectsEdit => 'Edit projects';
  String get projectsEditDone => 'Finish editing';
  String get projectsFlashCards => 'Flash Cards';
  String get projectsImport => 'Import project';
  String get projectsImportError => 'Error importing project';
  String get projectsImportNoFileSelected => 'No project file selected';
  String get projectsImportSuccess => 'Project imported successfully!';
  String get projectsMenu => 'Projects menu';
  String get projectsNew => 'New project';
  String get projectsNoProjects => 'Please click on "+" to create a new project.';
  String get projectsTutorialAddProject => 'Tap here to create a new project.';
  String get projectsTutorialCanIncludeMultipleTools =>
      'Projects can include multiple tools\n(tuner, metronome, piano, media player, image and text),\neven several tools of the same type.';
  String get projectsTutorialChangeProjectOrder =>
      'Tap the plus icon to add a new project or the pencil icon to edit the projects.';
  String get projectsTutorialHowToUseTio =>
      'Welcome! You can use TIO in two ways.\n1. Create a project and add tools.\n2. Start with using a tool and save your specific settings to any project.';
  String get projectsTutorialStart => 'Show tutorial';
  String get projectsTutorialStartUsingTool => 'Tap here to start using a tool.';

  String get text => 'Text';
  String get textAbout => 'Text';
  String get textAboutExplanation =>
      'You can use your device to create text notes, e.g. for playing instructions, background information, song lyrics etc.';
  String get textDescription => 'Write down your notes.';
  String get textImport => 'Import text';
  String get textImportDialogHint =>
      'ATTENTION: When importing a text, the current content of the text tool will be overwritten.';
  String get textImportDialogTitle => 'Import text?';
  String get textImportError => 'Error importing text file';
  String get textImportNoFileSelected => 'No text file selected';
  String get textImportSuccess => 'Text imported successfully!';

  String get toolAddNew => 'Add new tool';
  String get toolConnectAnother => 'Connect another tool';
  String get toolConnectExistingTool => 'Connect a tool';
  String get toolConnectNewTool => 'Connect a new tool';
  String get toolEmpty => 'Empty';
  String get toolNewProjectTitle => 'Project title';
  String get toolNewTitle => 'Tool title';
  String get toolGoToNext => 'Go to next tool';
  String get toolGoToNextOfSameType => 'Go to next tool of the same type';
  String get toolNoOtherToolAvailable =>
      'There is no other tool in this project. Please save another tool first to use it as an island.';
  String get toolGoToPrev => 'Go to previous tool';
  String get toolGoToPrevOfSameType => 'Go to previous tool of the same type';
  String get toolQuickTool => 'Quick tool';
  String get toolQuickToolSave => 'Save quick tool?';
  String get toolSave => 'Save in ...';
  String get toolSaveCopy => 'Save copy in ...';
  String get toolSaveInNewProject => 'Save in new project';
  String get toolTitleCopy => 'Copy';
  String get toolTutorialEditTitle => 'Tap here to edit the title of your tool.';
  String get toolTutorialSave =>
      'Tap here to save the tool to a project.\n\nOnce this tool is part of a project, you can link it with other tools.';
  String get toolUseBookmarkToSave => 'Use bookmark to save a tool.';

  String toolHasNoIslandView(String tool) => '$tool has no compact view!';

  String get tuner => 'Tuner';
  String get tunerAbout => 'Tuner';
  String get tunerAboutExplanation =>
      'You can tune your instruments to any concert pitch, play reference tones, save your individual configuration and combine the tuner with other tools.';
  String get tunerConcertPitch => 'Concert pitch';
  String get tunerConcertPitchInHz => 'Concert pitch in Hz';
  String get tunerDescription => 'Tune your instrument or use reference tones.';
  String get tunerFrequency => 'Frequency';
  String get tunerInstrument => 'Instrument';
  String get tunerLowFrequencyWarning =>
      'Low frequencies (<300 Hz) may be hard to hear on some devices. Consider using headphones or increasing the volume.';
  String get tunerPlayReference => 'Play reference';
  String get tunerSetConcertPitch => 'Set concert pitch';
  String get tunerTutorialAdjust => 'Tap here to adjust the concert pitch or play a reference tone.';
  String get tunerTutorialIslandTool =>
      'Tap here to combine your Tuner with a Metronome or Media Player.\n\nYou can link your Tuner with an existing tool or create a new tool and link it.';
  String get tunerTutorialStartStop =>
      'Tap here to start and stop the tuner.\n\nWhen the note fades out, overtones may cause incorrect readings. It’s best to strike the note again.';
  String get tunerTypeChromatic => 'Chromatic Tuner';
  String get tunerTypeBass => 'Bass';
  String get tunerTypeGuitar => 'Guitar';
  String get tunerTypeUkulele => 'Ukulele';
  String get tunerTypeViola => 'Viola';
  String get tunerTypeViolin => 'Violin';
  String get tunerTypeVioloncello => 'Violoncello';

  String formatDateAndTime(DateTime time) => DateFormat('dd/MM/yyyy - HH:mm:ss').format(time);
}
