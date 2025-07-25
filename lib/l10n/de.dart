// overriding keys do not change something; ignored because soft warning
// ignore_for_file: annotate_overrides

import 'package:intl/intl.dart';
import 'package:tiomusic/l10n/app_localization.dart';

class German extends AppLocalizations {
  String get locale => 'de';

  String get appAboutDataProtection => 'Datenschutz';
  String get appAboutDataProtectionExplanation =>
      'Wir erheben keine deiner Daten. Wir weisen darauf hin, dass deine Projekte ausschließlich lokal auf deinem Endgerät, also nicht in der App und auch nicht in einem Cloudservice o.ä. gespeichert werden. Falls du einzelne Inhalte aus der App heraus teilen möchtest, ist das über Drittanbieter-Dienste wie z.B. Messenger etc. möglich. Dabei gelten ausschließlich die Datenschutzbestimmungen der jeweils genutzten Drittanbieter-Dienste. Du bist selbst dafür verantwortlich, geltende Datenschutz- oder Copyright-Regelungen einzuhalten.';
  String get appAboutDeveloperOne => 'Entwickler: cultivate(software)';
  String get appAboutDeveloperTwo => 'Entwickler: Studio Fluffy';
  String get appAboutEditor => 'Herausgeber: Hochschule für Musik Nürnberg';
  String get appAboutFeatures => 'Funktionen';
  String get appAboutImprint => 'Impressum';
  String get appAboutParagraphOne =>
      'TIO Music vereint zahlreiche Tools (Stimmgerät, Metronom, Media Player, Piano, Bildnotizen und Textnotizen) in einer App und ermöglicht die kombinierte Nutzung der einzelnen Tools. Durch das Erstellen von Projekten ist es möglich, verschiedene Konfigurationen zu speichern und so das Üben und Musizieren zu erleichtern. Die Tools können aber auch einzeln, z.B. zum schnellen Stimmen von Instrumenten oder zum Aufnehmen von Samples verwendet werden. TIO Music wurde von Musiker*innen für Musiker*innen aller Erfahrungsstufen entwickelt. Dabei ist und bleibt die App vollkommen kosten- und werbefrei.';
  String get appAboutParagraphThree =>
      'Diese App wurde im Rahmen des RE|LEVEL-Projekts an der Hochschule für Musik Nürnberg entwickelt. RE|LEVEL wird von der Stiftung Innovation in der Hochschullehre gefördert.';
  String get appAboutParagraphTwo =>
      'Wir möchten die App laufend für dich verbessern - daher freuen wir uns auf dein Feedback!';
  String get appAboutTitle => 'Über TIO Music';
  String get appAboutVersion => 'App Version';
  String get appAboutVersionError => 'Konnte die App-Version nicht laden.';
  String get appTutorialToolIsland => 'Tippe hier, um dein Tool mit anderen Tools zu kombinieren.';
  String get appTutorialToolSave => 'Tippe hier, um dein Tool in ein anderes Projekt zu kopieren.';

  String get commonBasicBeat => 'Grundschlag';
  String get commonBasicBeatSetting => 'Grundschlag einstellen';
  String get commonBpm => 'BPM';
  String get commonCancel => 'Abbrechen';
  String get commonDelete => 'Löschen?';
  String get commonGotIt => 'Verstanden';
  String get commonInput => 'Eingabefeld';
  String get commonMinus => 'Minus-Schaltfläche';
  String get commonNext => 'Weiter';
  String get commonNo => 'Nein';
  String get commonOctave => 'Oktave';
  String get commonPlus => 'Plus-Schaltfläche';
  String get commonProceed => 'Fortfahren';
  String get commonReorder => 'Verschieben';
  String get commonReset => 'Zurücksetzen';
  String get commonSetVolume => 'Lautstärke einstellen';
  String get commonSlider => 'Schieberegler';
  String get commonSubmit => 'Bestätigen';
  String get commonTextField => 'Textfeld';
  String get commonVolume => 'Lautstärke';
  String get commonVolumeHintLow =>
      'Die Lautstärke deines Geräts ist niedrig. Wenn nötig, erhöhe die Lautstärke des Geräts zusätzlich zur Lautstärke des Tools.';
  String get commonVolumeHintMid =>
      'Falls du das Tool in deiner aktuellen Umgebung nicht gut hören kannst, verbinde dein Gerät z.B. per Bluetooth mit einem externen Lautsprecher.';
  String get commonVolumeHintMuted => 'Dein Gerät ist stummgeschaltet. Aktiviere den Ton, um das Tool hören zu können.';
  String get commonYes => 'Ja';

