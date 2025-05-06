import 'package:flutter/material.dart';
import 'package:tiomusic/widgets/input/small_number_input_dec.dart';

class SmallNumberInputInt extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChange;
  final int? min;
  final int? max;
  final int? step;
  final int? decrementStep;
  final int? incrementStep;
  final int? stepIntervalInMs;
  final String? label;
  final double? buttonRadius;
  final double? buttonGap;
  final double? textFontSize;
  final double? relIconSize;

  const SmallNumberInputInt({
    super.key,
    required this.value,
    required this.onChange,
    this.min = 0,
    this.max = 100,
    this.step,
    this.decrementStep,
    this.incrementStep,
    this.stepIntervalInMs,
    this.label,
    this.buttonRadius,
    this.buttonGap,
    this.textFontSize,
    this.relIconSize,
  });

  @override
  Widget build(BuildContext context) {
    return SmallNumberInputDec(
      value: value.toDouble(),
      onChange: (val) => onChange(val.round()),
      min: min?.toDouble(),
      max: max?.toDouble(),
      step: step?.toDouble(),
      decrementStep: decrementStep?.toDouble(),
      incrementStep: incrementStep?.toDouble(),
      stepIntervalInMs: stepIntervalInMs,
      label: label,
      buttonRadius: buttonRadius,
      buttonGap: buttonGap,
      textFontSize: textFontSize,
      relIconSize: relIconSize,
    );
  }
}
