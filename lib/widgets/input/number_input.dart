import 'package:flutter/material.dart';
import 'package:tiomusic/widgets/input/number_input_dec.dart';

class NumberInput extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final int? min;
  final int? max;
  final int? defaultValue;
  final int? step;
  final int? stepIntervalInMs;
  final String? label;
  final double? buttonRadius;
  final double? buttonGap;
  final double? textFieldWidth;
  final double? textFontSize;
  final double? relIconSize;

  const NumberInput({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 100,
    this.defaultValue = 1,
    this.step,
    this.stepIntervalInMs,
    this.label,
    this.buttonRadius,
    this.buttonGap,
    this.textFieldWidth,
    this.textFontSize,
    this.relIconSize,
  });

  @override
  Widget build(BuildContext context) {
    return NumberInputDec(
      value: value.toDouble(),
      onChanged: (val) => onChanged(val.toInt()),
      min: min?.toDouble(),
      max: max?.toDouble(),
      defaultValue: defaultValue?.toDouble(),
      step: step?.toDouble(),
      stepIntervalInMs: stepIntervalInMs,
      label: label,
      buttonRadius: buttonRadius,
      buttonGap: buttonGap,
      textFieldWidth: textFieldWidth,
      textFontSize: textFontSize,
      relIconSize: relIconSize,
    );
  }
}