  String get feedbackCta => 'Ausfüllen';
  String get feedbackQuestion => 'Gefällt dir TIO Music? Bitte mach mit bei unserer Umfrage!';
  String get feedbackTitle => 'Feedback-Umfrage';

  String get home => 'Startseite';
  String get homeAbout => 'Über TIO Music';
  String get homeFeedback => 'Feedback';

  String get image => 'Bild';
  String get imageAbout => 'Bild';
  String get imageAboutExplanation =>
      'Über die Kamera deines Endgeräts kannst du Notizen in Bildform erstellen sowie Bilder und Notenblätter in die App laden.';
  String get imageDescription => 'Lade ein Bild oder nimm ein neues Foto auf.';
  String get imageDoLater => 'Später';
  String get imageNoCameraFound => 'Keine Kamera gefunden';
  String get imageNoCameraFoundHint => 'Es ist keine Kamera auf diesem Gerät verfügbar.';
  String get imagePickImage => 'Bild(er) auswählen';
  String get imagePickNewImage => 'Neue(s) Bild(er) auswählen';
  String get imagePickOrTakeImage => 'Bitte lade ein Foto hoch oder mache ein neues Foto.';
  String get imageSetAsProjectThumbnail => 'Projektbild festlegen';
  String get imageSetAsThumbnail => 'Als Projektbild festlegen';
  String get imageSetAsThumbnailQuestion => 'Möchtest du das Bild als Projektbild verwenden?';
  String get imageShare => 'Bild teilen';
  String get imageTakePhoto => 'Foto aufnehmen';
  String get imageTakeNewPhoto => 'Neues Foto aufnehmen';
  String get imageUploadHint =>
      'Wähle ein oder mehrere Bilder von deinem Gerät aus oder mache ein Foto mit der Kamera.\n\nDu kannst bis zu 10 Bilder gleichzeitig hochladen. Das erste Bild wird hier gespeichert und für alle weiteren Bilder wird ein separates Bild-Tool angelegt.';
  String get imageUseAsThumbnailQuestion => 'Das erste Bild als Projektbild verwenden?';

  String get mainErrorDataLoading => 'Benutzerdaten konnten nicht geladen werden!';
  String get mainOpenAnyway => 'Trotzdem öffnen (alle Daten gehen verloren!)';
  String get mainRetry => 'Erneut versuchen';
  String get mainSplashScreen => 'Ladebildschirm';

