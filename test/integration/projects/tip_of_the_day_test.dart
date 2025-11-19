import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tiomusic/domain/flash_cards/flash_cards_list.dart';
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

  group('ProjectsPage - Tip of the day', () {
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
  });
}
