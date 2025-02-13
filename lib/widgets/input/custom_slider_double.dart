import 'package:flutter/material.dart';
import 'package:tiomusic/util/color_constants.dart';

class CustomSliderDouble extends StatefulWidget {
  final double min;
  final double max;
  final double defaultValue;
  final double step;
  final TextEditingController controller;

  const CustomSliderDouble({
    super.key,
    required this.min,
    required this.max,
    required this.defaultValue,
    required this.step,
    required this.controller,
  });

  @override
  State<CustomSliderDouble> createState() => _CustomSliderDoubleState();
}

class _CustomSliderDoubleState extends State<CustomSliderDouble> {
  late int _sliderDivisions;
  late double _sliderValue;

  // Initialize variables
  @override
  void initState() {
    super.initState();
    widget.controller.value = widget.controller.value.copyWith(text: widget.defaultValue.toString());

    _sliderDivisions = (widget.max - widget.min) ~/ widget.step;
    _sliderValue = widget.defaultValue;

    widget.controller.addListener(_onExternalChange);
  }

  // Handle external changes of the displayed text
  void _onExternalChange() {
    _validateInput(widget.controller.value.text);
  }

  void _validateInput(String input) {
    if (input != '' && input != '-' && input != '.' && input != '-.') {
      if (input[0] == '.') {
        input = '0$input';
      } else {
        if (input.substring(0, 1) == '-.') {
          input = '-0${input.substring(1)}';
        }
      }
      // Check for min/max values
      if (double.parse(input) < widget.min) {
        input = widget.min.toString();
      } else {
        if (double.parse(input) > widget.max) {
          input = widget.max.toString();
        }
      }
    } else {
      // Set default value when input is empty
      input = widget.defaultValue.toString();
    }
    widget.controller.value = widget.controller.value.copyWith(text: input);
    _sliderValue = double.parse(input);
    setState(() {});
  }

  // Main build
  @override
  Widget build(BuildContext context) {
    return Slider(
      value: _sliderValue,
      inactiveColor: ColorTheme.primary80,
      min: widget.min,
      max: widget.max,
      divisions: _sliderDivisions,
      label: widget.controller.text,
      onChanged: (newValue) {
        setState(() {
          _sliderValue = double.parse(newValue.toStringAsFixed(1));
          widget.controller.value = widget.controller.value.copyWith(text: _sliderValue.toString());
          _validateInput(widget.controller.text);
        });
      },
    );
  }
}
