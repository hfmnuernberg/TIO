import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../utils/action_utils.dart';
import '../../utils/render_utils.dart';
import 'number_input_dec_test_utils.dart';

void main() {
  setUpAll(WidgetsFlutterBinding.ensureInitialized);

  group('number input decimal', () {
    testWidgets('returns input value when changing value', (tester) async {
      double callbackCalls = 0;
      double mockCallback(double _) => callbackCalls++;

      await tester.renderWidget(TestWrapper(value: 1, onChange: mockCallback));
      expect(callbackCalls, equals(0));

      await tester.tapAndSettle(find.bySemanticsLabel('Plus button'));

      expect(callbackCalls, equals(1));
    });

    testWidgets('increases input value based on given step when tapping plus button', (tester) async {
      await tester.renderWidget(TestWrapper(value: 10.5, step: 2));
      expect(tester.getSemantics(find.bySemanticsLabel('Test Input')).value, '10.5');

      await tester.tapAndSettle(find.bySemanticsLabel('Plus button'));

      expect(tester.getSemantics(find.bySemanticsLabel('Test Input')).value, '12.5');
    });

    testWidgets('does not increase input value higher than max when tapping plus button', (tester) async {
      await tester.renderWidget(TestWrapper(value: 10.5, max: 11, step: 2));

      await tester.tapAndSettle(find.bySemanticsLabel('Plus button'));

      expect(tester.getSemantics(find.bySemanticsLabel('Test Input')).value, '11');
    });

    testWidgets('decreases input value based on given step when tapping minus button', (tester) async {
      await tester.renderWidget(TestWrapper(value: 10.5, step: 2));

      await tester.tapAndSettle(find.bySemanticsLabel('Minus button'));

      expect(tester.getSemantics(find.bySemanticsLabel('Test Input')).value, '8.5');
    });

    testWidgets('does not decrease input value lower than min when tapping minus button', (tester) async {
      await tester.renderWidget(TestWrapper(value: 1.5, min: 1, step: 2));

      await tester.tapAndSettle(find.bySemanticsLabel('Minus button'));

      expect(tester.getSemantics(find.bySemanticsLabel('Test Input')).value, '1');
    });

    testWidgets('changes input value when entering new value', (tester) async {
      await tester.renderWidget(TestWrapper(value: 10));
      expect(tester.getSemantics(find.bySemanticsLabel('Test Input')).value, '10');

      await tester.enterTextAndSettle(find.bySemanticsLabel('Test Input'), '20.0');

      expect(tester.getSemantics(find.bySemanticsLabel('Test Input')).value, '20.0');
    });

    testWidgets('changes input value to max when entering too high value', (tester) async {
      await tester.renderWidget(TestWrapper(value: 10, max: 20));

      await tester.enterTextAndSettle(find.bySemanticsLabel('Test Input'), '30.0');
      await tester.unfocusAndSettle();

      expect(tester.getSemantics(find.bySemanticsLabel('Test Input')).value, '20');
    });

    testWidgets('changes input value to max when entering value higher than max twice', (tester) async {
      await tester.renderWidget(TestWrapper(value: 10, max: 20));

      await tester.enterTextAndSettle(find.bySemanticsLabel('Test Input'), '30');
      await tester.unfocusAndSettle();
      expect(tester.getSemantics(find.bySemanticsLabel('Test Input')).value, '20');

      await tester.enterTextAndSettle(find.bySemanticsLabel('Test Input'), '30');
      await tester.unfocusAndSettle();
      expect(tester.getSemantics(find.bySemanticsLabel('Test Input')).value, '20');
    });

    testWidgets('changes input value to min when entering too low value', (tester) async {
      await tester.renderWidget(TestWrapper(value: 20, min: 10));

      await tester.enterTextAndSettle(find.bySemanticsLabel('Test Input'), '1.0');
      await tester.unfocusAndSettle();

      expect(tester.getSemantics(find.bySemanticsLabel('Test Input')).value, '10');
    });

    testWidgets('does not change input value when entering invalid value', (tester) async {
      await tester.renderWidget(TestWrapper(value: 10));

      await tester.enterTextAndSettle(find.bySemanticsLabel('Test Input'), 'test');
      await tester.unfocusAndSettle();

      expect(tester.getSemantics(find.bySemanticsLabel('Test Input')).value, '10');
    });

    testWidgets('does not change input value when entering new empty value', (tester) async {
      await tester.renderWidget(TestWrapper(value: 10));

      await tester.enterTextAndSettle(find.bySemanticsLabel('Test Input'), '');
      await tester.unfocusAndSettle();

      expect(tester.getSemantics(find.bySemanticsLabel('Test Input')).value, '10');
    });

    testWidgets('increases input value when tapping plus button during editing input value', (tester) async {
      await tester.renderWidget(TestWrapper(value: 10));

      await tester.enterText(find.bySemanticsLabel('Test Input'), '20');
      await tester.tapAndSettle(find.bySemanticsLabel('Plus button'));

      expect(tester.getSemantics(find.bySemanticsLabel('Test Input')).value, '21');
    });

    testWidgets('increases old input value when tapping plus button during input value is empty', (tester) async {
      await tester.renderWidget(TestWrapper(value: 10));

      await tester.enterText(find.bySemanticsLabel('Test Input'), '');
      await tester.tapAndSettle(find.bySemanticsLabel('Plus button'));

      expect(tester.getSemantics(find.bySemanticsLabel('Test Input')).value, '11');
    });
  });
}
