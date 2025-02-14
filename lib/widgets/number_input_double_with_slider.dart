import 'package:flutter/material.dart';
import 'package:tiomusic/widgets/input/custom_slider_double.dart';
import 'package:tiomusic/widgets/input/number_input_double.dart';

class NumberInputDoubleWithSlider extends StatefulWidget {
  final double min;
  final double max;
  final double defaultValue;
  final double step;
  final TextEditingController controller;
  final int stepIntervalInMs;
  final String descriptionText;
  final double buttonRadius;
  final double buttonGap;
  final double textFieldWidth;
  final double textFontSize;
  final double relIconSize;
  final bool allowNegativeNumbers;

  const NumberInputDoubleWithSlider({
    super.key,
    required this.min,
    required this.max,
    required this.defaultValue,
    required this.step,
    required this.controller,
    this.stepIntervalInMs = 100,
    this.descriptionText = '',
    this.buttonRadius = 25,
    this.buttonGap = 10,
    this.textFieldWidth = 100,
    this.textFontSize = 40,
    this.relIconSize = 0.4,
    this.allowNegativeNumbers = false,
  });

  @override
  State<NumberInputDoubleWithSlider> createState() => _NumberInputDoubleWithSliderState();
}

class _NumberInputDoubleWithSliderState extends State<NumberInputDoubleWithSlider> {
  // Initialize variables
  @override
  void initState() {
    super.initState();
    widget.controller.value = widget.controller.value.copyWith(text: widget.defaultValue.toString());
  }

  // Main build
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
          descriptionText: widget.descriptionText,
          buttonRadius: widget.buttonRadius,
          buttonGap: widget.buttonGap,
          textFieldWidth: widget.textFieldWidth,
          textFontSize: widget.textFontSize,
          relIconSize: widget.relIconSize,
          allowNegativeNumbers: widget.allowNegativeNumbers,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 40),
          child: CustomSliderDouble(
            semanticLabel: '${widget.descriptionText} slider',
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
