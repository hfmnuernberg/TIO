import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/metronome_block.dart';
import 'package:tiomusic/models/note_handler.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/models/rhythm_group.dart';
import 'package:tiomusic/pages/metronome/metronome_functions.dart';
import 'package:tiomusic/pages/metronome/metronome_utils.dart';
import 'package:tiomusic/pages/parent_tool/parent_setting_page.dart';
import 'package:tiomusic/services/file_system.dart';
import 'package:tiomusic/services/project_repository.dart';
import 'package:tiomusic/src/rust/api/api.dart';
import 'package:tiomusic/src/rust/api/modules/metronome.dart';
import 'package:tiomusic/src/rust/api/modules/metronome_rhythm.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/util/log.dart';
import 'package:tiomusic/util/tutorial_util.dart';
import 'package:tiomusic/util/util_functions.dart';
import 'package:tiomusic/widgets/custom_border_shape.dart';
import 'package:tiomusic/widgets/input/small_number_input_int.dart';
import 'package:tiomusic/widgets/metronome/beat/beat_button_type.dart';
import 'package:tiomusic/widgets/metronome/beat/beat_circle.dart';
import 'package:tiomusic/widgets/metronome/current_beat.dart';
import 'package:tiomusic/widgets/metronome/note/note_table.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class AdvancedRhythmGroupEditor extends StatefulWidget {
  final MetronomeBlock metronomeBlock;
  final List<RhythmGroup> rhythmGroups;
  final int? rhythmGroupIndex;
  final String currentNoteKey;
  final List<BeatType> currentMainBeats;
  final List<BeatTypePoly> currentPolyBeats;
  final bool isAddingNewRhythmGroup;
  final bool isSecondMetronome;

  const AdvancedRhythmGroupEditor({
    super.key,
    required this.metronomeBlock,
    required this.rhythmGroups,
    this.rhythmGroupIndex,
    required this.currentNoteKey,
    required this.currentMainBeats,
    required this.currentPolyBeats,
    required this.isAddingNewRhythmGroup,
    required this.isSecondMetronome,
  });

  @override
  State<AdvancedRhythmGroupEditor> createState() => _AdvancedRhythmGroupEditorState();
}

class _AdvancedRhythmGroupEditorState extends State<AdvancedRhythmGroupEditor> {
  static final logger = createPrefixLogger('AdvancedRhythmGroupEditor');

  late FileSystem fs;

  late String noteKey;

  int mainBeatCount = 0;
  int polyBeatCount = 0;

  final List<BeatType> mainBeats = List.empty(growable: true);
  final List<BeatTypePoly> polyBeats = List.empty(growable: true);

  CurrentBeat currentBeat = CurrentBeat();

  bool isPlaying = false;
  bool processingButtonClick = false;

  late Timer beatDetection;

  final Tutorial tutorial = Tutorial();
  final GlobalKey keyToggleBeats = GlobalKey();

