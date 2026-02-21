import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiomusic/widgets/input/number_input_and_slider_dec.dart';

extension WidgetTesterPumpExtension on WidgetTester {
  Future<void> tapAtCenterAndSettle(FinderBase<Element> finder) async {
    final Offset widgetCenter = getCenter(finder);
    await tapAt(widgetCenter);
    await pumpAndSettle();
  }

  Future<void> unfocusAndSettle() async {
    await testTextInput.receiveAction(TextInputAction.done);
    await pumpAndSettle();
  }
}

class TestWrapper extends StatefulWidget {
  final double value;
  final Function(double)? onChange;
  final double min;
  final double max;
  final double step;
  final String label;

  const TestWrapper({
    super.key,
    required this.value,
    this.onChange,
    this.min = 0.0,
    this.max = 100.0,
    this.step = 1.0,
    this.label = 'Test',
  });

  @override
  State<TestWrapper> createState() => _TestWrapperState();
}

class _TestWrapperState extends State<TestWrapper> {
  late double value;

  @override
  void initState() {
    super.initState();
    value = widget.value;
  }

  void onChange(double newValue) {
    setState(() => value = newValue);
    widget.onChange?.call(newValue);
  }

  @override
  Widget build(BuildContext context) {
    return NumberInputAndSliderDec(
      value: value,
      onChange: onChange,
      min: widget.min,
      max: widget.max,
      step: widget.step,
      label: widget.label,
    );
  }
}