  String get mediaPlayer => 'Media Player';
  String get mediaPlayerAbout => 'Media Player';
  String get mediaPlayerAboutExplanation =>
      'Du kannst Audiodateien aufnehmen, laden, bearbeiten und Konfigurationen speichern. Dabei kannst du deine bevorzugte Lautstärke, Range (Dauer und Ausschnitt), die Wiedergabegeschwindigkeit und die Tonhöhe (Transpose-Funktion) einstellen. Du hast die Möglichkeit, deine gespeicherten Projekte mithilfe von externen Messenger-Diensten an andere weiterzuleiten.';
  String get mediaPlayerAddMarker => 'Marker hinzufügen';
  String get mediaPlayerDescription => 'Lade Audio-Files oder nimm etwas auf, hör es dir an und bearbeite es.';
  String get mediaPlayerEditMarkers => 'Marker bearbeiten';
  String get mediaPlayerErrorFileAccessible => 'Datei nicht lesbar';
  String get mediaPlayerErrorFileAccessibleDescription =>
      'Die Datei ist nicht lesbar. Bitte überprüfe, ob sie lokal auf deinem Gerät gespeichert ist und das sie lizenzrechtlich in dieser App verwendet werden darf.';
  String get mediaPlayerErrorFileFormat => 'Dateiformat nicht unterstützt';
  String get mediaPlayerErrorFileOpen => 'Die Datei konnte nicht geöffnet werden';
  String get mediaPlayerErrorFileOpenDescription =>
      'Die Datei konnte nicht geöffnet werden. Versuche es noch einmal oder wähle eine andere Datei.';
  String get mediaPlayerFactor => 'Faktor';
  String get mediaPlayerFactorAndBpm => 'Faktor und BPM-Regler';
  String get mediaPlayerFile => 'Datei';
  String get mediaPlayerLooping => 'Loopen';
  String get mediaPlayerLoopingAll => 'Alle Media Player loopen';
  String get mediaPlayerMarkers => 'Marker';
  String get mediaPlayerOpenFileSystem => 'Öffne Dateien';
  String get mediaPlayerOpenMediaLibrary => 'Öffne Mediathek';
  String get mediaPlayerOverwriteSound => 'Audio-Datei überschreiben?';
  String get mediaPlayerOverwriteSoundQuestion =>
      'Möchtest du die aktuelle Audio-Datei überschreiben und die Aufnahme starten?';
  String get mediaPlayerPitch => 'Tonhöhe';
  String get mediaPlayerRecording => 'Aufnahme läuft...';
  String get mediaPlayerRemoveMarker => 'Ausgewählten Marker entfernen';
  String get mediaPlayerSecShort => 'Sek.';
  String get mediaPlayerSemitonesLabel => 'Halbtöne';
  String get mediaPlayerSetPitch => 'Tonhöhe einstellen';
  String get mediaPlayerSetSpeed => 'Tempo einstellen';
  String get mediaPlayerSetTrim => 'Trimmbereich festlegen';
  String get mediaPlayerShareAudioFile => 'Audio-Datei teilen';
  String get mediaPlayerSpeed => 'Tempo';
  String get mediaPlayerTapToTempo => 'Tippe im Takt';
  String get mediaPlayerTooManyFilesDescription =>
      'Aus technischen Gründen werden nur 10 Dateien gleichzeitig geladen.\n\nBitte wiederhole den Vorgang mit den übrigen Dateien, die in diesem Schritt nicht geladen wurden.';
  String get mediaPlayerTooManyFilesTitle => 'Zu viele Dateien';
  String get mediaPlayerTrim => 'Trimmen';
  String get mediaPlayerTutorialAdjust =>
      'Tippe hier, um deine Audiodatei anzupassen. Du kannst die Lautstärke und den Grundschlag einstellen, deine Datei trimmen und Marker setzen, sowie Tonhöhe und Tempo nachträglich verändern.';
  String get mediaPlayerTutorialJumpTo =>
      'Tippe auf eine beliebige Stelle, um zu diesem Teil deiner Audiodatei zu springen.';
  String get mediaPlayerTutorialStartStop =>
      'Tippe hier, um die Aufnahme zu starten und zu stoppen oder um eine Audiodatei abzuspielen.';

  String mediaPlayerErrorFileFormatDescription(String format) =>
      'Das Dateiformat $format wird nicht unterstützt. Bitte wähle eine andere Datei.';
  String mediaPlayerSemitones(int value) => value.abs() == 1 ? '$value Halbton' : '$value Halbtöne';

