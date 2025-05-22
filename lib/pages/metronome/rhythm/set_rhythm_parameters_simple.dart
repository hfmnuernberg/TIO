// Setting page for rhythm segments
// Called when a new rhythm segment is initialized and when an existing one is tapped

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/metronome_block.dart';
import 'package:tiomusic/models/note_handler.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/models/rhythm_group.dart';
import 'package:tiomusic/pages/metronome/rhythm/rhythm_generator_setting_list_item.dart';
import 'package:tiomusic/services/file_system.dart';
import 'package:tiomusic/services/project_repository.dart';
import 'package:tiomusic/src/rust/api/api.dart';
import 'package:tiomusic/src/rust/api/modules/metronome_rhythm.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/util/util_functions.dart';
import 'package:tiomusic/widgets/input/small_number_input_int.dart';
import 'package:tiomusic/widgets/rhythm_preset.dart';

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
  final List<RhythmGroup> rhythmGroups;
  final MetronomeBlock metronomeBlock;
  final void Function(List<BeatType> beats, List<BeatTypePoly> polyBeats, String noteKey) onUpdateRhythm;

  const SetRhythmParametersSimple({
    super.key,
    this.barIndex,
    required this.currentNoteKey,
    required this.currentBeats,
    required this.currentPolyBeats,
    required this.rhythmGroups,
    required this.metronomeBlock,
    required this.onUpdateRhythm,
  });

  @override
  State<SetRhythmParametersSimple> createState() => _SetRhythmParametersSimpleState();
}

class _SetRhythmParametersSimpleState extends State<SetRhythmParametersSimple> {
  late FileSystem fs;
  late FixedExtentScrollController _wheelController;

  late int beatCount = 0;
  final int minNumberOfBeats = 1;

  late String noteKey;
  final List<BeatType> beats = List.empty(growable: true);
  final List<BeatTypePoly> polyBeats = List.empty(growable: true);

  @override
  void initState() {
    super.initState();

    final currentIndex = wheelNoteKeys.indexOf(widget.currentNoteKey);
    _wheelController = FixedExtentScrollController(initialItem: currentIndex == -1 ? 0 : currentIndex);

    fs = context.read<FileSystem>();

    beats.addAll(widget.currentBeats);
    polyBeats.addAll(widget.currentPolyBeats);
    noteKey = widget.currentNoteKey;

    beatCount = beats.length;
  }

  void notifyParent() {
    widget.onUpdateRhythm(List.from(beats), List.from(polyBeats), noteKey);
  }

  @override
  void dispose() {
    _wheelController.dispose();
    super.dispose();
  }

  Future<void> onBeatCountChange(int newBeatCount) async {
    setState(() {
      beatCount = newBeatCount;

      if (newBeatCount > beats.length) {
        beats.addAll(List.filled(newBeatCount - beats.length, BeatType.Unaccented));
      } else if (newBeatCount < beats.length) {
        beats.removeRange(newBeatCount, beats.length);
      }

      refreshRhythm();
    });

    if (widget.barIndex != null) {
      final group = widget.rhythmGroups[widget.barIndex!];
      group.beats
        ..clear()
        ..addAll(beats);
      group.polyBeats
        ..clear()
        ..addAll(polyBeats);
      group.noteKey = noteKey;
      group.beatLen = NoteHandler.getBeatLength(noteKey);
    }

    notifyParent();

    await context.read<ProjectRepository>().saveLibrary(context.read<ProjectLibrary>());
  }

  void refreshRhythm() {
    final bars = getRhythmAsMetroBar([RhythmGroup('', beats, polyBeats, noteKey)]);
    metronomeSetRhythm(bars: bars, bars2: []);
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

        Container(
          height: 80,
          width: 160,
          decoration: BoxDecoration(
            color: ColorTheme.surface,
            border: Border.all(color: ColorTheme.primary80),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: RotatedBox(
              quarterTurns: -1,
              child: ListWheelScrollView.useDelegate(
                controller: _wheelController,
                itemExtent: 48,
                perspective: 0.008,
                physics: const FixedExtentScrollPhysics(),
                overAndUnderCenterOpacity: 0.6,
                onSelectedItemChanged: (index) {
                  final selectedKey = wheelNoteKeys[index];
                  final preset = getPresetRhythmPattern(selectedKey);

                  setState(() {
                    beats
                      ..clear()
                      ..addAll(preset.beats);
                    polyBeats
                      ..clear()
                      ..addAll(preset.polyBeats);
                    noteKey = preset.noteKey;
                    beatCount = preset.beats.length;
                    refreshRhythm();
                  });

                  notifyParent();
                },
                childDelegate: ListWheelChildBuilderDelegate(
                  childCount: wheelNoteKeys.length,
                  builder: (context, index) {
                    final key = wheelNoteKeys[index];

                    return RotatedBox(
                      quarterTurns: 1,
                      child: RhythmGeneratorSettingListItem(
                        noteKey: key,
                        onTap: () {
                          _wheelController.animateToItem(
                            index,
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                          final preset = getPresetRhythmPattern(key);

                          setState(() {
                            beats
                              ..clear()
                              ..addAll(preset.beats);
                            polyBeats
                              ..clear()
                              ..addAll(preset.polyBeats);
                            noteKey = preset.noteKey;
                            beatCount = preset.beats.length;
                            refreshRhythm();
                          });

                          notifyParent();
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
