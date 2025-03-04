import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiomusic/pages/projects_list/projects_list.dart';

import '../../utils/utils.dart';

extension on WidgetTester {
  Future<void> createProject(String title) async {
    await tapAndSettle(find.bySemanticsLabel('Add new project'));
    await enterTextAndSettle(find.bySemanticsLabel('New project title'), 'Project 1');
    await tapAndSettle(find.bySemanticsLabel('Submit'));

    await tapAndSettle(find.bySemanticsLabel('Text'));
    await enterTextAndSettle(find.bySemanticsLabel('Tool title'), 'Text 1');
    await tapAndSettle(find.bySemanticsLabel('Submit'));

    await tapAndSettle(find.bySemanticsLabel('Back'));
    await tapAndSettle(find.bySemanticsLabel('Back'));
  }
}

void main() {
  setUpAll(WidgetsFlutterBinding.ensureInitialized);

  setUp(() {});

  testWidgets('shows no projects initially', (tester) async {
    await tester.renderScaffoldWithProjectLibrary(ProjectsList());

    expect(find.bySemanticsLabel("Please click on '+' to create a new project."), findsOneWidget);
  });

  testWidgets('shows one project when one project was added', (tester) async {
    await tester.renderScaffoldWithProjectLibrary(ProjectsList());

    await tester.createProject('Project 1');

    expect(find.bySemanticsLabel('Project 1'), findsOneWidget);
    expect(find.bySemanticsLabel("Please click on '+' to create a new project."), findsNothing);
  });

  testWidgets('deletes project when project was deleted', (tester) async {
    await tester.renderScaffoldWithProjectLibrary(ProjectsList());

    await tester.createProject('Project 1');
    await tester.tapAndSettle(find.bySemanticsLabel('Delete project'));
    await tester.tapAndSettle(find.bySemanticsLabel('Yes'));

    expect(find.bySemanticsLabel('Project 1'), findsNothing);
  });
}
