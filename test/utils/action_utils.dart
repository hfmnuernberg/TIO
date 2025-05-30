import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

extension WidgetTesterActionxtension on WidgetTester {
  Future<void> tapAndSettle(FinderBase<Element> finder) async {
    await tap(finder);
    await pumpAndSettle();
  }

  Future<void> enterTextAndSettle(FinderBase<Element> finder, String text) async {
    await enterText(finder, text);
    await pumpAndSettle();
  }

  Future<void> dragFromCenterToTargetAndSettle(FinderBase<Element> finder, Offset to) async {
    final Offset widgetCenter = getCenter(finder);
    await dragFrom(widgetCenter, to);
    await pumpAndSettle();
  }
}
