import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiomusic/widgets/input/number_input_and_slider_int.dart';

import '../../utils/action_utils.dart';
import '../../utils/render_utils.dart';

extension WidgetTesterPumpExtension on WidgetTester {
  Future<void> unfocusAndSettle() async {
    await testTextInput.receiveAction(TextInputAction.done);
    await pumpAndSettle();
  }
}

class TestWrapper extends StatefulWidget {
  final int value;
  final Function(int) onChange;
  final int min;
  final int max;
  final int step;
  final String label;

  const TestWrapper({
    super.key,
    required this.value,
    required this.onChange,
    this.min = 0,
    this.max = 100,
    this.step = 1,
    this.label = 'Test',
  });

  @override
  State<TestWrapper> createState() => _TestWrapperState();
}

class _TestWrapperState extends State<TestWrapper> {
  late int value;

  @override
  void initState() {
    super.initState();
    value = widget.value;
  }

  void onChange(int newValue) => {setState(() => value = newValue), widget.onChange(newValue)};

  @override
  Widget build(BuildContext context) {
    return NumberInputAndSliderInt(
      value: value,
      onChange: onChange,
      min: widget.min,
      max: widget.max,
      step: widget.step,
      label: widget.label,
    );
  }
}

void main() {
  setUpAll(WidgetsFlutterBinding.ensureInitialized);

  group('number input int and slider', () {
    testWidgets('returns input value when changing value', (tester) async {
      int callbackCalls = 0;
      int mockCallback(int _) => callbackCalls++;

      await tester.renderWidget(TestWrapper(value: 1, onChange: mockCallback));
      expect(callbackCalls, equals(0));

      await tester.tapAndSettle(find.bySemanticsLabel('Plus button'));

      expect(callbackCalls, equals(1));
    });

    testWidgets('change input value to integer when entering new value with decimal', (tester) async {
      await tester.renderWidget(TestWrapper(value: 10, onChange: (_) {}));
      expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '10');

      await tester.enterTextAndSettle(find.bySemanticsLabel('Test input'), '20.5');
      await tester.unfocusAndSettle();

      expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '21');
    });
  });
}