  String get metronome => 'Metronom';
  String get metronomePrimary => 'Metronom 1';
  String get metronomeSecondary => 'Metronom 2';
  String get metronomeAbout => 'Metronom';
  String get metronomeAboutExplanation =>
      'Du kannst ein Metronom nutzen und dabei deine individuellen Konfigurationen (Tempo, Taktart, Polyrhythmen, Random mute, Sound u. a.) speichern und abrufen. Du kannst das Metronom auch mit einem anderen Tool kombinieren.';
  String get metronomeAccented => 'Betont';
  String get metronomeBeatMain => 'Main Beat';
  String get metronomeBeatPoly => 'Poly Beat';
  String get metronomeClearAllRhythms => 'Alle Rhythmen löschen';
  String get metronomeDescription => 'Übe oder gestalte deinen eigenen Rhythmus.';
  String get metronomeNumberOfBeats => 'Anzahl der Beats';
  String get metronomeNumberOfPolyBeats => 'Anzahl der Poly Beats';
  String get metronomeRandomMute => 'Random mute';
  String get metronomeRandomMuteChance => 'Aussetzen';
  String get metronomeRandomMuteProbability => 'Wahrscheinlichkeit in %';
  String get metronomeResetDialogHint =>
      'ACHTUNG: Dadurch werden der Metronomrhythmus und -sound auf die Standardeinstellungen zurückgesetzt. Alle deine aktuellen Einstellungen gehen verloren. Möchtest du fortfahren?';
  String get metronomeResetDialogTitle => 'Metronome zurücksetzen?';
  String get metronomeRhythmDottedEighthFollowedBySixteenth => 'Punktierte Achtel gefolgt von Sechzehntel';
  String get metronomeRhythmEighthRestFollowedByEighth => 'Achtelpause gefolgt von Achtel';
  String get metronomeRhythmEighths => 'Achtel';
  String get metronomeRhythmPattern => 'Rhythmus-Pattern';
  String get metronomeRhythmQuarter => 'Viertel';
  String get metronomeRhythmSixteenthFollowedByDottedEighth => 'Sechzehntel gefolgt von punktierter Achtel';
  String get metronomeRhythmSixteenths => 'Sechzehntel';
  String get metronomeRhythmTriplets => 'Triole';
  String get metronomeSetBpm => 'BPM einstellen';
  String get metronomeSetRandomMute => 'Random mute einstellen';
  String get metronomeSetSoundsPrimary => 'Sounds einstellen';
  String get metronomeSetSoundsSecondary => 'Sounds einstellen (Metronom 2)';
  String get metronomeSimpleModeOff => 'Wechsel zu erweitertem Modus';
  String get metronomeSimpleModeOn => 'Wechsel zu einfachem Modus';
  String get metronomeSound => 'Sound';
  String get metronomeSoundMain => 'Main';
  String get metronomeSoundPoly => 'Poly Sound';
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
  String get metronomeTutorialAddNew => 'Tippe hier, um ein zweites Metronom hinzuzufügen.';
  String get metronomeTutorialAdjust => 'Tippe hier, um die Metronomeinstellungen anzupassen.';
  String get metronomeTutorialModeAdvanced =>
      'Halte und ziehe seitlich, um Takte zu verschieben, wische nach oben, um Takte zu löschen oder tippe, um den ausgewählten Takt zu bearbeiten.';
  String get metronomeTutorialModeChange =>
      'Über das Menü oben rechts kannst du zwischen einfachem und erweitertem Modus wechseln.';
  String get metronomeTutorialModeSimple => 'Hier kannst du die Basic Beats und einen Rhytmus festlegen.';
  String get metronomeTutorialEditBeats =>
      'Tippe auf einen der Schläge, um zwischen betont, unbetont und stumm zu wechseln.';
  String get metronomeTutorialStartStop => 'Tippe hier, um das Metronom zu starten und zu stoppen.';
  String get metronomeUnaccented => 'Unbetont';

  String metronomeSegment(int value) => '$value ${value == 1 ? 'Segment' : 'Segmente'}';

  String get piano => 'Piano';
  String get pianoAbout => 'Piano';
  String get pianoAboutExplanation =>
      'Du kannst ein virtuelles Piano nutzen, unterschiedliche Klänge wählen, Aufnahmen erstellen und deine individuellen Einstellungen speichern.';
  String get pianoConcertPitchInHz => 'Kammerton in Hz';
  String get pianoDescription => 'Spiele ein Stück an oder teste ein paar Akkorde.';
  String get pianoInstrumentElectricPiano1 => 'E-Piano 1';
  String get pianoInstrumentElectricPiano2 => 'E-Piano 2';
  String get pianoInstrumentElectricPianoHold => 'E-Piano (H)';
  String get pianoInstrumentGrandPiano1 => 'Piano 1';
  String get pianoInstrumentGrandPiano2 => 'Piano 2';
  String get pianoInstrumentHarpsichord => 'Cembalo';
  String get pianoInstrumentPipeOrgan => 'Orgel (H)';
  String get pianoLowestKey => 'Tiefste Taste';
  String get pianoSetConcertPitch => 'Kammerton einstellen';
  String get pianoSetSound => 'Piano-Sound einstellen';
  String get pianoTutorialAdjust => 'Tippe hier, um den Kammerton, die Lautstärke oder den Klang anzupassen.';
  String get pianoTutorialChangeKeyOrOctave =>
      'Tippe auf die Pfeile links oder rechts, um die Tastatur um eine Taste oder um eine Oktave nach oben oder unten zu verschieben.';

