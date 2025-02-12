import 'package:flutter/material.dart';
import 'package:tiomusic/widgets/input/custom_slider_double.dart';
import 'package:tiomusic/widgets/input/number_input_for_double.dart';

class NumberInputDouble extends StatefulWidget {
  final double max;
  final double min;
  final double defaultValue;
  final double step;
  final TextEditingController controller;
  final int countingIntervalMs;
  final String descriptionText;
  final double buttonRadius;
  final double buttonGap;
  final double textFieldWidth;
  final double textFontSize;
  final double relIconSize;
  final bool allowNegativeNumbers;

  const NumberInputDouble({
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
    this.textFieldWidth = 100,
    this.textFontSize = 40,
    this.relIconSize = 0.4,
    this.allowNegativeNumbers = false,
  });

  @override
  State<NumberInputDouble> createState() => _NumberInputDoubleState();
}

class _NumberInputDoubleState extends State<NumberInputDouble> {
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
        NumberInputForDouble(
          max: widget.max,
          min: widget.min,
          defaultValue: widget.defaultValue,
          step: widget.step,
          controller: widget.controller,
          countingIntervalMs: widget.countingIntervalMs,
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
