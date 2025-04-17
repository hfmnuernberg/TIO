import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:flutter/material.dart';
import 'package:tiomusic/widgets/input/number_input_int.dart';
import 'package:tiomusic/widgets/input/slider_int.dart';

class NumberInputAndSliderInt extends StatelessWidget {
  final int value;
  final Function(int) onChanged;
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

  const NumberInputAndSliderInt({
    super.key,
    required this.value,
    required this.onChanged,
    this.min,
    this.max,
    this.defaultValue,
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
        NumberInputInt(
          value: value,
          onChanged: onChanged,
          max: max,
          min: min,
          defaultValue: defaultValue,
          step: step,
          stepIntervalInMs: stepIntervalInMs,
          label: label,
          buttonRadius: buttonRadius,
          buttonGap: buttonGap,
          relIconSize: relIconSize,
          textFieldWidth: textFieldWidth,
          textFontSize: textFontSize,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 40),
          child: SliderInt(
            value: value,
            onChanged: onChanged,
            max: max,
            min: min,
            step: step,
            semanticLabel: '$label ${context.l10n.commonSlider}',
          ),
        ),
      ],
    );
  }
}