  String get projectDelete => 'Project löschen';
  String get projectDeleteTool => 'Tool löschen';
  String get projectDeleteAllTools => 'Alle Tools löschen';
  String get projectDeleteAllToolsConfirmation => 'Möchtest du wirklich alle Tools in diesem Projekt löschen?';
  String get projectDeleteToolConfirmation => 'Möchtest du dieses Tool wirklich löschen?';
  String get projectDetails => 'Projektdetails';
  String get projectEditTools => 'Tools editieren';
  String get projectEditToolsDone => 'Editieren beenden';
  String get projectEmpty => 'Wähle ein Tool.';
  String get projectExport => 'Projekt exportieren';
  String get projectExportCancelled => 'Projektexport abgebrochen';
  String get projectExportError => 'Fehler beim Exportieren des Projekts';
  String get projectExportSuccess => 'Projekt erfolgreich exportiert!';
  String get projectMenu => 'Projektmenü';
  String get projectNew => 'Projekttitel';
  String get projectNewTool => 'Tool-Titel';
  String get projectToolList => 'Tool-Liste';
  String get projectToolListEmpty => 'Leere Tool-Liste';
  String get projectTutorialChangeToolOrder =>
      'Tippe auf das Plus-Symbol um ein neues Tool hinzuzufügen oder auf das Stift-Symbol um die Tools zu bearbeiten.';
  String get projectTutorialEditTitle => 'Tippe hier, um den Projekttitel zu bearbeiten.';

  String get projectsAbout => 'Projekte';
  String get projectsAboutExplanation =>
      'Alle Elemente lassen sich gemeinsam in Projekten abspeichern. So musst du z.B. das Metronom nicht jedes Mal neu einstellen oder dein Stimmgerät anpassen. Du kannst schnell und reibungslos da weitermachen, wo du beim letzten Mal aufgehört hast.';
  String get projectsAddNew => 'Neues Projekt hinzufügen';
  String get projectsDeleteAll => 'Alle Projekte löschen';
  String get projectsDeleteAllConfirmation => 'Möchtest du wirklich alle Projekte löschen?';
  String get projectsDeleteConfirmation => 'Möchtest du dieses Projekt wirklich löschen?';
  String get projectsEdit => 'Projekte editieren';
  String get projectsEditDone => 'Editieren beenden';
  String get projectsImport => 'Projekt importieren';
  String get projectsImportError => 'Fehler beim Importieren des Projekts';
  String get projectsImportNoFileSelected => 'Keine Projektdatei ausgewählt';
  String get projectsImportSuccess => 'Projekt erfolgreich importiert!';
  String get projectsMenu => 'Projekte-Menü';
  String get projectsNew => 'Neues Projekt';
  String get projectsNoProjects => 'Bitte klicke auf das "+", um ein neues Projekt zu erstellen.';
  String get projectsTutorialAddProject => 'Tippe hier, um ein neues Projekt zu erstellen.';
  String get projectsTutorialCanIncludeMultipleTools =>
      'Projekte können mehrere Tools enthalten\n(Stimmgerät, Metronom, Piano, Media Player, Bild und Text),\nund sogar mehrere Tools desselben Typs.';
  String get projectsTutorialChangeProjectOrder =>
      'Tippe auf das Plus-Symbol um ein neues Projekt hinzuzufügen oder auf das Stift-Symbol um die Projekte zu bearbeiten.';
  String get projectsTutorialHowToUseTio =>
      'Willkommen! Du kannst TIO auf zwei Arten verwenden.\n1. Erstelle ein Projekt und füge Tools hinzu.\n2. Starte mit der Verwendung eines Tools und speichere deine spezifischen Einstellungen in einem Projekt.';
  String get projectsTutorialStart => 'Tutorial anzeigen';
  String get projectsTutorialStartUsingTool => 'Tippe hier, um ein Tool zu verwenden.';

