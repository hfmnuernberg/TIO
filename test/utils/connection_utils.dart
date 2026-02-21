import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'action_utils.dart';

final connectionDialog = find.byWidgetPredicate(
  (widget) => widget is Semantics && widget.properties.label == 'Connect another tool',
);

extension WidgetTesterConnectionExtension on WidgetTester {
  Future<void> openConnectionDialog() async {
    await ensureVisible(find.byTooltip('Connect another tool'));
    await tapAndSettle(find.byTooltip('Connect another tool'));
  }

  Finder withinConnectionDialog(FinderBase<Element> matching) =>
      find.descendant(of: connectionDialog, matching: matching);

  Finder withinList(FinderBase<Element> matching) =>
      find.descendant(of: find.bySemanticsLabel('Tool list'), matching: matching);

  Future<void> connectExistingTool(String toolTitle) async {
    await openConnectionDialog();
    await tapAndSettle(find.bySemanticsLabel(toolTitle));
    await pumpAndSettle(const Duration(milliseconds: 1100));
  }

  Future<void> connectNewTool(String toolType, String toolTitle) async {
    await openConnectionDialog();
    await tapAndSettle(find.bySemanticsLabel(toolType));
    await enterTextAndSettle(find.bySemanticsLabel('Tool title'), toolTitle);
    await tapAndSettle(find.bySemanticsLabel('Submit'));
    await pumpAndSettle(const Duration(milliseconds: 1100));
  }
}
