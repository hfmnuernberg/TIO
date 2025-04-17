import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/util/color_constants.dart';

class SliderDec extends StatelessWidget {
  final double value;
  final Function(double) onChanged;
  final double min;
  final double max;
  final double step;
  final String semanticLabel;

  const SliderDec({
    super.key,
    required this.value,
    required this.onChanged,
    double? min,
    double? max,
    double? step,
    String? semanticLabel,
  }) : min = min ?? double.negativeInfinity,
       max = max ?? double.infinity,
       step = step ?? 1,
       semanticLabel = semanticLabel ?? '';

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      value: context.l10n.formatNumber(value),
      child: Slider(
        value: value,
        inactiveColor: ColorTheme.primary80,
        min: min,
        max: max,
        divisions: (max - min) ~/ step,
        label: context.l10n.formatNumber(value),
        onChanged: onChanged,
      ),
    );
  }
}
