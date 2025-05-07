// Setting page for rhythm segments
// Called when a new rhythm segment is initialized and when an existing one is tapped

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/metronome_block.dart';
import 'package:tiomusic/models/note_handler.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/models/rhythm_group.dart';
import 'package:tiomusic/pages/metronome/beat_button.dart';
import 'package:tiomusic/pages/metronome/rhythm/beat_circle.dart';
import 'package:tiomusic/pages/metronome/metronome_functions.dart';
import 'package:tiomusic/pages/metronome/metronome_utils.dart';
import 'package:tiomusic/pages/metronome/rhythm/note_table.dart';
import 'package:tiomusic/pages/metronome/rhythm/rhythm_functions.dart';
import 'package:tiomusic/pages/metronome/rhythm/rhythm_segment.dart';
import 'package:tiomusic/pages/parent_tool/parent_setting_page.dart';
import 'package:tiomusic/services/file_system.dart';
import 'package:tiomusic/services/project_repository.dart';
import 'package:tiomusic/src/rust/api/api.dart';
import 'package:tiomusic/src/rust/api/modules/metronome.dart';
import 'package:tiomusic/src/rust/api/modules/metronome_rhythm.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/util/log.dart';
import 'package:tiomusic/util/util_functions.dart';
import 'package:tiomusic/util/tutorial_util.dart';
import 'package:tiomusic/widgets/custom_border_shape.dart';
import 'package:tiomusic/widgets/input/small_number_input_int.dart';
import 'package:tiomusic/widgets/small_icon_button.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class SetRhythmParameters extends StatefulWidget {
  final int? barIndex;
  final String currentNoteKey;
  final List<BeatType> currentBeats;
  final List<BeatTypePoly> currentPolyBeats;
  final bool isAddingNewBar;
  final List<RhythmGroup> rhythmGroups;
  final bool isSecondMetronome;
  final MetronomeBlock metronomeBlock;

  const SetRhythmParameters({
    super.key,
    this.barIndex,
    required this.currentNoteKey,
    required this.currentBeats,
    required this.currentPolyBeats,
    required this.isAddingNewBar,
    required this.rhythmGroups,
    required this.isSecondMetronome,
    required this.metronomeBlock,
  });

  @override
  State<SetRhythmParameters> createState() => _SetRhythmParametersState();
}

class _SetRhythmParametersState extends State<SetRhythmParameters> {
  static final logger = createPrefixLogger('SetRhythmParameters');

  late FileSystem fs;

  int beatCount = 0;
  int polyBeatCount = 0;

  final int minNumberOfBeats = 1;
  final int minNumberOfPolyBeats = 0;

  late String noteKey;
  final List<BeatType> beats = List.empty(growable: true);
  final List<BeatTypePoly> polyBeats = List.empty(growable: true);

  bool isPlaying = false;
  bool processingButtonClick = false;
  bool isSimpleModeOn = true;

  late Timer beatDetection;
  final ActiveBeatsModel activeBeatsModel = ActiveBeatsModel();

  final Tutorial tutorial = Tutorial();
  final GlobalKey keyToggleBeats = GlobalKey();

  @override
  void initState() {
    super.initState();

    fs = context.read<FileSystem>();

    // we need to use the first metronome, because the first metronome cannot have no beats
    // so if we edit a beat of the second metronome, we just load the sounds of the second metronome into the first metronome
    if (widget.isSecondMetronome) {
      MetronomeUtils.loadMetro2SoundsIntoMetro1(fs, widget.metronomeBlock);
    }

    beats.addAll(widget.currentBeats);
    polyBeats.addAll(widget.currentPolyBeats);
    noteKey = widget.currentNoteKey;

    beatCount = beats.length;
    polyBeatCount = polyBeats.length;

    beatDetection = Timer.periodic(const Duration(milliseconds: MetronomeParams.beatDetectionDurationMillis), (
      t,
    ) async {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (!isPlaying) return;

      var event = await metronomePollBeatEventHappened();
      if (event != null) {
        onBeatHappened(event);
        setState(() {});
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<ProjectLibrary>().showBeatToggleTip) {
        createTutorial();
        tutorial.show(context);
      }
    });
  }

  @override
  void dispose() {
    stopBeat();
    beatDetection.cancel();
    super.dispose();
  }

  @override
  void deactivate() {
    stopBeat();
    beatDetection.cancel();
    super.deactivate();
  }

  void toggleSimpleMode() {
    setState(() => isSimpleModeOn = !isSimpleModeOn);
    if (isSimpleModeOn) onPolyBeatCountChange(beatCount);
  }

