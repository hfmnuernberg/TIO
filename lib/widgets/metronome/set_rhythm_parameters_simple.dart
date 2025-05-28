import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/metronome_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/models/rhythm_group.dart';
import 'package:tiomusic/services/file_system.dart';
import 'package:tiomusic/services/project_repository.dart';
import 'package:tiomusic/src/rust/api/api.dart';
import 'package:tiomusic/src/rust/api/modules/metronome_rhythm.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/util/util_functions.dart';
import 'package:tiomusic/widgets/input/small_number_input_int.dart';
import 'package:tiomusic/widgets/metronome/rhythm_preset.dart';

const List<RhythmPresetKey> wheelNoteKeys = RhythmPresetKey.values;

Widget getNoteIconWidget(RhythmPresetKey key) {
  return SvgPicture.asset(
    'assets/metronome_presets/${key.assetName}.svg',
    height: 50,
    colorFilter: const ColorFilter.mode(ColorTheme.surfaceTint, BlendMode.srcIn),
  );
}

class SetRhythmParametersSimple extends StatefulWidget {
  final String currentNoteKey;
  final List<BeatType> currentBeats;
  final List<BeatTypePoly> currentPolyBeats;
  final List<RhythmGroup> rhythmGroups;
  final MetronomeBlock metronomeBlock;
  final void Function(List<BeatType> beats, List<BeatTypePoly> polyBeats, String noteKey, RhythmPresetKey? presetKey)
  onUpdateRhythm;

  final bool forcePresetFallback;

  const SetRhythmParametersSimple({
    super.key,
    required this.currentNoteKey,
    required this.currentBeats,
    required this.currentPolyBeats,
    required this.rhythmGroups,
    required this.metronomeBlock,
    required this.onUpdateRhythm,
    this.forcePresetFallback = false,
  });

  @override
  State<SetRhythmParametersSimple> createState() => _SetRhythmParametersSimpleState();
}

class _SetRhythmParametersSimpleState extends State<SetRhythmParametersSimple> {
  late FileSystem fs;
  late FixedExtentScrollController _wheelController;

  late int beatCount = 0;
  final int minNumberOfBeats = 1;

  final List<BeatType> beats = List.empty(growable: true);
  final List<BeatTypePoly> polyBeats = List.empty(growable: true);
  late String noteKey;
  RhythmPresetKey? presetKey;

  @override
  void initState() {
    super.initState();
    fs = context.read<FileSystem>();

    beats.addAll(widget.currentBeats);
    polyBeats.addAll(widget.currentPolyBeats);
    noteKey = widget.currentNoteKey;

    onResetRhythmWhenNotMatchingPreset();

    final currentIndex = wheelNoteKeys.indexOf(presetKey!);
    _wheelController = FixedExtentScrollController(initialItem: currentIndex == -1 ? 0 : currentIndex);
  }

  @override
  void dispose() {
    _wheelController.dispose();
    super.dispose();
  }

  void notifyParent() => widget.onUpdateRhythm(List.from(beats), List.from(polyBeats), noteKey, presetKey);

  void onResetRhythmWhenNotMatchingPreset() {
    final matchingKey = findMatchingPresetKey();

    if (matchingKey != null) {
      presetKey = matchingKey;
      beatCount = beats.length;
    } else if (widget.forcePresetFallback) {
      applyPreset(wheelNoteKeys.first);
    } else {
      presetKey = wheelNoteKeys.first;
      beatCount = beats.length;
    }
  }

  RhythmPresetKey? findMatchingPresetKey() {
    for (final key in wheelNoteKeys) {
      if (getPresetRhythmPattern(key) == RhythmPreset(beats: beats, polyBeats: polyBeats, noteKey: noteKey)) {
        return key;
      }
    }
    return null;
  }

  void applyPreset(RhythmPresetKey key) {
    final preset = getPresetRhythmPattern(key);

    beats
      ..clear()
      ..addAll(preset.beats);
    polyBeats
      ..clear()
      ..addAll(preset.polyBeats);
    noteKey = preset.noteKey;
    beatCount = preset.beats.length;
    presetKey = key;

    refreshRhythm();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyParent();
    });
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

        Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 12),
              child: Container(
                height: 78,
                width: 160,
                decoration: BoxDecoration(color: ColorTheme.surface, borderRadius: BorderRadius.circular(16)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: RotatedBox(
                    quarterTurns: -1,
                    child: ListWheelScrollView.useDelegate(
                      controller: _wheelController,
                      itemExtent: 70,
                      perspective: 0.008,
                      physics: const FixedExtentScrollPhysics(),
                      overAndUnderCenterOpacity: 0.6,
                      onSelectedItemChanged: (index) {
                        final newPresetKey = wheelNoteKeys[index];
                        final preset = getPresetRhythmPattern(newPresetKey);

                        setState(() {
                          beats
                            ..clear()
                            ..addAll(preset.beats);
                          polyBeats
                            ..clear()
                            ..addAll(preset.polyBeats);
                          noteKey = preset.noteKey;
                          presetKey = newPresetKey;
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
                            child: GestureDetector(
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
                                  presetKey = key;
                                  beatCount = preset.beats.length;
                                  refreshRhythm();
                                });

                                notifyParent();
                              },
                              child: getNoteIconWidget(key),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(l10n.metronomeSubdivision, style: const TextStyle(color: ColorTheme.primary)),
            ),
          ],
        ),
      ],
    );
  }
}
