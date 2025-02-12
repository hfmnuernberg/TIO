import 'package:flutter/material.dart';
import 'package:tiomusic/util/color_constants.dart';

class CustomSlider extends StatefulWidget {
  final int max;
  final int min;
  final int defaultValue;
  final int step;
  final TextEditingController controller;

  const CustomSlider({
    super.key,
    required this.max,
    required this.min,
    required this.defaultValue,
    required this.step,
    required this.controller,
  });

  @override
  State<CustomSlider> createState() => _CustomSliderState();
}

class _CustomSliderState extends State<CustomSlider> {
  late TextEditingController _valueController;
  late int _sliderDivisions;

  late int _sliderValue;

  // Initialize variables
  @override
  void initState() {
    super.initState();
    widget.controller.value = widget.controller.value.copyWith(text: widget.defaultValue.toString());
    _valueController = TextEditingController(text: widget.defaultValue.toString());

    _sliderDivisions = (widget.max - widget.min) ~/ widget.step;
    _sliderValue = widget.defaultValue;
  }

  // Check if submitted input is valid
  void _validateInput(int input) {
    if (input != '' && input != '-') {
      // Check for min/max values
      if (input < widget.min) {
        input = widget.min;
      } else {
        if (input > widget.max) {
          input = widget.max;
        }
      }
    } else {
      // Set default value when input is no number
      input = widget.defaultValue;
    }
    _valueController.value = _valueController.value.copyWith(text: input.toString());
    widget.controller.value = widget.controller.value.copyWith(text: input.toString());
    _sliderValue = input;
    setState(() {});
  }

  // Main build
  @override
  Widget build(BuildContext context) {
    return Slider(
      value: _sliderValue.toDouble(),
      inactiveColor: ColorTheme.primary80,
      min: widget.min.toDouble(),
      max: widget.max.toDouble(),
      divisions: _sliderDivisions,
      label: _valueController.text,
      onChanged: (newValue) {
        _sliderValue = int.parse(newValue.toStringAsFixed(0));
        setState(() {
          _valueController.value = _valueController.value.copyWith(text: _sliderValue.toString());
          _validateInput(int.parse(_valueController.text));
        });
      },
    );
  }
}
