import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

extension WidgetTesterFinderExtension on WidgetTester {
  Finder within(FinderBase<Element> parentFinder, FinderBase<Element> childFinder) =>
      find.descendant(of: parentFinder, matching: childFinder);
}
