import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/pages/projects_list/projects_list.dart';

import '../../utils/action_utils.dart';
import '../../utils/render_utils.dart';
import 'project_utils.dart';

void main() {
  late List<SingleChildWidget> providers;

  setUpAll(WidgetsFlutterBinding.ensureInitialized);

  setUp(() {
    providers = [
      ChangeNotifierProvider<ProjectLibrary>.value(value: ProjectLibrary.withDefaults()..dismissAllTutorials()),
    ];
  });

  testWidgets('shows no projects initially', (tester) async {
    await tester.renderScaffold(ProjectsList(), providers);

    expect(find.bySemanticsLabel("Please click on '+' to create a new project."), findsOneWidget);
  });

  testWidgets('shows one project when one project was added', (tester) async {
    await tester.renderScaffold(ProjectsList(), providers);

    await tester.createProject('Project 1');

    expect(find.bySemanticsLabel('Project 1'), findsOneWidget);
    expect(find.bySemanticsLabel("Please click on '+' to create a new project."), findsNothing);
  });

  testWidgets('deletes project when project was deleted', (tester) async {
    await tester.renderScaffold(ProjectsList(), providers);

    await tester.createProject('Project 1');
    await tester.tapAndSettle(find.byTooltip('Delete project'));
    await tester.tapAndSettle(find.bySemanticsLabel('Yes'));

    expect(find.bySemanticsLabel('Project 1'), findsNothing);
  });
}
