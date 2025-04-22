import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/widgets/input/number_input_dec.dart';
import 'package:tiomusic/widgets/input/slider_dec.dart';

class NumberInputAndSliderDec extends StatelessWidget {
  final double value;
  final Function(double) onChanged;
  final double? max;
  final double? min;
  final double? defaultValue;
  final int? decimalDigits;
  final double? step;
  final int? stepIntervalInMs;
  final String? label;
  final double? buttonRadius;
  final double? buttonGap;
  final double? textFieldWidth;
  final double? textFontSize;
  final double? relIconSize;

  const NumberInputAndSliderDec({
    super.key,
    required this.value,
    required this.onChanged,
    this.min,
    this.max,
    this.defaultValue,
    this.decimalDigits,
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        NumberInputDec(
          value: value,
          onChanged: onChanged,
          min: min,
          max: max,
          defaultValue: defaultValue,
          decimalDigits: decimalDigits,
          step: step,
          stepIntervalInMs: stepIntervalInMs,
          label: label,
          buttonRadius: buttonRadius,
          buttonGap: buttonGap,
          textFieldWidth: textFieldWidth,
          textFontSize: textFontSize,
          relIconSize: relIconSize,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 40),
          child: SliderDec(
            value: value,
            onChanged: onChanged,
            min: min,
            max: max,
            step: step,
            semanticLabel: '$label ${context.l10n.commonSlider}',
          ),
        ),
      ],
    );
  }
}
