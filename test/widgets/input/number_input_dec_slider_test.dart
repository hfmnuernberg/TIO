import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../utils/action_utils.dart';
import '../../utils/render_utils.dart';
import 'number_input_dec_test_utils.dart';

void main() {
  setUpAll(WidgetsFlutterBinding.ensureInitialized);

  group('slider decimal', () {
    testWidgets('increases input value when moving slider to right', (tester) async {
      await tester.renderWidget(TestWrapper(value: 10));
      expect(tester.getSemantics(find.bySemanticsLabel('Test Input')).value, '10');

      final Finder slider = find.bySemanticsLabel('Test Slider');
      await tester.dragFromCenterToTargetAndSettle(slider, const Offset(10, 0));

      expect(tester.getSemantics(find.bySemanticsLabel('Test Input')).value, '51');
    });

    testWidgets('decreases input value when moving slider to left', (tester) async {
      await tester.renderWidget(TestWrapper(value: 10));

      final Finder slider = find.bySemanticsLabel('Test Slider');
      await tester.dragFromCenterToTargetAndSettle(slider, const Offset(-10, 0));

      expect(tester.getSemantics(find.bySemanticsLabel('Test Input')).value, '49');
    });

    testWidgets('increases input value to max when moving slider far to right', (tester) async {
      await tester.renderWidget(TestWrapper(value: 10, max: 50));

      final Finder slider = find.bySemanticsLabel('Test Slider');
      await tester.dragFromCenterToTargetAndSettle(slider, const Offset(500, 0));

      expect(tester.getSemantics(find.bySemanticsLabel('Test Input')).value, '50');
    });

    testWidgets('decreases input value to min when moving slider far to left', (tester) async {
      await tester.renderWidget(TestWrapper(value: 10, min: 1));

      final Finder slider = find.bySemanticsLabel('Test Slider');
      await tester.dragFromCenterToTargetAndSettle(slider, const Offset(-500, 0));

      expect(tester.getSemantics(find.bySemanticsLabel('Test Input')).value, '1');
    });

    testWidgets('changes input value to slider value when tapping on slider', (tester) async {
      await tester.renderWidget(TestWrapper(value: 10, max: 50));
      expect(tester.getSemantics(find.bySemanticsLabel('Test Input')).value, '10');

      await tester.tapAtCenterAndSettle(find.bySemanticsLabel('Test Slider'));

      expect(tester.getSemantics(find.bySemanticsLabel('Test Input')).value, '25');
    });

    testWidgets('changes slider value to input value when changing input value', (tester) async {
      await tester.renderWidget(TestWrapper(value: 10));
      expect(tester.getSemantics(find.bySemanticsLabel('Test Input')).value, '10');

      await tester.tapAndSettle(find.bySemanticsLabel('Plus button'));

      expect(tester.getSemantics(find.bySemanticsLabel('Test Slider')).value, '11');
    });
  });
}
