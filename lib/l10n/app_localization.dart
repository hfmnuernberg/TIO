import 'package:intl/intl.dart';

abstract class AppLocalizations {
  String get locale;

  String get appAboutDataProtection;
  String get appAboutDataProtectionExplanation;
  String get appAboutDeveloperOne;
  String get appAboutDeveloperTwo;
  String get appAboutEditor;
  String get appAboutFeatures;
  String get appAboutImprint;
  String get appAboutParagraphOne;
  String get appAboutParagraphThree;
  String get appAboutParagraphTwo;
  String get appAboutTitle;
  String get appAboutVersion;
  String get appAboutVersionError;
  String get appTutorialToolIsland;
  String get appTutorialToolSave;

  String get commonBasicBeat;
  String get commonBasicBeatSetting;
  String get commonBpm;
  String get commonCancel;
  String get commonDelete;
  String get commonGotIt;
  String get commonInput;
  String get commonMinus;
  String get commonNext;
  String get commonNo;
  String get commonOctave;
  String get commonPlus;
  String get commonProceed;
  String get commonReorder;
  String get commonReset;
  String get commonSetVolume;
  String get commonSlider;
  String get commonSubmit;
  String get commonTextField;
  String get commonVolume;
  String get commonVolumeHintLow;
  String get commonVolumeHintMid;
  String get commonVolumeHintMuted;
  String get commonYes;

  String get feedbackCta;
  String get feedbackQuestion;
  String get feedbackTitle;

  String get home;
  String get homeAbout;
  String get homeFeedback;

  String get image;
  String get imageAbout;
  String get imageAboutExplanation;
  String get imageDescription;
  String get imageDoLater;
  String get imageNoCameraFound;
  String get imageNoCameraFoundHint;
  String get imagePickImage;
  String get imagePickNewImage;
  String get imagePickOrTakeImage;
  String get imageSetAsProjectThumbnail;
  String get imageSetAsThumbnail;
  String get imageSetAsThumbnailQuestion;
  String get imageShare;
  String get imageTakePhoto;
  String get imageTakeNewPhoto;
  String get imageUploadHint;
  String get imageUseAsThumbnailQuestion;

  String get mainErrorDataLoading;
  String get mainOpenAnyway;
  String get mainRetry;
  String get mainSplashScreen;

  String get mediaPlayer;
  String get mediaPlayerAbout;
  String get mediaPlayerAboutExplanation;
  String get mediaPlayerAddMarker;
  String get mediaPlayerDescription;
  String get mediaPlayerEditMarkers;
  String get mediaPlayerErrorFileAccessible;
  String get mediaPlayerErrorFileAccessibleDescription;
  String get mediaPlayerErrorFileFormat;
  String get mediaPlayerErrorFileOpen;
  String get mediaPlayerErrorFileOpenDescription;
  String get mediaPlayerFactor;
  String get mediaPlayerFactorAndBpm;
  String get mediaPlayerFile;
  String get mediaPlayerLooping;
  String get mediaPlayerMarkers;
  String get mediaPlayerOpenFileSystem;
  String get mediaPlayerOpenMediaLibrary;
  String get mediaPlayerOverwriteSound;
  String get mediaPlayerOverwriteSoundQuestion;
  String get mediaPlayerPitch;
  String get mediaPlayerRecording;
  String get mediaPlayerRemoveMarker;
  String get mediaPlayerSecShort;
  String get mediaPlayerSemitonesLabel;
  String get mediaPlayerSetPitch;
  String get mediaPlayerSetSpeed;
  String get mediaPlayerSetTrim;
  String get mediaPlayerShareAudioFile;
  String get mediaPlayerSpeed;
  String get mediaPlayerTapToTempo;
  String get mediaPlayerTrim;
  String get mediaPlayerTutorialAdjust;
  String get mediaPlayerTutorialJumpTo;
  String get mediaPlayerTutorialStartStop;

  String mediaPlayerErrorFileFormatDescription(String format);
  String mediaPlayerSemitones(int value);

  String get metronome;
  String get metronomePrimary;
  String get metronomeSecondary;
  String get metronomeAbout;
  String get metronomeAboutExplanation;
  String get metronomeAccented;
  String get metronomeBeatMain;
  String get metronomeBeatPoly;
  String get metronomeClearAllRhythms;
  String get metronomeDescription;
  String get metronomeNumberOfBeats;
  String get metronomeNumberOfPolyBeats;
  String get metronomeRandomMute;
  String get metronomeRandomMuteChance;
  String get metronomeRandomMuteProbability;
  String get metronomeRhythmDottedEighthFollowedBySixteenth;
  String get metronomeRhythmEighthRestFollowedByEighth;
  String get metronomeRhythmEighths;
  String get metronomeRhythmPattern;
  String get metronomeRhythmQuarter;
  String get metronomeRhythmSixteenthFollowedByDottedEighth;
  String get metronomeRhythmSixteenths;
  String get metronomeRhythmTriplets;
  String get metronomeResetDialogHint;
  String get metronomeResetDialogTitle;
  String get metronomeSetBpm;
  String get metronomeSetRandomMute;
  String get metronomeSetSoundsPrimary;
  String get metronomeSetSoundsSecondary;
  String get metronomeSimpleModeOff;
  String get metronomeSimpleModeOn;
  String get metronomeSound;
  String get metronomeSoundMain;
  String get metronomeSoundPoly;
  String get metronomeSoundPolyShort;
  String get metronomeSoundPrimary;
  String get metronomeSoundSecondary;
  String get metronomeSoundTypeBlup;
  String get metronomeSoundTypeBop;
  String get metronomeSoundTypeClap;
  String get metronomeSoundTypeClick;
  String get metronomeSoundTypeClock;
  String get metronomeSoundTypeCowbell;
  String get metronomeSoundTypeDigiClick;
  String get metronomeSoundTypeHeart;
  String get metronomeSoundTypeKick;
  String get metronomeSoundTypeNoise;
  String get metronomeSoundTypePing;
  String get metronomeSoundTypePling;
  String get metronomeSoundTypeRim;
  String get metronomeSoundTypeTick;
  String get metronomeSoundTypeWood;
  String get metronomeTutorialAddNew;
  String get metronomeTutorialAdjust;
  String get metronomeTutorialEditBeats;
  String get metronomeTutorialRelocate;
  String get metronomeTutorialSimpleView;
  String get metronomeTutorialStartStop;
  String get metronomeUnaccented;