  String get text => 'Text';
  String get textAbout => 'Text';
  String get textAboutExplanation =>
      'Über dein Endgerät kannst du Notizen in Textform erstellen, z. B. für Spielanweisungen, Hintergrundinformationen, Songtexte etc.';
  String get textDescription => 'Mach dir Notizen.';
  String get textImport => 'Text importieren';
  String get textImportDialogHint =>
      'ACHTUNG: Wenn du einen Text importierst, wird der aktuelle Inhalt des Text-Tools überschrieben.';
  String get textImportDialogTitle => 'Text importieren?';
  String get textImportError => 'Fehler beim Importieren der Text-Datei';
  String get textImportNoFileSelected => 'Keine Text-Datei ausgewählt';
  String get textImportSuccess => 'Text erfolgreich importiert!';

  String get toolAddNew => 'Tool hinzufügen';
  String get toolConnectAnother => 'Verbinde ein anderes Tool';
  String get toolConnectExistingTool => 'Verbinde ein Tool';
  String get toolConnectNewTool => 'Verbinde ein neues Tool';
  String get toolEmpty => 'Leerer Block';
  String get toolNewProjectTitle => 'Projekttitel';
  String get toolNewTitle => 'Tool-Titel';
  String get toolGoToNext => 'Gehe zu nächstem Tool';
  String get toolGoToNextOfSameType => 'Gehe zu nächstem Tool des gleichen Typs';
  String get toolNoOtherToolAvailable =>
      'Kein anderes Tool im Projekt verfügbar. Bitte speichere zuerst ein anderes Tool, um es mit diesem Tool verknüpfen zu können.';
  String get toolGoToPrev => 'Gehe zu vorherigem Tool';
  String get toolGoToPrevOfSameType => 'Gehe zu vorherigem Tool des gleichen Typs';
  String get toolQuickTool => 'Tool';
  String get toolQuickToolSave => 'Tool speichern?';
  String get toolSave => 'Speichern in ...';
  String get toolSaveCopy => 'Kopie speichern in ...';
  String get toolSaveInNewProject => 'In neuem Projekt speichern';
  String get toolTitleCopy => 'Kopie';
  String get toolTutorialEditTitle => 'Tippe hier, um den Titel deines Tools zu bearbeiten.';
  String get toolTutorialSave =>
      'Tippe hier, um das Tool in einem Projekt zu speichern.\n\nSobald sich dieses Tool in einem Projekt befindet, kannst du es mit anderen Tools verknüpfen.';
  String get toolUseBookmarkToSave => 'Verwende das Lesezeichen, um das Tool zu speichern.';

  String toolHasNoIslandView(String tool) => '$tool hat keine Kompaktansicht!';

  String get tuner => 'Stimmgerät';
  String get tunerAbout => 'Stimmgerät';
  String get tunerAboutExplanation =>
      'Du kannst deine Instrumente nach beliebigem Kammerton stimmen, Referenztöne abspielen, deine individuelle Konfiguration speichern sowie das Stimmgerät mit anderen Tools zusammen nutzen.';
  String get tunerConcertPitch => 'Kammerton';
  String get tunerConcertPitchInHz => 'Kammerton in Hz';
  String get tunerDescription => 'Stimme dein Instrument oder nutze Referenztöne.';
  String get tunerFrequency => 'Frequenz';
  String get tunerInstrument => 'Instrument';
  String get tunerPlayReference => 'Referenzton abspielen';
  String get tunerSetConcertPitch => 'Kammerton einstellen';
  String get tunerTutorialAdjust => 'Tippe hier, um den Kammerton anzupassen oder einen Referenzton abzuspielen.';
  String get tunerTutorialStartStop =>
      'Tippe hier, um das Stimmgerät zu starten und zu stoppen.\n\nWenn der Ton ausklingt, können Obertöne das Stimmgerät irritieren – schlage den Ton daher besser neu an.';
  String get tunerTypeChromatic => 'Chromatisches Stimmgerät';
  String get tunerTypeBass => 'Bass';
  String get tunerTypeGuitar => 'Gitarre';
  String get tunerTypeUkulele => 'Ukulele';
  String get tunerTypeViola => 'Viola';
  String get tunerTypeViolin => 'Violine';
  String get tunerTypeVioloncello => 'Violoncello';

  String formatDateAndTime(DateTime time) => DateFormat('dd.MM.yyyy - HH:mm:ss').format(time);
}
