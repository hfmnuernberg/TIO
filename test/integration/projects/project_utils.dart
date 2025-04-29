import 'package:flutter_test/flutter_test.dart';

import '../../utils/action_utils.dart';

extension WidgetTesterProjectExtension on WidgetTester {
  Future<void> createProject(String title) async {
    await tapAndSettle(find.byTooltip('New project'));
    await enterTextAndSettle(find.bySemanticsLabel('New project'), title);
    await tapAndSettle(find.bySemanticsLabel('Submit'));

    await tapAndSettle(find.bySemanticsLabel('Text'));
    await enterTextAndSettle(find.bySemanticsLabel('Tool title'), 'Text 1');
    await tapAndSettle(find.bySemanticsLabel('Submit'));

    await tapAndSettle(find.bySemanticsLabel('Back'));
    await tapAndSettle(find.bySemanticsLabel('Back'));
  }
}
