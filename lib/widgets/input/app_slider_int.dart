import 'package:flutter/material.dart';
import 'package:tiomusic/util/color_constants.dart';

class AppSliderInt extends StatefulWidget {
  final int min;
  final int max;
  final int defaultValue;
  final int step;
  final TextEditingController controller;
  final String? semanticLabel;

  const AppSliderInt({
    super.key,
    required this.min,
    required this.max,
    required this.defaultValue,
    required this.step,
    required this.controller,
    this.semanticLabel,
  });

  @override
  State<AppSliderInt> createState() => _AppSliderIntState();
}

class _AppSliderIntState extends State<AppSliderInt> {
  late int _sliderDivisions;
  late int _sliderValue;

  @override
  void initState() {
    super.initState();
    widget.controller.value = widget.controller.value.copyWith(text: widget.defaultValue.toString());

    _sliderDivisions = (widget.max - widget.min) ~/ widget.step;
    _sliderValue = widget.defaultValue;

    widget.controller.addListener(_onExternalChange);
  }

  void _onExternalChange() {
    _validateInput(int.parse(widget.controller.value.text));
  }

  void _validateInput(int input) {
    if (input < widget.min) {
      input = widget.min;
    } else if (input > widget.max) {
      input = widget.max;
    }
    widget.controller.value = widget.controller.value.copyWith(text: input.toString());
    _sliderValue = input;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.semanticLabel,
      value: widget.controller.text,
      child: Slider(
        value: _sliderValue.toDouble(),
        inactiveColor: ColorTheme.primary80,
        min: widget.min.toDouble(),
        max: widget.max.toDouble(),
        divisions: _sliderDivisions,
        label: widget.controller.text,
        onChanged: (newValue) {
          setState(() {
            _sliderValue = int.parse(newValue.toStringAsFixed(0));
            widget.controller.value = widget.controller.value.copyWith(text: _sliderValue.toString());
            _validateInput(int.parse(widget.controller.text));
          });
        },
      ),
    );
  }
}
