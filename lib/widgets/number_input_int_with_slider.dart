import 'input/custom_slider_int.dart';
import 'input/number_input_int.dart';
import 'package:flutter/material.dart';

class NumberInputIntWithSlider extends StatefulWidget {
  final int max;
  final int min;
  final int defaultValue;
  final int step;
  final TextEditingController controller;
  final int countingIntervalInMs;
  final String descriptionText;
  final double buttonRadius;
  final double buttonGap;
  final double relIconSize;
  final double textFieldWidth;
  final double textFontSize;

  const NumberInputIntWithSlider({
    super.key,
    required this.max,
    required this.min,
    required this.defaultValue,
    required this.step,
    required this.controller,
    this.countingIntervalInMs = 100,
    this.descriptionText = '',
    this.buttonRadius = 25,
    this.buttonGap = 10,
    this.relIconSize = 0.4,
    this.textFieldWidth = 100,
    this.textFontSize = 40,
  });

  @override
  State<NumberInputIntWithSlider> createState() => _NumberInputIntWithSliderState();
}

class _NumberInputIntWithSliderState extends State<NumberInputIntWithSlider> {
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
        NumberInputInt(
          defaultValue: widget.defaultValue,
          max: widget.max,
          min: widget.min,
          step: widget.step,
          controller: widget.controller,
          countingStepsInMilliseconds: widget.countingIntervalInMs,
          descriptionText: widget.descriptionText,
          buttonRadius: widget.buttonRadius,
          buttonGap: widget.buttonGap,
          relIconSize: widget.relIconSize,
          textFieldWidth: widget.textFieldWidth,
          textFontSize: widget.textFontSize,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 40),
          child: CustomSliderInt(
            max: widget.max,
            min: widget.min,
            defaultValue: widget.defaultValue,
            step: widget.step,
            controller: widget.controller,
          ),
        ),
      ],
    );
  }
}
