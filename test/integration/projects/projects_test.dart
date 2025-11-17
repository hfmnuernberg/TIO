import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/pages/projects_page/editable_project_list.dart';
import 'package:tiomusic/pages/projects_page/project_list.dart';
import 'package:tiomusic/pages/projects_page/projects_page.dart';

import '../../utils/action_utils.dart';
import '../../utils/render_utils.dart';
import '../../utils/project_utils.dart';
import '../../utils/test_context.dart';

void main() {
  late TestContext context;

  setUpAll(WidgetsFlutterBinding.ensureInitialized);

  setUp(() async {
    context = TestContext();
    await context.init();
  });

  group('ProjectsPage', () {
    testWidgets('shows tip of the day', (tester) async {
      await tester.renderScaffold(ProjectsPage(), context.providers);

      expect(find.bySemanticsLabel('Tip of the day'), findsOneWidget);
    });

    testWidgets('shows no projects initially', (tester) async {
      await tester.renderScaffold(ProjectsPage(), context.providers);

      expect(find.bySemanticsLabel('Please click on "+" to create a new project.'), findsOneWidget);
    });

    testWidgets('shows one project when one project was added', (tester) async {
      await tester.renderScaffold(ProjectsPage(), context.providers);

      await tester.createProject('Project 1');

      expect(find.bySemanticsLabel('Project 1'), findsOneWidget);
      expect(find.bySemanticsLabel('Please click on "+" to create a new project.'), findsNothing);
    });

    testWidgets('deletes project when project was deleted', (tester) async {
      await tester.renderScaffold(ProjectsPage(), context.providers);

      await tester.createProject('Project 1');
      await tester.tapAndSettle(find.byTooltip('Projects menu'));
      await tester.tapAndSettle(find.bySemanticsLabel('Edit projects'));
      await tester.tapAndSettle(find.byTooltip('Delete project'));
      await tester.tapAndSettle(find.bySemanticsLabel('Yes'));

      expect(find.bySemanticsLabel('Project 1'), findsNothing);
      expect(find.bySemanticsLabel('Please click on "+" to create a new project.'), findsOneWidget);
    });

    testWidgets('changes order when project is moved during editing', (tester) async {
      await tester.renderScaffold(ProjectsPage(), context.providers);
      await tester.createProject('Project 1');
      await tester.createProject('Project 2');

      final pageContext = tester.element(find.byType(ProjectsPage));
      final projectLibrary = pageContext.read<ProjectLibrary>();

      final initialTitles = projectLibrary.projects.map((p) => p.title).toList();
      expect(initialTitles, equals(['Project 2', 'Project 1']));

      await tester.tapAndSettle(find.byTooltip('Projects menu'));
      await tester.tapAndSettle(find.bySemanticsLabel('Edit projects'));

      final editableList = tester.widget<EditableProjectList>(find.byType(EditableProjectList));
      await editableList.onReorder(1, 0);

      await tester.tapAndSettle(find.byTooltip('Finish editing'));

      final updatedTitles = projectLibrary.projects.map((p) => p.title).toList();
      expect(updatedTitles, equals(['Project 1', 'Project 2']));
    });

    testWidgets('does not change order when project is moved too less during editing', (tester) async {
      await tester.renderScaffold(ProjectsPage(), context.providers);
      await tester.createProject('Project 1');
      await tester.createProject('Project 2');

      final initialProjects = tester.widget<ProjectList>(find.byType(ProjectList));
      final initialTitles = initialProjects.projectLibrary.projects.map((p) => p.title).toList();

      expect(initialTitles, equals(['Project 2', 'Project 1']));

      await tester.tapAndSettle(find.byTooltip('Projects menu'));
      await tester.tapAndSettle(find.bySemanticsLabel('Edit projects'));

      await tester.dragFromCenterToTargetAndSettle(find.byTooltip('Reorder').first, const Offset(0, 10));

      await tester.tapAndSettle(find.byTooltip('Finish editing'));

      final updatedProjects = tester.widget<ProjectList>(find.byType(ProjectList));
      final updatedTitles = updatedProjects.projectLibrary.projects.map((p) => p.title).toList();

      expect(updatedTitles, equals(['Project 2', 'Project 1']));
    });
  });
}
