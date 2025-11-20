import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiomusic/pages/projects_page/projects_page.dart';

import '../../utils/action_utils.dart';
import '../../utils/render_utils.dart';
import '../../utils/test_context.dart';

void main() {
  late TestContext context;

  setUpAll(WidgetsFlutterBinding.ensureInitialized);

  setUp(() async {
    context = TestContext();
    await context.init();
  });

  group('ProjectsPage - Navigation', () {
    testWidgets('navigates to about page on menu item tap', (tester) async {
      await tester.renderScaffold(ProjectsPage(), context.providers);

      await tester.tapAndSettle(find.byTooltip('Projects menu'));
      await tester.tapAndWaitFor(find.bySemanticsLabel('About'));

      expect(find.bySemanticsLabel('About'), findsOneWidget);
    });

    testWidgets('navigates to feedback page on menu item tap', (tester) async {
      await tester.renderScaffold(ProjectsPage(), context.providers);

      await tester.tapAndSettle(find.byTooltip('Projects menu'));
      await tester.tapAndWaitFor(find.bySemanticsLabel('Feedback'));

      expect(find.bySemanticsLabel('Feedback survey'), findsOneWidget);
    });

    testWidgets('navigates to practice tips page on tip of the day button tap', (tester) async {
      await tester.renderScaffold(ProjectsPage(), context.providers);

      await tester.tapAndSettle(find.bySemanticsLabel('View more'));
      await tester.tapAndWaitFor(find.bySemanticsLabel('Practice tips'));

      expect(find.bySemanticsLabel('Practice tips'), findsOneWidget);
    });

    testWidgets('navigates to practice tips page on tip of the day button tap', (tester) async {
      await tester.renderScaffold(ProjectsPage(), context.providers);

      await tester.tapAndSettle(find.bySemanticsLabel('View more'));
      await tester.tapAndWaitFor(find.bySemanticsLabel('Practice tips'));

      expect(find.bySemanticsLabel('Practice tips'), findsOneWidget);
    });
  });
}
