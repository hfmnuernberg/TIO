import 'package:flutter/material.dart';
import 'package:tiomusic/widgets/input/number_input_and_slider_int.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'NumberInputAndSliderInt', type: NumberInputAndSliderInt)
Widget numberInputAndSliderInt(BuildContext context) {
  return NumberInputAndSliderInt(
    min: 0,
    max: 100,
    step: 1,
    value: context.knobs.int.input(label: 'value', initialValue: 1),
    onChange: (value) => debugPrint('⌨️ onChange - value: $value'),
  );
}
