import 'package:flutter_test/flutter_test.dart';

import '../../utils/action_utils.dart';

extension WidgetTesterPumpExtension on WidgetTester {
  Future<void> createProjectWithoutTool(String title) async {
    await tapAndSettle(find.byTooltip('Add new project'));
    await enterTextAndSettle(find.bySemanticsLabel('New project'), title);
    await tapAndSettle(find.bySemanticsLabel('Submit'));
  }

  Future<void> createAndOpenTool(String tool) async {
    await tapAndSettle(find.bySemanticsLabel(tool));
    await enterTextAndSettle(find.bySemanticsLabel('Tool title'), '$tool 1');
    await tapAndSettle(find.bySemanticsLabel('Submit'));
  }

  Future<void> createAndOpenQuickTool(String tool) async {
    await tapAndSettle(find.bySemanticsLabel(tool));
  }

  Future<void> completeInitialTutorial() async {
    await waitForTutorialNext();
    await tapAndSettle(find.bySemanticsLabel('Next'));
    await tapAndSettle(find.bySemanticsLabel('Next'));
    await tapAndSettle(find.bySemanticsLabel('Next'));
    await tapAndSettle(find.bySemanticsLabel('Next'));
  }

  Future<void> completeParentToolTutorial() async {
    await waitForTutorialNext();
    await tapAndSettle(find.bySemanticsLabel('Next'));
    await tapAndSettle(find.bySemanticsLabel('Next'));
  }

  Future<void> completeProjectTutorial() async {
    await waitForTutorialNext();
    await tapAndSettle(find.bySemanticsLabel('Next'));
    await tapAndSettle(find.bySemanticsLabel('Next'));
  }

  Future<void> completeTunerTutorial() async {
    await waitForTutorialNext();
    await tapAndSettle(find.bySemanticsLabel('Next'));
    await tapAndSettle(find.bySemanticsLabel('Next'));
  }

  Future<void> completeTextTutorial() async {
    await waitForTutorialNext();
    await tapAndSettle(find.bySemanticsLabel('Next'));
    await tapAndSettle(find.bySemanticsLabel('Next'));
  }

  Future<void> goBackAndSaveQuickToolInNewProject() async {
    await tapAndSettle(find.bySemanticsLabel('Back'));
    await tapAndSettle(find.bySemanticsLabel('Yes'));
    await tapAndSettle(find.bySemanticsLabel('Save in new project'));
    await tapAndSettle(find.bySemanticsLabel('Submit'));
  }

  Future<void> waitForTutorialNext({Duration timeout = const Duration(seconds: 5)}) async {
    final next = find.bySemanticsLabel('Next');
    const step = Duration(milliseconds: 100);
    var waited = Duration.zero;
    while (next.evaluate().isEmpty && waited < timeout) {
      await pump(step);
      waited += step;
    }
  }
}
