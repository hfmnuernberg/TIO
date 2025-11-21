import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tiomusic/pages/projects_page/projects_page.dart';

import '../../utils/action_utils.dart';
import '../../utils/render_utils.dart';
import '../../utils/test_context.dart';

extension WidgetTesterPumpExtension on WidgetTester {
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

  group('Tip of the day', () {
    testWidgets('shows same tip of the day when reopening on the same day', (tester) async {
      await tester.renderScaffold(const ProjectsPage(), context.providers);
      expect(find.bySemanticsLabel(RegExp('play your piece with flutter tongue')), findsOneWidget);

      await tester.simulateAppClose();

      await tester.renderScaffold(const ProjectsPage(), context.providers);
      expect(find.bySemanticsLabel(RegExp('play your piece with flutter tongue')), findsOneWidget);
    });

    testWidgets('save no new suggested flash cards when reopening on the same day', (tester) async {
      await tester.renderScaffold(const ProjectsPage(), context.providers);
      expect((await context.projectRepo.loadLibrary()).seenFlashCards.length, 1);

      await tester.simulateAppClose();

      expect((await context.projectRepo.loadLibrary()).seenFlashCards.length, 1);
      expect((await context.projectRepo.loadLibrary()).seenFlashCards[0].id, 'practicing004');
    });

    testWidgets('shows new tip of the day after regenerating', (tester) async {
      await tester.renderScaffold(const ProjectsPage(), context.providers);
      expect(find.bySemanticsLabel(RegExp('play your piece with flutter tongue')), findsOneWidget);

      await tester.tapAndSettle(find.bySemanticsLabel('Regenerate'));

      expect(find.bySemanticsLabel(RegExp('play your piece with flutter tongue')), findsNothing);
      expect(find.bySemanticsLabel(RegExp('listen to a recording of your piece')), findsOneWidget);
    });

    testWidgets('saves suggested flash cards after regenerating', (tester) async {
      await tester.renderScaffold(const ProjectsPage(), context.providers);
      expect((await context.projectRepo.loadLibrary()).seenFlashCards.length, 1);

      await tester.tapAndSettle(find.bySemanticsLabel('Regenerate'));

      expect((await context.projectRepo.loadLibrary()).seenFlashCards.length, 2);
      expect((await context.projectRepo.loadLibrary()).seenFlashCards[1].id, 'mixUp048');
    });

    testWidgets('shows one of all flash cards when all cards are suggested once', (tester) async {
      await tester.renderScaffold(const ProjectsPage(), context.providers);
      expect(find.bySemanticsLabel(RegExp('play your piece with flutter tongue')), findsOneWidget);

      for (int i = 0; i < context.flashCards.getAll().length; i++) {
        await tester.tapAndSettle(find.bySemanticsLabel('Regenerate'));
      }

      expect(find.bySemanticsLabel(RegExp("record a passage you can't play yet")), findsOneWidget);
    });

    testWidgets('resets suggested flash cards when all cards are suggested once', (tester) async {
      await tester.renderScaffold(const ProjectsPage(), context.providers);
      expect((await context.projectRepo.loadLibrary()).seenFlashCards.length, 1);

      for (int i = 0; i < context.flashCards.getAll().length; i++) {
        await tester.tapAndSettle(find.bySemanticsLabel('Regenerate'));
      }

      expect((await context.projectRepo.loadLibrary()).seenFlashCards.length, 1);
      expect((await context.projectRepo.loadLibrary()).seenFlashCards[0].id, 'practicing027');
    });
  });
}
