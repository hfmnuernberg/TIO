import '../../utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiomusic/widgets/number_input_double_with_slider.dart';

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

class TestWrapper extends StatelessWidget {
  final double defaultValue;
  final double min;
  final double max;
  final double step;
  final bool allowNegativeNumbers;

  const TestWrapper({
    super.key,
    this.defaultValue = 50.0,
    this.min = 0.0,
    this.max = 100.0,
    this.step = 1.0,
    this.allowNegativeNumbers = false,
  });

  @override
  Widget build(BuildContext context) {
    return NumberInputDoubleWithSlider(
      min: min,
      max: max,
      defaultValue: defaultValue,
      step: step,
      label: 'Test',
      controller: TextEditingController(),
      allowNegativeNumbers: allowNegativeNumbers,
    );
  }
}

void main() {
  setUpAll(() {
    WidgetsFlutterBinding.ensureInitialized();
  });

  group('number input double with slider', () {
    group('number input double', () {
      testWidgets('increases input value when tapping plus button', (WidgetTester tester) async {
        await tester.renderWidget(TestWrapper(defaultValue: 10.0));
        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '10.0');

        await tester.tapAndSettle(find.bySemanticsLabel('Plus button'));

        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '11.0');
      });

      testWidgets('does not increase input value higher than max when tapping plus button', (
        WidgetTester tester,
      ) async {
        await tester.renderWidget(TestWrapper(defaultValue: 10.0, max: 10.0));
        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '10.0');

        await tester.tapAndSettle(find.bySemanticsLabel('Plus button'));

        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '10.0');
      });

      testWidgets('increases input value based on given step when tapping plus button', (WidgetTester tester) async {
        await tester.renderWidget(TestWrapper(defaultValue: 10.0, step: 0.1));
        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '10.0');

        await tester.tapAndSettle(find.bySemanticsLabel('Plus button'));

        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '10.1');
      });

      testWidgets('decreases input value when tapping minus button', (WidgetTester tester) async {
        await tester.renderWidget(TestWrapper(defaultValue: 10.0));
        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '10.0');

        await tester.tapAndSettle(find.bySemanticsLabel('Minus button'));

        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '9.0');
      });

      testWidgets('does not decrease input value lower than min when tapping minus button', (
        WidgetTester tester,
      ) async {
        await tester.renderWidget(TestWrapper(defaultValue: 0.0, min: 0.0));
        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '0.0');

        await tester.tapAndSettle(find.bySemanticsLabel('Minus button'));

        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '0.0');
      });

      testWidgets('decreases input value based on given step when tapping minus button', (WidgetTester tester) async {
        await tester.renderWidget(TestWrapper(defaultValue: 10.0, step: 0.1));
        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '10.0');

        await tester.tapAndSettle(find.bySemanticsLabel('Minus button'));

        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '9.9');
      });

      testWidgets('changes input value when entering new value in text field', (WidgetTester tester) async {
        await tester.renderWidget(TestWrapper(defaultValue: 10.0));
        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '10.0');

        await tester.enterTextAndSettle(find.bySemanticsLabel('Test input'), '20.0');

        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '20.0');
      });

      testWidgets('changes input value to max when entering too high value in text field', (WidgetTester tester) async {
        await tester.renderWidget(TestWrapper(defaultValue: 10.0, max: 20.0));
        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '10.0');

        await tester.enterTextAndSettle(find.bySemanticsLabel('Test input'), '30.0');
        await tester.unfocusAndSettle();

        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '20.0');
      });

      testWidgets('changes input value to min when entering too low value in text field', (WidgetTester tester) async {
        await tester.renderWidget(TestWrapper(defaultValue: 20.0, min: 10.0));
        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '20.0');

        await tester.enterTextAndSettle(find.bySemanticsLabel('Test input'), '1.0');
        await tester.unfocusAndSettle();

        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '10.0');
      });

      testWidgets('does not change input value when entering invalid value in text field', (WidgetTester tester) async {
        await tester.renderWidget(TestWrapper(defaultValue: 20.0, min: 10.0));
        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '20.0');

        await tester.enterTextAndSettle(find.bySemanticsLabel('Test input'), 'test');
        await tester.unfocusAndSettle();

        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '20.0');
      });

      testWidgets('does not change input value when entering new empty value in text field', (
        WidgetTester tester,
      ) async {
        await tester.renderWidget(TestWrapper(defaultValue: 50.0));
        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '50.0');

        await tester.enterTextAndSettle(find.bySemanticsLabel('Test input'), '');
        await tester.unfocusAndSettle();

        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '50.0');
      });

      testWidgets('changes input value to min when entering negative value is allowed in text field', (
        WidgetTester tester,
      ) async {
        await tester.renderWidget(TestWrapper(defaultValue: 20.0, min: 0.0, allowNegativeNumbers: true));
        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '20.0');

        await tester.enterTextAndSettle(find.bySemanticsLabel('Test input'), '-0.1');
        await tester.unfocusAndSettle();

        expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '0.0');
      }, skip: true); // FIXME: Fix text range out of bounds error
    });
  });

  group('slider int', () {
    testWidgets('increases input value when moving slider to right', (WidgetTester tester) async {
      await tester.renderWidget(TestWrapper(defaultValue: 50.0));
      expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '50.0');

      final Finder slider = find.bySemanticsLabel('Test slider');
      await tester.dragFromCenterToTargetAndSettle(slider, const Offset(10, 0));

      expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '51.0');
    });

    testWidgets('decreases input value when moving slider to left', (WidgetTester tester) async {
      await tester.renderWidget(TestWrapper(defaultValue: 50.0));
      expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '50.0');

      final Finder slider = find.bySemanticsLabel('Test slider');
      await tester.dragFromCenterToTargetAndSettle(slider, const Offset(-10, 0));

      expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '49.0');
    });

    testWidgets('increases input value to max when moving slider far to right', (WidgetTester tester) async {
      await tester.renderWidget(TestWrapper(defaultValue: 50.0, max: 100.0));
      expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '50.0');

      final Finder slider = find.bySemanticsLabel('Test slider');
      await tester.dragFromCenterToTargetAndSettle(slider, const Offset(500, 0));

      expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '100.0');
    });

    testWidgets('decreases input value to min when moving slider far to left', (WidgetTester tester) async {
      await tester.renderWidget(TestWrapper(defaultValue: 50.0, min: 0.0));
      expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '50.0');

      final Finder slider = find.bySemanticsLabel('Test slider');
      await tester.dragFromCenterToTargetAndSettle(slider, const Offset(-500, 0));

      expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '0.0');
    });

    testWidgets('changes input value to slider value when tapping on slider', (WidgetTester tester) async {
      await tester.renderWidget(TestWrapper(defaultValue: 10.0));
      expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '10.0');

      await tester.tapAtCenterAndSettle(find.bySemanticsLabel('Test slider'));

      expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '50.0');
    });

    testWidgets('changes slider value to input value when changing input value', (WidgetTester tester) async {
      await tester.renderWidget(TestWrapper(defaultValue: 10.0));
      expect(tester.getSemantics(find.bySemanticsLabel('Test input')).value, '10.0');

      await tester.tapAndSettle(find.bySemanticsLabel('Plus button'));

      expect(tester.getSemantics(find.bySemanticsLabel('Test slider')).value, '11.0');
    });
  });
}