  // React to beat signal
  void onBeatHappened(BeatHappenedEvent event) {
    Timer(Duration(milliseconds: event.millisecondsBeforeStart), () {
      setState(() {
        activeBeatsModel.setBeatOnOff(true, event.barIndex, event.beatIndex, event.isPoly, event.isSecondary);
      });
    });

    Timer(Duration(milliseconds: event.millisecondsBeforeStart + MetronomeParams.flashDurationInMs), () {
      if (!mounted) return;
      setState(() {
        activeBeatsModel.setBeatOnOff(false, event.barIndex, event.beatIndex, event.isPoly, event.isSecondary);
      });
    });
  }

  void createTutorial() {
    // add the targets here
    var targets = <CustomTargetFocus>[
      CustomTargetFocus(
        keyToggleBeats,
        context.l10n.metronomeTutorialEditBeats,
        alignText: ContentAlign.bottom,
        pointingDirection: PointingDirection.up,
      ),
    ];
    tutorial.create(targets.map((e) => e.targetFocus).toList(), () async {
      context.read<ProjectLibrary>().showBeatToggleTip = false;
      await context.read<ProjectRepository>().saveLibrary(context.read<ProjectLibrary>());
    }, context);
  }

  void onBeatCountChange(int newBeatCount) {
    setState(() {
      beatCount = newBeatCount;
      if (isSimpleModeOn) polyBeatCount = newBeatCount;

      if (newBeatCount > beats.length) {
        beats.addAll(List.filled(newBeatCount - beats.length, BeatType.Unaccented));
      } else if (newBeatCount < beats.length) {
        beats.removeRange(newBeatCount, beats.length);
      }

      refreshRhythm();
    });
  }

  void onPolyBeatCountChange(int newPolyBeatCount) {
    setState(() {
      polyBeatCount = newPolyBeatCount;

      if (newPolyBeatCount > polyBeats.length) {
        polyBeats.addAll(List.filled(newPolyBeatCount - polyBeats.length, BeatTypePoly.Unaccented));
      } else if (newPolyBeatCount < polyBeats.length) {
        polyBeats.removeRange(newPolyBeatCount, polyBeats.length);
      }

      refreshRhythm();
    });
  }

  void startStopBeatPlayback() async {
    if (processingButtonClick) return;
    setState(() => processingButtonClick = true);

    if (isPlaying) {
      await stopBeat();
    } else {
      await startBeat();
    }

    await Future.delayed(const Duration(milliseconds: TIOMusicParams.millisecondsPlayPauseDebounce));
    setState(() => processingButtonClick = false);
  }

  Future<void> startBeat() async {
    // set beat in rust
    refreshRhythm();

    await MetronomeFunctions.stop();
    final success = await MetronomeFunctions.start();
    if (!success) {
      logger.e('Unable to start metronome.');
      return;
    }
    isPlaying = true;
  }

  Future<void> stopBeat() async {
    await metronomeStop();
    isPlaying = false;
  }

  BeatType getBeatTypeOnTap(BeatType currentType) {
    if (currentType == BeatType.Accented) {
      return BeatType.Muted;
    } else if (currentType == BeatType.Unaccented) {
      return BeatType.Accented;
    } else {
      return BeatType.Unaccented;
    }
  }

  BeatTypePoly getBeatTypePolyOnTap(BeatTypePoly currentType) {
    if (currentType == BeatTypePoly.Accented) {
      return BeatTypePoly.Muted;
    } else if (currentType == BeatTypePoly.Unaccented) {
      return BeatTypePoly.Accented;
    } else {
      return BeatTypePoly.Unaccented;
    }
  }

  void refreshRhythm() {
    final bars = getRhythmAsMetroBar([RhythmGroup('', beats, polyBeats, noteKey)]);
    metronomeSetRhythm(bars: bars, bars2: []);
  }

  void selectIcon(String chosenNoteKey) {
    setState(() {
      noteKey = chosenNoteKey;
      refreshRhythm();
    });
  }

