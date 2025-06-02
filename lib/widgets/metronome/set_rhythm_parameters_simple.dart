import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/src/rust/api/modules/metronome_rhythm.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/widgets/input/small_number_input_int.dart';
import 'package:tiomusic/widgets/metronome/rhythm_preset.dart';
import 'package:tiomusic/widgets/metronome/rhythm_preset_wheel.dart';

class SetRhythmParametersSimple extends StatelessWidget {
  final List<BeatType> beats;
  final List<BeatTypePoly> polyBeats;
  final String noteKey;

  final void Function(List<BeatType> beats, List<BeatTypePoly> polyBeats, String noteKey) onUpdateRhythm;

  const SetRhythmParametersSimple({
    super.key,
    required this.beats,
    required this.polyBeats,
    required this.noteKey,
    required this.onUpdateRhythm,
  });

  void _handleBeatCountChange(int beatCount) {
    onUpdateRhythm(_getBeats(beats, beatCount), polyBeats, noteKey);
  }

  void _handlePresetSelected(RhythmPresetKey key) {
    final preset = RhythmPreset.fromKey(key);
    onUpdateRhythm(preset.beats, preset.polyBeats, preset.noteKey);
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
        RhythmPreset.fromProperties(beats: beats, polyBeats: polyBeats, noteKey: noteKey) ?? RhythmPresetKey.oneFourth;

    return Row(
      children: [
        SmallNumberInputInt(
          value: beats.length,
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
