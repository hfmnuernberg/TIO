import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiomusic/widgets/input/number_input_and_slider_dec.dart';

import '../../utils/action_utils.dart';
import '../../utils/render_utils.dart';

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

  Future<void> dragFromCenterToTargetAndSettle(FinderBase<Element> finder, Offset to) async {
    final Offset widgetCenter = getCenter(finder);
    await dragFrom(widgetCenter, to);
    await pumpAndSettle();
  }
}

class _TestWrapper extends StatefulWidget {
  final double value;
  final Function(double)? onChange;
  final double min;
  final double max;
  final double step;

  const _TestWrapper({required this.value, this.onChange, this.min = 0.0, this.max = 100.0, this.step = 1.0});

  @override
  State<_TestWrapper> createState() => _TestWrapperState();
}

class _TestWrapperState extends State<_TestWrapper> {
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
      label: 'Test',
    );
  }
}

void main() {
  setUpAll(WidgetsFlutterBinding.ensureInitialized);

  group('number input dec and slider', () {
    testWidgets('returns input value when changing value', (tester) async {
      double callbackCalls = 0;
      double mockCallback(double _) => callbackCalls++;

      await tester.renderWidget(_TestWrapper(value: 1, onChange: mockCallback));
      expect(callbackCalls, equals(0));

      await tester.tapAndSettle(find.bySemanticsLabel('Plus button'));

      expect(callbackCalls, equals(1));
    });

    group('number input decimal', () {
      testWidgets('increases input value based on given step when tapping plus button', (tester) async {
        await tester.renderWidget(_TestWrapper(value: 10.5, step: 2));
        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '10.5');

        await tester.tapAndSettle(find.bySemanticsLabel('Plus button'));

        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '12.5');
      });

      testWidgets('does not increase input value higher than max when tapping plus button', (tester) async {
        await tester.renderWidget(_TestWrapper(value: 10.5, max: 11, step: 2));

        await tester.tapAndSettle(find.bySemanticsLabel('Plus button'));

        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '11');
      });

      testWidgets('decreases input value based on given step when tapping minus button', (tester) async {
        await tester.renderWidget(_TestWrapper(value: 10.5, step: 2));

        await tester.tapAndSettle(find.bySemanticsLabel('Minus button'));

        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '8.5');
      });

      testWidgets('does not decrease input value lower than min when tapping minus button', (tester) async {
        await tester.renderWidget(_TestWrapper(value: 1.5, min: 1, step: 2));

        await tester.tapAndSettle(find.bySemanticsLabel('Minus button'));

        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '1');
      });

      testWidgets('changes input value when entering new value', (tester) async {
        await tester.renderWidget(_TestWrapper(value: 10));
        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '10');

        await tester.enterTextAndSettle(find.bySemanticsLabel('Test input'), '20.0');

        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '20.0');
      });

      testWidgets('changes input value to max when entering too high value', (tester) async {
        await tester.renderWidget(_TestWrapper(value: 10, max: 20));

        await tester.enterTextAndSettle(find.bySemanticsLabel('Test input'), '30.0');
        await tester.unfocusAndSettle();

        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '20');
      });

      testWidgets('changes input value to max when entering value higher than max twice', (tester) async {
        await tester.renderWidget(_TestWrapper(value: 10, max: 20));

        await tester.enterTextAndSettle(find.bySemanticsLabel('Test input'), '30');
        await tester.unfocusAndSettle();
        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '20');

        await tester.enterTextAndSettle(find.bySemanticsLabel('Test input'), '30');
        await tester.unfocusAndSettle();
        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '20');
      });

      testWidgets('changes input value to min when entering too low value', (tester) async {
        await tester.renderWidget(_TestWrapper(value: 20, min: 10));

        await tester.enterTextAndSettle(find.bySemanticsLabel('Test input'), '1.0');
        await tester.unfocusAndSettle();

        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '10');
      });

      testWidgets('does not change input value when entering invalid value', (tester) async {
        await tester.renderWidget(_TestWrapper(value: 10));

        await tester.enterTextAndSettle(find.bySemanticsLabel('Test input'), 'test');
        await tester.unfocusAndSettle();

        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '10');
      });

      testWidgets('does not change input value when entering new empty value', (tester) async {
        await tester.renderWidget(_TestWrapper(value: 10));

        await tester.enterTextAndSettle(find.bySemanticsLabel('Test input'), '');
        await tester.unfocusAndSettle();

        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '10');
      });

      testWidgets('increases input value when tapping plus button during editing input value', (tester) async {
        await tester.renderWidget(_TestWrapper(value: 10));

        await tester.enterText(find.bySemanticsLabel('Test input'), '20');
        await tester.tapAndSettle(find.bySemanticsLabel('Plus button'));

        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '21');
      });

      testWidgets('increases old input value when tapping plus button during input value is empty', (tester) async {
        await tester.renderWidget(_TestWrapper(value: 10));

        await tester.enterText(find.bySemanticsLabel('Test input'), '');
        await tester.tapAndSettle(find.bySemanticsLabel('Plus button'));

        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '11');
      });
    });
  });

  group('slider decimal', () {
    testWidgets('increases input value when moving slider to right', (tester) async {
      await tester.renderWidget(_TestWrapper(value: 10));
      expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '10');

      final Finder slider = find.bySemanticsLabel('Test slider');
      await tester.dragFromCenterToTargetAndSettle(slider, const Offset(10, 0));

      expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '51');
    });

    testWidgets('decreases input value when moving slider to left', (tester) async {
      await tester.renderWidget(_TestWrapper(value: 10));

      final Finder slider = find.bySemanticsLabel('Test slider');
      await tester.dragFromCenterToTargetAndSettle(slider, const Offset(-10, 0));

      expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '49');
    });

    testWidgets('increases input value to max when moving slider far to right', (tester) async {
      await tester.renderWidget(_TestWrapper(value: 10, max: 50));

      final Finder slider = find.bySemanticsLabel('Test slider');
      await tester.dragFromCenterToTargetAndSettle(slider, const Offset(500, 0));

      expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '50');
    });

    testWidgets('decreases input value to min when moving slider far to left', (tester) async {
      await tester.renderWidget(_TestWrapper(value: 10, min: 1));

      final Finder slider = find.bySemanticsLabel('Test slider');
      await tester.dragFromCenterToTargetAndSettle(slider, const Offset(-500, 0));

      expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '1');
    });

    testWidgets('changes input value to slider value when tapping on slider', (tester) async {
      await tester.renderWidget(_TestWrapper(value: 10, max: 50));
      expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '10');

      await tester.tapAtCenterAndSettle(find.bySemanticsLabel('Test slider'));

      expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '25');
    });

    testWidgets('changes slider value to input value when changing input value', (tester) async {
      await tester.renderWidget(_TestWrapper(value: 10));
      expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '10');

      await tester.tapAndSettle(find.bySemanticsLabel('Plus button'));

      expect(tester.getSemantics(find.bySemanticsLabel('Test slider')).value, '11');
    });
  });
}
