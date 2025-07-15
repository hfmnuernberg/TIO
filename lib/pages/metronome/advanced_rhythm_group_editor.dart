import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/metronome_block.dart';
import 'package:tiomusic/models/note_handler.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/models/rhythm_group.dart';
import 'package:tiomusic/pages/parent_tool/parent_setting_page.dart';
import 'package:tiomusic/services/audio_system.dart';
import 'package:tiomusic/services/file_system.dart';
import 'package:tiomusic/services/project_repository.dart';
import 'package:tiomusic/src/rust/api/modules/metronome_rhythm.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/util/metronome.dart';
import 'package:tiomusic/util/tutorial_util.dart';
import 'package:tiomusic/widgets/custom_border_shape.dart';
import 'package:tiomusic/widgets/input/small_number_input_int.dart';
import 'package:tiomusic/widgets/metronome/beat/beat_button_type.dart';
import 'package:tiomusic/widgets/metronome/beat/beat_circle.dart';
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
  late final Metronome metronome;

  late String noteKey;

  final List<BeatType> mainBeats = List.empty(growable: true);
  final List<BeatTypePoly> polyBeats = List.empty(growable: true);

  bool processingButtonClick = false;

  final Tutorial tutorial = Tutorial();
  final GlobalKey keyToggleBeats = GlobalKey();

  @override
  void initState() {
    super.initState();

    metronome = Metronome(
      context.read<AudioSystem>(),
      context.read<FileSystem>(),
      onBeatStart: refresh,
      onBeatStop: refresh,
    );

    if (widget.isSecondMetronome) metronome.sounds.loadSecondarySoundsAsPrimary(widget.metronomeBlock);

    mainBeats.addAll(widget.currentMainBeats);
    polyBeats.addAll(widget.currentPolyBeats);
    noteKey = widget.currentNoteKey;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<ProjectLibrary>().showBeatToggleTip) {
        createTutorial();
        tutorial.show(context);
      }
    });
  }

  @override
  void deactivate() {
    metronome.stop();
    super.deactivate();
  }

  @override
  void dispose() {
    metronome.stop();
    super.dispose();
  }

  Future<void> refresh(_) async {
    if (!mounted) return metronome.stop();
    setState(() {});
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
      if (newPolyBeatCount > polyBeats.length) {
        polyBeats.addAll(List.filled(newPolyBeatCount - polyBeats.length, BeatTypePoly.Unaccented));
      } else if (newPolyBeatCount < polyBeats.length) {
        polyBeats.removeRange(newPolyBeatCount, polyBeats.length);
      }

      refreshRhythm();
    });
  }

  Future<void> startStopBeatPlayback() async {
    if (processingButtonClick) return;
    setState(() => processingButtonClick = true);

    if (metronome.isOn) {
      await stopMetronome();
    } else {
      await startMetronome();
    }

    await Future.delayed(const Duration(milliseconds: TIOMusicParams.millisecondsPlayPauseDebounce));
    setState(() => processingButtonClick = false);
  }

  void refreshRhythm() => metronome.setRhythm([RhythmGroup('', mainBeats, polyBeats, noteKey)]);

  Future<void> startMetronome() async {
    refreshRhythm();
    await metronome.restart();
  }

  Future<void> stopMetronome() async => metronome.stop();

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

  void selectIcon(String chosenNoteKey) {
    noteKey = chosenNoteKey;
    refreshRhythm();
    setState(() {});
  }

  Future<void> onConfirm() async {
    stopMetronome();

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

    metronome.sounds.loadAllSounds(widget.metronomeBlock);

    await context.read<ProjectRepository>().saveLibrary(context.read<ProjectLibrary>());
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  void reset() {
    selectIcon(MetronomeParams.defaultNoteKey);
    for (int i = 0; i < mainBeats.length; i++) {
      mainBeats[i] = MetronomeParams.defaultBeats[i];
    }
    polyBeats.clear();

    refreshRhythm();
  }

  void onCancel() {
    stopMetronome();
    metronome.sounds.loadAllSounds(widget.metronomeBlock);
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
              key: keyToggleBeats,
              alignment: AlignmentDirectional.center,
              children: [
                BeatCircle(
                  beatCount: mainBeats.length,
                  beatTypes: BeatButtonType.fromMainBeatTypes(mainBeats),
                  currentBeatIndex: metronome.currentBeat.mainBeatIndex,
                  isPlaying: metronome.isOn,
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
                  currentBeatIndex: metronome.currentBeat.polyBeatIndex,
                  isPlaying: metronome.isOn,
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
                  value: mainBeats.length,
                  onChange: onBeatCountChange,
                  min: 1,
                  max: MetronomeParams.maxBeatCount,
                  step: 1,
                  label: l10n.metronomeNumberOfBeats,
                  buttonRadius: MetronomeParams.popupButtonRadius,
                  textFontSize: MetronomeParams.popupTextFontSize,
                ),
                SmallNumberInputInt(
                  value: polyBeats.length,
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
