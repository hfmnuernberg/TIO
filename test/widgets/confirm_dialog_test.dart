import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiomusic/widgets/confirm_dialog.dart';

import '../utils/action_utils.dart';
import '../utils/render_utils.dart';

class TestWrapper extends StatelessWidget {
  const TestWrapper({super.key});

  Future<void> handleOpenDialog(BuildContext context) async {
    await showConfirmDialog(context: context, title: Text('Title'), content: Text('Content'));
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(onPressed: () => handleOpenDialog(context), child: Text('Open dialog'));
  }
}

void main() {
  setUpAll(WidgetsFlutterBinding.ensureInitialized);

  group('ConfirmDialog', () {
    testWidgets('shows dialog', (tester) async {
      await tester.renderWidget(TestWrapper());
      expect(find.bySemanticsLabel('Title'), findsNothing);

      await tester.tapAndSettle(find.bySemanticsLabel('Open dialog'));

      expect(find.bySemanticsLabel('Title'), findsOneWidget);
    });

    testWidgets('hides dialog when cancel button is pressed', (tester) async {
      await tester.renderWidget(TestWrapper());

      await tester.tapAndSettle(find.bySemanticsLabel('Open dialog'));
      expect(find.bySemanticsLabel('Title'), findsOneWidget);

      await tester.tapAndSettle(find.bySemanticsLabel('Cancel'));
      expect(find.bySemanticsLabel('Title'), findsNothing);
    });

    testWidgets('hides dialog when confirm button is pressed', (tester) async {
      await tester.renderWidget(TestWrapper());

      await tester.tapAndSettle(find.bySemanticsLabel('Open dialog'));
      expect(find.bySemanticsLabel('Title'), findsOneWidget);

      await tester.tapAndSettle(find.bySemanticsLabel('Confirm'));
      expect(find.bySemanticsLabel('Title'), findsNothing);
    });
  });
}
