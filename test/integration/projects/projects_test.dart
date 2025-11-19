import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tiomusic/domain/flash_cards/flash_cards_list.dart';
import 'package:tiomusic/pages/projects_page/projects_page.dart';

import '../../utils/action_utils.dart';
import '../../utils/render_utils.dart';
import '../../utils/project_utils.dart';
import '../../utils/test_context.dart';

extension WidgetTesterPumpExtension on WidgetTester {
  Future<void> minimizeTipOfTheDay() async =>
      dragFromCenterToTargetAndSettle(find.bySemanticsLabel('Projects').first, const Offset(0, -1000));

  List<String> getProjectTitles(FinderBase<SemanticsNode> list) {
    final semanticNodesList = list.evaluate().cast<SemanticsNode>().toList();
    return semanticNodesList.map((node) => node.label).toList();
  }

  Future<void> simulateAppClose() async => pumpWidget(const SizedBox.shrink());
}

void main() {
  late TestContext context;

  setUpAll(WidgetsFlutterBinding.ensureInitialized);

  setUp(() async {
    resetMocktailState();
    context = TestContext();
    await context.init();
  });

  group('ProjectsPage', () {
    testWidgets('shows tip of the day', (tester) async {
      await tester.renderScaffold(ProjectsPage(), context.providers);

      expect(find.bySemanticsLabel('Tip of the day'), findsOneWidget);
    });

    testWidgets('shows new tip of the day after regenerating', (tester) async {
      final firstCard = flashCards[0];
      final secondCard = flashCards[1];
      context.flashCardsMock.cards = [firstCard, secondCard];

      context.flashCardsMock.nextRandomCard = firstCard;
      await tester.renderScaffold(const ProjectsPage(), context.providers);
      expect(find.bySemanticsLabel(RegExp('book a ticket for a concert')), findsOneWidget);

      context.flashCardsMock.nextRandomCard = secondCard;
      await tester.tapAndSettle(find.bySemanticsLabel('Regenerate'));
      expect(find.bySemanticsLabel(RegExp('book a ticket for a concert')), findsNothing);
      expect(find.bySemanticsLabel(RegExp('reward yourself with whatever')), findsOneWidget);
    });

    testWidgets('shows same tip of the day when reopening on the same day', (tester) async {
      final firstCard = flashCards[0];
      final secondCard = flashCards[1];
      context.flashCardsMock.cards = [firstCard, secondCard];

      context.flashCardsMock.nextRandomCard = firstCard;
      await tester.renderScaffold(const ProjectsPage(), context.providers);
      expect(find.bySemanticsLabel(RegExp('book a ticket for a concert')), findsOneWidget);

      await tester.simulateAppClose();

      await tester.renderScaffold(const ProjectsPage(), context.providers);
      expect(find.bySemanticsLabel(RegExp('book a ticket for a concert')), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('reward yourself with whatever')), findsNothing);
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

    testWidgets('shows one project when one project was added using menu', (tester) async {
      await tester.renderScaffold(ProjectsPage(), context.providers);

      await tester.tapAndSettle(find.byTooltip('Projects menu'));
      await tester.tapAndSettle(find.bySemanticsLabel('Add new project'));
      await tester.enterTextAndSettle(find.bySemanticsLabel('New project'), 'Project 1');
      await tester.tapAndSettle(find.bySemanticsLabel('Submit'));

      await tester.tapAndSettle(find.bySemanticsLabel('Text'));
      await tester.enterTextAndSettle(find.bySemanticsLabel('Tool title'), 'Text 1');
      await tester.tapAndSettle(find.bySemanticsLabel('Submit'));

      await tester.tapAndSettle(find.bySemanticsLabel('Back'));
      await tester.tapAndSettle(find.bySemanticsLabel('Back'));

      expect(find.bySemanticsLabel('Project 1'), findsOneWidget);
      expect(find.bySemanticsLabel('Please click on "+" to create a new project.'), findsNothing);
    });

    testWidgets('deletes project when project was deleted', (tester) async {
      await tester.renderScaffold(ProjectsPage(), context.providers);

      await tester.createProject('Project 1');
      await tester.minimizeTipOfTheDay();
      await tester.tapAndSettle(find.byTooltip('Edit projects'));
      await tester.tapAndSettle(find.byTooltip('Delete project'));
      await tester.tapAndSettle(find.bySemanticsLabel('Yes'));

      expect(find.bySemanticsLabel('Project 1'), findsNothing);
      expect(find.bySemanticsLabel('Please click on "+" to create a new project.'), findsOneWidget);
    });

    testWidgets('deletes project when project was deleted using menu', (tester) async {
      await tester.renderScaffold(ProjectsPage(), context.providers);

      await tester.createProject('Project 1');
      await tester.minimizeTipOfTheDay();
      await tester.tapAndSettle(find.byTooltip('Projects menu'));
      await tester.tapAndSettle(find.bySemanticsLabel('Edit projects'));
      await tester.tapAndSettle(find.byTooltip('Delete project'));
      await tester.tapAndSettle(find.bySemanticsLabel('Yes'));

      expect(find.bySemanticsLabel('Project 1'), findsNothing);
      expect(find.bySemanticsLabel('Please click on "+" to create a new project.'), findsOneWidget);
    });

    testWidgets('deletes all projects when all projects were deleted using menu', (tester) async {
      await tester.renderScaffold(ProjectsPage(), context.providers);

      await tester.createProject('Project 1');
      await tester.createProject('Project 2');
      await tester.tapAndSettle(find.byTooltip('Projects menu'));
      await tester.tapAndSettle(find.bySemanticsLabel('Delete all projects'));
      await tester.tapAndSettle(find.bySemanticsLabel('Yes'));

      expect(find.bySemanticsLabel('Project 1'), findsNothing);
      expect(find.bySemanticsLabel('Please click on "+" to create a new project.'), findsOneWidget);
    });

    testWidgets('changes order when project is moved during editing', (tester) async {
      await tester.renderScaffold(ProjectsPage(), context.providers);
      await tester.createProject('Project 1');
      await tester.createProject('Project 2');

      await tester.minimizeTipOfTheDay();

      final projectList = find.semantics.byHint('Projects');
      final projectListItems = find.semantics.descendant(of: projectList, matching: find.semantics.byHint('Project'));
      final projectTitles = tester.getProjectTitles(projectListItems);
      expect(projectTitles, equals(['Project 2', 'Project 1']));

      await tester.tapAndSettle(find.byTooltip('Edit projects'));
      await tester.dragFromCenterToTargetAndSettle(find.byTooltip('Reorder').first, const Offset(0, 500));

      final updatedProjectTitles = tester.getProjectTitles(projectListItems);
      expect(updatedProjectTitles, equals(['Project 1', 'Project 2']));
    });

    testWidgets('does not change order when project is moved too less during editing', (tester) async {
      await tester.renderScaffold(ProjectsPage(), context.providers);
      await tester.createProject('Project 1');
      await tester.createProject('Project 2');

      await tester.minimizeTipOfTheDay();

      final projectList = find.semantics.byHint('Projects');
      final projectListItems = find.semantics.descendant(of: projectList, matching: find.semantics.byHint('Project'));
      final projectTitles = tester.getProjectTitles(projectListItems);
      expect(projectTitles, equals(['Project 2', 'Project 1']));

      await tester.tapAndSettle(find.byTooltip('Edit projects'));
      await tester.dragFromCenterToTargetAndSettle(find.byTooltip('Reorder').first, const Offset(0, 10));

      final updatedProjectTitles = tester.getProjectTitles(projectListItems);
      expect(updatedProjectTitles, equals(['Project 2', 'Project 1']));
    });
  });
}