  Future<void> onConfirm() async {
    stopBeat();

    if (widget.isAddingNewBar) {
      widget.rhythmGroups.add(RhythmGroup(MetronomeParams.getNewKeyID(), beats, polyBeats, noteKey));
    } else if (widget.barIndex != null) {
      widget.rhythmGroups[widget.barIndex!].beats.clear();
      beats.forEach(widget.rhythmGroups[widget.barIndex!].beats.add);

      widget.rhythmGroups[widget.barIndex!].polyBeats.clear();
      polyBeats.forEach(widget.rhythmGroups[widget.barIndex!].polyBeats.add);

      widget.rhythmGroups[widget.barIndex!].noteKey = noteKey;
      widget.rhythmGroups[widget.barIndex!].beatLen = NoteHandler.getBeatLength(noteKey);
    }

    MetronomeUtils.loadSounds(fs, widget.metronomeBlock);

    await context.read<ProjectRepository>().saveLibrary(context.read<ProjectLibrary>());
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  void reset() {
    selectIcon(MetronomeParams.defaultNoteKey);
    beatCount = MetronomeParams.defaultBeats.length;
    polyBeatCount = MetronomeParams.defaultPolyBeats.length;

    for (var i = 0; i < beats.length; i++) {
      beats[i] = MetronomeParams.defaultBeats[i];
    }

    refreshRhythm();
  }

  void onCancel() {
    stopBeat();
    MetronomeUtils.loadSounds(fs, widget.metronomeBlock);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ParentSettingPage(
      title: l10n.metronomeSetBpm,
      confirm: onConfirm,
      reset: reset,
      cancel: onCancel,
      mustBeScrollable: true,
      customWidget: Padding(
        padding: const EdgeInsets.all(TIOMusicParams.edgeInset),
        child: Column(
          children: [
            // planets
            Stack(
              alignment: AlignmentDirectional.center,
              children: [
                Positioned(
                  top: 0,
                  right: 0,
                  child: SmallIconButton(
                    icon: Icon(isSimpleModeOn ? Icons.music_note : Icons.tune, color: ColorTheme.tertiary),
                    onPressed: toggleSimpleMode,
                  ),
                ),
                BeatCircle(
                  beatCount: beats.length,
                  beatTypes: getBeatButtonsFromBeats(beats),
                  currentBeatIndex: activeBeatsModel.mainBeatOn ? activeBeatsModel.mainBeat : null,
                  isPlaying: isPlaying,
                  centerWidgetRadius: MediaQuery.of(context).size.width / 3,
                  buttonSize: TIOMusicParams.beatButtonSizeBig,
                  beatButtonColor: ColorTheme.surfaceTint,
                  noInnerBorder: true,
                  onStartStop: startStopBeatPlayback,
                  onTapBeat: (index) {
                    setState(() {
                      beats[index] = getBeatTypeOnTap(beats[index]);
                      refreshRhythm();
                    });
                  },
                ),
                BeatCircle(
                  beatCount: polyBeats.length,
                  beatTypes: getBeatButtonsFromBeatsPoly(polyBeats),
                  currentBeatIndex: activeBeatsModel.polyBeatOn ? activeBeatsModel.polyBeat : null,
                  isPlaying: isPlaying,
                  centerWidgetRadius: MediaQuery.of(context).size.width / 5,
                  buttonSize: TIOMusicParams.beatButtonSizeSmall,
                  beatButtonColor: ColorTheme.primary60,
                  noInnerBorder: false,
                  onStartStop: startStopBeatPlayback,
                  onTapBeat: (index) {
                    setState(() {
                      polyBeats[index] = getBeatTypePolyOnTap(polyBeats[index]);
                      refreshRhythm();
                    });
                  },
                ),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SmallNumberInputInt(
                  value: beatCount,
                  onChange: onBeatCountChange,
                  min: minNumberOfBeats,
                  max: MetronomeParams.maxBeatCount,
                  step: 1,
                  label: l10n.metronomeNumberOfBeats,
                  buttonRadius: MetronomeParams.popupButtonRadius,
                  textFontSize: MetronomeParams.popupTextFontSize,
                ),
                SmallNumberInputInt(
                  value: polyBeatCount,
                  onChange: onPolyBeatCountChange,
                  min: minNumberOfPolyBeats,
                  max: MetronomeParams.maxBeatCount,
                  decrementStep: isSimpleModeOn ? getDecrementStepForPolyBeat(beatCount, polyBeatCount) : 1,
                  incrementStep: isSimpleModeOn ? getIncrementStepForPolyBeat(beatCount, polyBeatCount) : 1,
                  label: l10n.metronomeNumberOfPolyBeats,
                  buttonRadius: MetronomeParams.popupButtonRadius,
                  textFontSize: MetronomeParams.popupTextFontSize,
                ),
              ],
            ),

            if (!isSimpleModeOn) NoteTable(selectedNoteKey: noteKey, onSelectNote: selectIcon),
          ],
        ),
      ),
    );
  }
}
