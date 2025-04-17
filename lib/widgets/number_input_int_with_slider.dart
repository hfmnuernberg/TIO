import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:flutter/material.dart';
import 'package:tiomusic/widgets/input/number_input_int.dart';
import 'package:tiomusic/widgets/input/old_app_slider_int.dart';

class NumberInputIntWithSlider extends StatefulWidget {
  final int min;
  final int max;
  final int defaultValue;
  final int step;
  final String label;
  final TextEditingController controller;
  final int? stepIntervalInMs;
  final double? buttonRadius;
  final double? buttonGap;
  final double? relIconSize;
  final double? textFieldWidth;
  final double? textFontSize;
  final bool? allowNegativeNumbers;

  const NumberInputIntWithSlider({
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
    this.relIconSize,
    this.textFieldWidth,
    this.textFontSize,
    this.allowNegativeNumbers,
  });

  @override
  State<NumberInputIntWithSlider> createState() => _NumberInputIntWithSliderState();
}

class _NumberInputIntWithSliderState extends State<NumberInputIntWithSlider> {
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
        NumberInputInt(
          value: int.parse(widget.controller.text),
          onChanged: (value) => widget.controller.value = widget.controller.value.copyWith(text: value.toString()),
          max: widget.max,
          min: widget.min,
          defaultValue: widget.defaultValue,
          step: widget.step,
          stepIntervalInMs: widget.stepIntervalInMs,
          label: widget.label,
          buttonRadius: widget.buttonRadius,
          buttonGap: widget.buttonGap,
          relIconSize: widget.relIconSize,
          textFieldWidth: widget.textFieldWidth,
          textFontSize: widget.textFontSize,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 40),
          child: OldAppSliderInt(
            semanticLabel: '${widget.label} ${context.l10n.commonSlider}',
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
