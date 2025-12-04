import 'package:tiomusic/models/project_library.dart';

extension ProjectLibraryTutorialsExtension on ProjectLibrary {
  void resetAllTutorials() {
    showHomepageTutorial = true;
    showProjectPageTutorial = true;
    showFlashCardsPageTutorial = true;
    showToolTutorial = true;
    showQuickToolTutorial = true;
    showTunerIslandTutorial = true;
    showTunerTutorial = true;
    showMetronomeIslandTutorial = true;
    showMetronomeTutorial = true;
    showMetronomeAdvancedTutorial = true;
    showMetronomeSimpleTutorial = true;
    showMediaPlayerIslandTutorial = true;
    showMediaPlayerTutorial = true;
    showPianoIslandTutorial = true;
    showPianoTutorial = true;
    showImageTutorial = true;
    showWaveformTip = true;
    showBeatToggleTip = true;
  }

  void dismissAllTutorials() {
    showHomepageTutorial = false;
    showProjectPageTutorial = false;
    showFlashCardsPageTutorial = false;
    showToolTutorial = false;
    showQuickToolTutorial = false;
    showTunerIslandTutorial = false;
    showTunerTutorial = false;
    showMetronomeIslandTutorial = false;
    showMetronomeTutorial = false;
    showMetronomeAdvancedTutorial = false;
    showMetronomeSimpleTutorial = false;
    showMediaPlayerIslandTutorial = false;
    showMediaPlayerTutorial = false;
    showPianoIslandTutorial = false;
    showPianoTutorial = false;
    showImageTutorial = false;
    showWaveformTip = false;
    showBeatToggleTip = false;
  }
}