  @override
  void initState() {
    super.initState();

    fs = context.read<FileSystem>();

    if (widget.isSecondMetronome) {
      MetronomeUtils.loadMetro2SoundsIntoMetro1(fs, widget.metronomeBlock);
    }

    mainBeats.addAll(widget.currentMainBeats);
    polyBeats.addAll(widget.currentPolyBeats);
    noteKey = widget.currentNoteKey;

    mainBeatCount = mainBeats.length;
    polyBeatCount = polyBeats.length;

    beatDetection = Timer.periodic(const Duration(milliseconds: MetronomeParams.beatDetectionDurationMillis), (
      t,
    ) async {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (!isPlaying) return;

      final event = await metronomePollBeatEventHappened();
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

  void onBeatHappened(BeatHappenedEvent event) {
    Timer(Duration(milliseconds: event.millisecondsBeforeStart), () {
      currentBeat = MetronomeUtils.getCurrentPrimaryBeatFromEvent(isOn: true, event: event);
      setState(() {});
    });

    Timer(Duration(milliseconds: event.millisecondsBeforeStart + MetronomeParams.flashDurationInMs), () {
      if (!mounted) return;
      currentBeat = MetronomeUtils.getCurrentPrimaryBeatFromEvent(isOn: false, event: event);
      setState(() {});
    });
  }

  void createTutorial() {
    final targets = <CustomTargetFocus>[
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
      mainBeatCount = newBeatCount;

      if (newBeatCount > mainBeats.length) {
        mainBeats.addAll(List.filled(newBeatCount - mainBeats.length, BeatType.Unaccented));
      } else if (newBeatCount < mainBeats.length) {
        mainBeats.removeRange(newBeatCount, mainBeats.length);
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

  void refreshRhythm() =>
      metronomeSetRhythm(bars: getRhythmAsMetroBar([RhythmGroup('', mainBeats, polyBeats, noteKey)]), bars2: []);

  void selectIcon(String chosenNoteKey) {
    noteKey = chosenNoteKey;
    refreshRhythm();
    setState(() {});
  }

  Future<void> onConfirm() async {
    stopBeat();

    if (widget.isAddingNewRhythmGroup) {
      widget.rhythmGroups.add(RhythmGroup(MetronomeParams.getNewKeyID(), mainBeats, polyBeats, noteKey));
    } else if (widget.rhythmGroupIndex != null) {
      final group = widget.rhythmGroups[widget.rhythmGroupIndex!];
      group.beats
        ..clear()
        ..addAll(mainBeats);
      group.polyBeats
        ..clear()
        ..addAll(polyBeats);
      group.noteKey = noteKey;
      group.beatLen = NoteHandler.getBeatLength(noteKey);
    }

    MetronomeUtils.loadSounds(fs, widget.metronomeBlock);

    await context.read<ProjectRepository>().saveLibrary(context.read<ProjectLibrary>());
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  void reset() {
    selectIcon(MetronomeParams.defaultNoteKey);
    mainBeatCount = MetronomeParams.defaultBeats.length;
    polyBeatCount = MetronomeParams.defaultPolyBeats.length;

    for (int i = 0; i < mainBeats.length; i++) {
      mainBeats[i] = MetronomeParams.defaultBeats[i];
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
            Stack(
              alignment: AlignmentDirectional.center,
              children: [
                BeatCircle(
                  beatCount: mainBeats.length,
                  beatTypes: BeatButtonType.fromMainBeatTypes(mainBeats),
                  currentBeatIndex: currentBeat.mainBeatIndex,
                  isPlaying: isPlaying,
                  centerWidgetRadius: MediaQuery.of(context).size.width / 3,
                  buttonSize: TIOMusicParams.beatButtonSizeBig,
                  beatButtonColor: ColorTheme.surfaceTint,
                  noInnerBorder: true,
                  onStartStop: startStopBeatPlayback,
                  onTap: (index) {
                    setState(() {
                      mainBeats[index] = getBeatTypeOnTap(mainBeats[index]);
                      refreshRhythm();
                    });
                  },
                ),
                BeatCircle(
                  beatCount: polyBeats.length,
                  beatTypes: BeatButtonType.fromPolyBeatTypes(polyBeats),
                  currentBeatIndex: currentBeat.polyBeatIndex,
                  isPlaying: isPlaying,
                  centerWidgetRadius: MediaQuery.of(context).size.width / 5,
                  buttonSize: TIOMusicParams.beatButtonSizeSmall,
                  beatButtonColor: ColorTheme.primary60,
                  noInnerBorder: false,
                  onStartStop: startStopBeatPlayback,
                  onTap: (index) {
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
                  value: mainBeatCount,
                  onChange: onBeatCountChange,
                  min: 1,
                  max: MetronomeParams.maxBeatCount,
                  step: 1,
                  label: l10n.metronomeNumberOfBeats,
                  buttonRadius: MetronomeParams.popupButtonRadius,
                  textFontSize: MetronomeParams.popupTextFontSize,
                ),
                SmallNumberInputInt(
                  value: polyBeatCount,
                  onChange: onPolyBeatCountChange,
                  max: MetronomeParams.maxBeatCount,
                  decrementStep: 1,
                  incrementStep: 1,
                  label: l10n.metronomeNumberOfPolyBeats,
                  buttonRadius: MetronomeParams.popupButtonRadius,
                  textFontSize: MetronomeParams.popupTextFontSize,
                ),
              ],
            ),
            NoteTable(selected: noteKey, onSelect: selectIcon),
          ],
        ),
      ),
    );
  }
}
