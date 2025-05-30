import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/metronome_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/models/rhythm_group.dart';
import 'package:tiomusic/services/project_repository.dart';
import 'package:tiomusic/src/rust/api/api.dart';
import 'package:tiomusic/src/rust/api/modules/metronome_rhythm.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/util/util_functions.dart';
import 'package:tiomusic/widgets/input/small_number_input_int.dart';
import 'package:tiomusic/widgets/metronome/rhythm_preset.dart';
import 'package:tiomusic/widgets/metronome/rhythm_preset_wheel.dart';
import 'package:tiomusic/widgets/metronome/rhythm_utils.dart';

class SetRhythmParametersSimple extends StatefulWidget {
  final String currentNoteKey;
  final List<BeatType> currentBeats;
  final List<BeatTypePoly> currentPolyBeats;
  final List<RhythmGroup> rhythmGroups;
  final MetronomeBlock metronomeBlock;
  final void Function(List<BeatType> beats, List<BeatTypePoly> polyBeats, String noteKey) onUpdateRhythm;

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
  late int beatCount = 0;
  final int minNumberOfBeats = 1;

  final List<BeatType> beats = List.empty(growable: true);
  final List<BeatTypePoly> polyBeats = List.empty(growable: true);
  late String noteKey;
  late RhythmPresetKey presetKey;

  @override
  void initState() {
    super.initState();

    beats.addAll(widget.currentBeats);
    polyBeats.addAll(widget.currentPolyBeats);
    noteKey = widget.currentNoteKey;

    handleResetRhythmWhenNotMatchingPreset();
  }

  void notifyParent() => widget.onUpdateRhythm(List.from(beats), List.from(polyBeats), noteKey);

  void refreshRhythm() {
    final bars = getRhythmAsMetroBar([RhythmGroup('', beats, polyBeats, noteKey)]);
    metronomeSetRhythm(bars: bars, bars2: []);
  }

  Future<void> handleBeatCountChange(int newBeatCount) async {
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

  void handlePresetSelected(RhythmPresetKey key) {
    final preset = RhythmPreset.fromKey(key);

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
  }

  void handleResetRhythmWhenNotMatchingPreset() {
    final matchingKey = findMatchingPresetKey(beats: beats, polyBeats: polyBeats, noteKey: noteKey);

    if (matchingKey != null) {
      presetKey = matchingKey;
      beatCount = beats.length;
    } else if (widget.forcePresetFallback) {
      applyPreset(RhythmPresetKey.values.first);
    } else {
      presetKey = RhythmPresetKey.values.first;
      beatCount = beats.length;
    }
  }

  void applyPreset(RhythmPresetKey key) {
    final preset = RhythmPreset.fromKey(key);

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

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SmallNumberInputInt(
          value: beatCount,
          onChange: handleBeatCountChange,
          min: minNumberOfBeats,
          max: MetronomeParams.maxBeatCount,
          step: 1,
          label: context.l10n.metronomeNumberOfBeats,
          buttonRadius: MetronomeParams.popupButtonRadius,
          textFontSize: MetronomeParams.popupTextFontSize,
        ),

        Expanded(child: SizedBox()),

        RhythmPresetWheel(presetKey: presetKey, onSelect: handlePresetSelected),
      ],
    );
  }
}
