import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/widgets/input/app_slider_double.dart';
import 'package:tiomusic/widgets/input/number_input_double.dart';

class NumberInputDoubleWithSlider extends StatefulWidget {
  final double min;
  final double max;
  final double defaultValue;
  final double step;
  final String label;
  final TextEditingController controller;
  final int? stepIntervalInMs;
  final double? buttonRadius;
  final double? buttonGap;
  final double? textFieldWidth;
  final double? textFontSize;
  final double? relIconSize;
  final bool? allowNegativeNumbers;

  const NumberInputDoubleWithSlider({
    super.key,
    required this.min,
    required this.max,
    required this.defaultValue,
    required this.step,
    required this.label,
    required this.controller,
    this.stepIntervalInMs,
    this.buttonRadius,
    this.buttonGap,
    this.textFieldWidth,
    this.textFontSize,
    this.relIconSize,
    this.allowNegativeNumbers,
  });

  @override
  State<NumberInputDoubleWithSlider> createState() => _NumberInputDoubleWithSliderState();
}

class _NumberInputDoubleWithSliderState extends State<NumberInputDoubleWithSlider> {
  @override
  void initState() {
    super.initState();
    widget.controller.value = widget.controller.value.copyWith(text: widget.defaultValue.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        NumberInputDouble(
          max: widget.max,
          min: widget.min,
          defaultValue: widget.defaultValue,
          step: widget.step,
          controller: widget.controller,
          stepIntervalInMs: widget.stepIntervalInMs,
          label: widget.label,
          buttonRadius: widget.buttonRadius,
          buttonGap: widget.buttonGap,
          textFieldWidth: widget.textFieldWidth,
          textFontSize: widget.textFontSize,
          relIconSize: widget.relIconSize,
          allowNegativeNumbers: widget.allowNegativeNumbers,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 40),
          child: AppSliderDouble(
            semanticLabel: context.l10n.commonSemanticLabelSlider(widget.label),
            min: widget.min,
            max: widget.max,
            defaultValue: widget.defaultValue,
            step: widget.step,
            controller: widget.controller,
          ),
        ),
      ],
    );
  }
}
