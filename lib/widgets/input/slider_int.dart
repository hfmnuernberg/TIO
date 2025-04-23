import 'package:flutter/material.dart';
import 'package:tiomusic/widgets/input/slider_dec.dart';

class SliderInt extends StatelessWidget {
  final int value;
  final Function(int) onChange;
  final int? min;
  final int? max;
  final int? step;
  final String? semanticLabel;

  const SliderInt({
    super.key,
    required this.value,
    required this.onChange,
    this.min = 0,
    this.max = 100,
    this.step,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return SliderDec(
      value: value.toDouble(),
      min: min?.toDouble(),
      max: max?.toDouble(),
      step: step?.toDouble(),
      semanticLabel: semanticLabel,
      onChange: (val) => onChange(val.round()),
    );
  }
}
