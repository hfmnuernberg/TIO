import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/rhythm.dart';
import 'package:tiomusic/models/rhythm_group.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/widgets/input/small_number_input_int.dart';
import 'package:tiomusic/widgets/metronome/rhythm_wheel.dart';

class SimpleRhythmGroupSelect extends StatelessWidget {
  final RhythmGroup rhythmGroup;

  final void Function(RhythmGroup rhythmGroup) onUpdate;

  int get beatCount => rhythmGroup.beats.length;
  Rhythm get rhythm => rhythmGroup.rhythm ?? Rhythm.quarter;

  const SimpleRhythmGroupSelect({super.key, required this.rhythmGroup, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SmallNumberInputInt(
          value: rhythmGroup.beats.length,
          onChange: (beatCount) => onUpdate(RhythmGroup.fromRhythm(rhythm, beatCount)),
          min: 1,
          max: MetronomeParams.maxBeatCount,
          step: 1,
          label: context.l10n.metronomeNumberOfBeats,
          buttonRadius: MetronomeParams.popupButtonRadius,
          textFontSize: MetronomeParams.popupTextFontSize,
        ),

        Expanded(child: SizedBox()),

        RhythmWheel(rhythm: rhythm, onSelect: (rhythm) => onUpdate(RhythmGroup.fromRhythm(rhythm, beatCount))),
      ],
    );
  }
}
