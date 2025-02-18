import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

extension WidgetTesterPumpExtension on WidgetTester {
  Future<void> renderWidget(Widget widget) async {
    await pumpWidget(MaterialApp(home: Scaffold(body: widget)));
    await pumpAndSettle();
  }

  Future<void> tapAndSettle(FinderBase<Element> finder) async {
    await tap(finder);
    await pumpAndSettle();
  }

  Future<void> enterTextAndSettle(FinderBase<Element> finder, String text) async {
    await enterText(finder, text);
    await pumpAndSettle();
  }
}
