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
import 'package:tiomusic/pages/metronome/rhythm/rhythm_generator_setting_list_item.dart';
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
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

const List<String> wheelNoteKeys = [
  NoteValues.quarter,
  NoteValues.eighth,
  NoteValues.tuplet3Quarter,
  NoteValues.sixteenth,
  NoteValues.eighthDotted,
];

class SetRhythmParametersSimple extends StatefulWidget {
  final int? barIndex;
  final String currentNoteKey;
  final List<BeatType> currentBeats;
  final List<BeatTypePoly> currentPolyBeats;
  final bool isAddingNewBar;
  final List<RhythmGroup> rhythmGroups;
  final bool isSecondMetronome;
  final MetronomeBlock metronomeBlock;

  const SetRhythmParametersSimple({
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
  State<SetRhythmParametersSimple> createState() => _SetRhythmParametersSimpleState();
}

class _SetRhythmParametersSimpleState extends State<SetRhythmParametersSimple> {
  static final logger = createPrefixLogger('SetRhythmParametersSimpleSimple');

  // late FileSystem fs;
  late FixedExtentScrollController _wheelController;

  int beatCount = 0;
  int polyBeatCount = 0;

  final int minNumberOfBeats = 1;
  final int minNumberOfPolyBeats = 0;

  late String noteKey;
  final List<BeatType> beats = List.empty(growable: true);
  final List<BeatTypePoly> polyBeats = List.empty(growable: true);

  // bool isPlaying = false;
  // bool processingButtonClick = false;

  // late Timer beatDetection;
  // final ActiveBeatsModel activeBeatsModel = ActiveBeatsModel();

  // final Tutorial tutorial = Tutorial();
  // final GlobalKey keyToggleBeats = GlobalKey();

  @override
  void initState() {
    super.initState();

    super.initState();

    final currentIndex = wheelNoteKeys.indexOf(widget.currentNoteKey);
    _wheelController = FixedExtentScrollController(initialItem: currentIndex == -1 ? 0 : currentIndex);

    // fs = context.read<FileSystem>();
    //
    // // we need to use the first metronome, because the first metronome cannot have no beats
    // // so if we edit a beat of the second metronome, we just load the sounds of the second metronome into the first metronome
    // if (widget.isSecondMetronome) {
    //   MetronomeUtils.loadMetro2SoundsIntoMetro1(fs, widget.metronomeBlock);
    // }

    beats.addAll(widget.currentBeats);
    polyBeats.addAll(widget.currentPolyBeats);
    noteKey = widget.currentNoteKey;

    beatCount = beats.length;
    polyBeatCount = polyBeats.length;

    // beatDetection = Timer.periodic(const Duration(milliseconds: MetronomeParams.beatDetectionDurationMillis), (
    //   t,
    // ) async {
    //   if (!mounted) {
    //     t.cancel();
    //     return;
    //   }
    //   if (!isPlaying) return;
    //
    //   var event = await metronomePollBeatEventHappened();
    //   if (event != null) {
    //     onBeatHappened(event);
    //     setState(() {});
    //   }
    // });
    //
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (context.read<ProjectLibrary>().showBeatToggleTip) {
    //     createTutorial();
    //     tutorial.show(context);
    //   }
    // });
  }

  // @override
  // void dispose() {
  //   stopBeat();
  //   beatDetection.cancel();
  //   super.dispose();
  // }

  // @override
  // void deactivate() {
  //   stopBeat();
  //   beatDetection.cancel();
  //   super.deactivate();
  // }

  // void onBeatHappened(BeatHappenedEvent event) {
  //   Timer(Duration(milliseconds: event.millisecondsBeforeStart), () {
  //     setState(() {
  //       activeBeatsModel.setBeatOnOff(true, event.barIndex, event.beatIndex, event.isPoly, event.isSecondary);
  //     });
  //   });
  //
  //   Timer(Duration(milliseconds: event.millisecondsBeforeStart + MetronomeParams.flashDurationInMs), () {
  //     if (!mounted) return;
  //     setState(() {
  //       activeBeatsModel.setBeatOnOff(false, event.barIndex, event.beatIndex, event.isPoly, event.isSecondary);
  //     });
  //   });
  // }

  // void createTutorial() {
  //   // add the targets here
  //   var targets = <CustomTargetFocus>[
  //     CustomTargetFocus(
  //       keyToggleBeats,
  //       context.l10n.metronomeTutorialEditBeats,
  //       alignText: ContentAlign.bottom,
  //       pointingDirection: PointingDirection.up,
  //     ),
  //   ];
  //   tutorial.create(targets.map((e) => e.targetFocus).toList(), () async {
  //     context.read<ProjectLibrary>().showBeatToggleTip = false;
  //     await context.read<ProjectRepository>().saveLibrary(context.read<ProjectLibrary>());
  //   }, context);
  // }

  void onBeatCountChange(int newBeatCount) {
    setState(() {
      beatCount = newBeatCount;

      if (newBeatCount > beats.length) {
        beats.addAll(List.filled(newBeatCount - beats.length, BeatType.Unaccented));
      } else if (newBeatCount < beats.length) {
        beats.removeRange(newBeatCount, beats.length);
      }

      refreshRhythm();
    });
  }

  // void onPolyBeatCountChange(int newPolyBeatCount) {
  //   setState(() {
  //     polyBeatCount = newPolyBeatCount;
  //
  //     if (newPolyBeatCount > polyBeats.length) {
  //       polyBeats.addAll(List.filled(newPolyBeatCount - polyBeats.length, BeatTypePoly.Unaccented));
  //     } else if (newPolyBeatCount < polyBeats.length) {
  //       polyBeats.removeRange(newPolyBeatCount, polyBeats.length);
  //     }
  //
  //     refreshRhythm();
  //   });
  // }

  // void startStopBeatPlayback() async {
  //   if (processingButtonClick) return;
  //   setState(() => processingButtonClick = true);
  //
  //   if (isPlaying) {
  //     await stopBeat();
  //   } else {
  //     await startBeat();
  //   }
  //
  //   await Future.delayed(const Duration(milliseconds: TIOMusicParams.millisecondsPlayPauseDebounce));
  //   setState(() => processingButtonClick = false);
  // }

  // Future<void> startBeat() async {
  //   // set beat in rust
  //   refreshRhythm();
  //
  //   await MetronomeFunctions.stop();
  //   final success = await MetronomeFunctions.start();
  //   if (!success) {
  //     logger.e('Unable to start metronome.');
  //     return;
  //   }
  //   isPlaying = true;
  // }

  // Future<void> stopBeat() async {
  //   await metronomeStop();
  //   isPlaying = false;
  // }

  // BeatType getBeatTypeOnTap(BeatType currentType) {
  //   if (currentType == BeatType.Accented) {
  //     return BeatType.Muted;
  //   } else if (currentType == BeatType.Unaccented) {
  //     return BeatType.Accented;
  //   } else {
  //     return BeatType.Unaccented;
  //   }
  // }

  // BeatTypePoly getBeatTypePolyOnTap(BeatTypePoly currentType) {
  //   if (currentType == BeatTypePoly.Accented) {
  //     return BeatTypePoly.Muted;
  //   } else if (currentType == BeatTypePoly.Unaccented) {
  //     return BeatTypePoly.Accented;
  //   } else {
  //     return BeatTypePoly.Unaccented;
  //   }
  // }

  void refreshRhythm() {
    final bars = getRhythmAsMetroBar([RhythmGroup('', beats, polyBeats, noteKey)]);
    metronomeSetRhythm(bars: bars, bars2: []);
  }

  // void selectIcon(String chosenNoteKey) {
  //   setState(() {
  //     noteKey = chosenNoteKey;
  //     refreshRhythm();
  //   });
  // }

  // Future<void> onConfirm() async {
  //   stopBeat();
  //
  //   if (widget.isAddingNewBar) {
  //     widget.rhythmGroups.add(RhythmGroup(MetronomeParams.getNewKeyID(), beats, polyBeats, noteKey));
  //   } else if (widget.barIndex != null) {
  //     widget.rhythmGroups[widget.barIndex!].beats.clear();
  //     beats.forEach(widget.rhythmGroups[widget.barIndex!].beats.add);
  //
  //     widget.rhythmGroups[widget.barIndex!].polyBeats.clear();
  //     polyBeats.forEach(widget.rhythmGroups[widget.barIndex!].polyBeats.add);
  //
  //     widget.rhythmGroups[widget.barIndex!].noteKey = noteKey;
  //     widget.rhythmGroups[widget.barIndex!].beatLen = NoteHandler.getBeatLength(noteKey);
  //   }
  //
  //   MetronomeUtils.loadSounds(fs, widget.metronomeBlock);
  //
  //   await context.read<ProjectRepository>().saveLibrary(context.read<ProjectLibrary>());
  //   if (!mounted) return;
  //   Navigator.of(context).pop(true);
  // }

  // void reset() {
  //   selectIcon(MetronomeParams.defaultNoteKey);
  //   beatCount = MetronomeParams.defaultBeats.length;
  //   polyBeatCount = MetronomeParams.defaultPolyBeats.length;
  //
  //   for (var i = 0; i < beats.length; i++) {
  //     beats[i] = MetronomeParams.defaultBeats[i];
  //   }
  //
  //   refreshRhythm();
  // }
  //
  // void onCancel() {
  //   stopBeat();
  //   MetronomeUtils.loadSounds(fs, widget.metronomeBlock);
  //   Navigator.pop(context);
  // }

  Widget _buildNoteWheel() {
    return Container(
      height: 100,
      width: 80,
      decoration: BoxDecoration(
        color: ColorTheme.surface,
        border: Border.all(color: ColorTheme.primary80, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ListWheelScrollView.useDelegate(
          controller: _wheelController,
          itemExtent: 52,
          physics: const FixedExtentScrollPhysics(),
          overAndUnderCenterOpacity: 0.5,
          perspective: 0.002,
          onSelectedItemChanged: (index) {
            setState(() {
              noteKey = wheelNoteKeys[index];
              refreshRhythm();
            });
          },
          childDelegate: ListWheelChildBuilderDelegate(
            childCount: wheelNoteKeys.length,
            builder: (context, index) {
              final key = wheelNoteKeys[index];
              final isSelected = noteKey == key;

              return RhythmGeneratorSettingListItem(
                noteKey: key,
                hasBorder: isSelected,
                onTap: () {
                  _wheelController.animateToItem(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                  setState(() {
                    noteKey = key;
                    refreshRhythm();
                  });
                },
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Row(
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

        Expanded(child: SizedBox()),

        _buildNoteWheel(),
      ],
    );
  }
}
