import 'input/customSlider.dart';
import 'input/number_input.dart';
import 'package:flutter/material.dart';
import 'package:tiomusic/util/color_constants.dart';

class NumberInputInt extends StatefulWidget {
  final int max;
  final int min;
  final int defaultValue;
  final int step;
  final TextEditingController controller;
  final int countingIntervalMs;
  final String descriptionText;
  final double buttonRadius;
  final double buttonGap;
  final double relIconSize;
  final double textFieldWidth;
  final double textFontSize;

  const NumberInputInt({
    super.key,
    required this.max,
    required this.min,
    required this.defaultValue,
    required this.step,
    required this.controller,
    this.countingIntervalMs = 100,
    this.descriptionText = '',
    this.buttonRadius = 25,
    this.buttonGap = 10,
    this.relIconSize = 0.4,
    this.textFieldWidth = 100,
    this.textFontSize = 40,
  });

  @override
  State<NumberInputInt> createState() => _NumberInputIntState();
}

class _NumberInputIntState extends State<NumberInputInt> {
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
        NumberInput(
          defaultValue: widget.defaultValue,
          max: widget.max,
          min: widget.min,
          step: widget.step,
          controller: widget.controller,
          countingStepsInMilliseconds: widget.countingIntervalMs,
          descriptionText: widget.descriptionText,
          buttonRadius: widget.buttonRadius,
          buttonGap: widget.buttonGap,
          relIconSize: widget.relIconSize,
          textFieldWidth: widget.textFieldWidth,
          textFontSize: widget.textFontSize,
        ),
        Text(widget.descriptionText, style: const TextStyle(color: ColorTheme.primary)),
        Padding(
          padding: const EdgeInsets.only(top: 40),
          child: CustomSlider(
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
