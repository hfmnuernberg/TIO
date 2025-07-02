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

  Future<void> createTextToolInProject(String title) async {
    await tapAndSettle(find.bySemanticsLabel('Text'));
    await enterTextAndSettle(find.bySemanticsLabel('Tool title'), title);
    await tapAndSettle(find.bySemanticsLabel('Submit'));
    await enterTextAndSettle(find.bySemanticsLabel('Text field'), '$title text content');
    await tapAndSettle(find.bySemanticsLabel('Back'));
  }

  Future<void> createImageToolInProject() async {
    await tapAndSettle(find.bySemanticsLabel('Image'));
    await enterTextAndSettle(find.bySemanticsLabel('Tool title'), 'Image 1');
    await tapAndSettle(find.bySemanticsLabel('Submit'));
    await tapAndSettle(find.bySemanticsLabel('Do it later'));
    await tapAndSettle(find.bySemanticsLabel('Back'));
  }

  Future<void> createMediaPlayerToolInProject() async {
    await tapAndSettle(find.bySemanticsLabel('Media Player'));
    await enterTextAndSettle(find.bySemanticsLabel('Tool title'), 'Media Player 1');
    await tapAndSettle(find.bySemanticsLabel('Submit'));
    await tapAndSettle(find.bySemanticsLabel('Back'));
  }

  Future<void> createPianoToolInProject() async {
    await tapAndSettle(find.bySemanticsLabel('Piano'));
    await enterTextAndSettle(find.bySemanticsLabel('Tool title'), 'Piano 1');
    await tapAndSettle(find.bySemanticsLabel('Submit'));
    await tapAndSettle(find.bySemanticsLabel('Back'));
  }
}