  String metronomeSegment(int value);

  String get piano;
  String get pianoAbout;
  String get pianoAboutExplanation;
  String get pianoConcertPitchInHz;
  String get pianoDescription;
  String get pianoInstrumentElectricPiano1;
  String get pianoInstrumentElectricPiano2;
  String get pianoInstrumentGrandPiano1;
  String get pianoInstrumentGrandPiano2;
  String get pianoInstrumentHarpsichord;
  String get pianoInstrumentPipeOrgan;
  String get pianoLowestKey;
  String get pianoSetConcertPitch;
  String get pianoSetSound;
  String get pianoTutorialAdjust;
  String get pianoTutorialChangeKeyOrOctave;

  String get projectDelete;
  String get projectDeleteTool;
  String get projectDeleteAllTools;
  String get projectDeleteAllToolsConfirmation;
  String get projectDeleteToolConfirmation;
  String get projectDetails;
  String get projectEditTools;
  String get projectEditToolsDone;
  String get projectEmpty;
  String get projectExport;
  String get projectExportCancelled;
  String get projectExportError;
  String get projectExportSuccess;
  String get projectMenu;
  String get projectNew;
  String get projectNewTool;
  String get projectToolList;
  String get projectToolListEmpty;
  String get projectTutorialChangeToolOrder;
  String get projectTutorialEditTitle;

  String get projectsAbout;
  String get projectsAboutExplanation;
  String get projectsAddNew;
  String get projectsDeleteAll;
  String get projectsDeleteAllConfirmation;
  String get projectsDeleteConfirmation;
  String get projectsEdit;
  String get projectsEditDone;
  String get projectsImport;
  String get projectsImportError;
  String get projectsImportNoFileSelected;
  String get projectsImportSuccess;
  String get projectsMenu;
  String get projectsNew;
  String get projectsNoProjects;
  String get projectsTutorialAddProject;
  String get projectsTutorialCanIncludeMultipleTools;
  String get projectsTutorialChangeProjectOrder;
  String get projectsTutorialHowToUseTio;
  String get projectsTutorialStart;
  String get projectsTutorialStartUsingTool;

  String get text;
  String get textAbout;
  String get textAboutExplanation;
  String get textDescription;
  String get textImport;
  String get textImportDialogHint;
  String get textImportDialogTitle;
  String get textImportError;
  String get textImportNoFileSelected;
  String get textImportSuccess;

  String get toolAddNew;
  String get toolEmpty;
  String get toolNewProjectTitle;
  String get toolNewTitle;
  String get toolGoToNext;
  String get toolGoToNextOfSameType;
  String get toolNoOtherToolAvailable;
  String get toolGoToPrev;
  String get toolGoToPrevOfSameType;
  String get toolQuickTool;
  String get toolQuickToolSave;
  String get toolSave;
  String get toolSaveCopy;
  String get toolSaveInNewProject;
  String get toolTitleCopy;
  String get toolTutorialEditTitle;
  String get toolTutorialSave;
  String get toolUseBookmarkToSave;

  String toolHasNoIslandView(String tool);

  String get tuner;
  String get tunerAbout;
  String get tunerAboutExplanation;
  String get tunerConcertPitch;
  String get tunerConcertPitchInHz;
  String get tunerDescription;
  String get tunerFrequency;
  String get tunerPlayReference;
  String get tunerSetConcertPitch;
  String get tunerTutorialAdjust;
  String get tunerTutorialStartStop;

  String formatNumber(double number) => NumberFormat.decimalPattern(locale).format(number);

  double parseNumber(String number) => NumberFormat.decimalPattern(locale).parse(number).toDouble();

  String formatDateAndTime(DateTime time);

  String formatDuration(Duration dur) {
    final hours = _padWithTwoZeros(dur.inHours.remainder(24));
    final minutes = _padWithTwoZeros(dur.inMinutes.remainder(60));
    final seconds = _padWithTwoZeros(dur.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  String formatDurationWithMillis(Duration dur) {
    final minutes = _padWithTwoZeros(dur.inMinutes.remainder(60));
    final seconds = _padWithTwoZeros(dur.inSeconds.remainder(60));
    final milliSeconds = _padWithThreeZeros(dur.inMilliseconds.remainder(1000));
    return '$minutes:$seconds:$milliSeconds';
  }

  String _padWithTwoZeros(int n) => n.toString().padLeft(2, '0');
  String _padWithThreeZeros(int n) => n.toString().padLeft(3, '0');
}
