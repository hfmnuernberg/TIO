import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/rhythm_group.dart';
import 'package:tiomusic/src/rust/api/modules/metronome_rhythm.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/widgets/input/small_number_input_int.dart';
import 'package:tiomusic/widgets/metronome/rhythm_preset.dart';
import 'package:tiomusic/widgets/metronome/rhythm_preset_wheel.dart';

class SetRhythmParametersSimple extends StatelessWidget {
  final RhythmGroup rhythmGroup;

  final void Function(RhythmGroup rhythmGroup) onUpdate;

  const SetRhythmParametersSimple({super.key, required this.rhythmGroup, required this.onUpdate});

  void _handleBeatCountChange(int beatCount) {
    onUpdate(RhythmGroup('', _getBeats(rhythmGroup.beats, beatCount), rhythmGroup.polyBeats, rhythmGroup.noteKey));
  }

  void _handlePresetSelected(RhythmPresetKey key) {
    final preset = RhythmPreset.fromKey(key);
    onUpdate(RhythmGroup('', preset.beats, preset.polyBeats, preset.noteKey));
  }

  static List<BeatType> _getBeats(List<BeatType> beats, int beatCount) {
    if (beatCount < beats.length) {
      return beats.sublist(0, beatCount);
    }
    if (beatCount > beats.length) {
      return List.from(beats)..addAll(List.filled(beatCount - beats.length, BeatType.Unaccented));
    }
    return beats;
  }

  @override
  Widget build(BuildContext context) {
    final presetKey =
        RhythmPreset.fromProperties(
          beats: rhythmGroup.beats,
          polyBeats: rhythmGroup.polyBeats,
          noteKey: rhythmGroup.noteKey,
        ) ??
        RhythmPresetKey.oneFourth;

    return Row(
      children: [
        SmallNumberInputInt(
          value: rhythmGroup.beats.length,
          onChange: _handleBeatCountChange,
          min: 1,
          max: MetronomeParams.maxBeatCount,
          step: 1,
          label: context.l10n.metronomeNumberOfBeats,
          buttonRadius: MetronomeParams.popupButtonRadius,
          textFontSize: MetronomeParams.popupTextFontSize,
        ),

        Expanded(child: SizedBox()),

        RhythmPresetWheel(presetKey: presetKey, onSelect: _handlePresetSelected),
      ],
    );
  }
}
