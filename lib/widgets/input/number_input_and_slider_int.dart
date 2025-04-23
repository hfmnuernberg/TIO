import 'package:flutter/material.dart';
import 'package:tiomusic/widgets/input/number_input_and_slider_dec.dart';

class NumberInputAndSliderInt extends StatelessWidget {
  final int value;
  final Function(int) onChanged;
  final int? min;
  final int? max;
  final int? step;
  final int? stepIntervalInMs;
  final String? label;
  final double? buttonRadius;
  final double? buttonGap;
  final double? textFieldWidth;
  final double? textFontSize;
  final double? relIconSize;

  const NumberInputAndSliderInt({
    super.key,
    required this.value,
    required this.onChanged,
    this.min,
    this.max,
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
    return NumberInputAndSliderDec(
      value: value.toDouble(),
      onChanged: (val) => onChanged(val.round()),
      min: min?.toDouble(),
      max: max?.toDouble(),
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
