import 'package:flutter_test/flutter_test.dart';

import 'action_utils.dart';

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

  Future<void> createTextToolInProject(String content) async {
    await tapAndSettle(find.bySemanticsLabel('Text'));
    await enterTextAndSettle(find.bySemanticsLabel('Tool title'), 'Text 1');
    await tapAndSettle(find.bySemanticsLabel('Submit'));
    await enterTextAndSettle(find.bySemanticsLabel('Text field'), content);
    await tapAndSettle(find.bySemanticsLabel('Back'));
  }

  Future<void> createImageToolInProject() async {
    await tapAndSettle(find.bySemanticsLabel('Image'));
    await enterTextAndSettle(find.bySemanticsLabel('Tool title'), 'Image 1');
    await tapAndSettle(find.bySemanticsLabel('Submit'));
    await tapAndSettle(find.bySemanticsLabel('Do it later'));
    await tapAndSettle(find.bySemanticsLabel('Back'));
  }
}
