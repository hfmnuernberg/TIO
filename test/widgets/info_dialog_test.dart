import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiomusic/widgets/info_dialog.dart';

import '../utils/action_utils.dart';
import '../utils/render_utils.dart';

class TestWrapper extends StatelessWidget {
  const TestWrapper({super.key});

  @override
  Widget build(BuildContext context) => TextButton(onPressed: () => showInfoDialog(context: context, title: 'Title', content: Text('Content')), child: Text('Open dialog'));
}

void main() {
  setUpAll(WidgetsFlutterBinding.ensureInitialized);

  group('InfoDialog', () {
    testWidgets('shows dialog', (tester) async {
      await tester.renderWidget(TestWrapper());
      expect(find.bySemanticsLabel('Title'), findsNothing);

      await tester.tapAndSettle(find.bySemanticsLabel('Open dialog'));

      expect(find.bySemanticsLabel('Title'), findsOneWidget);
    });

    testWidgets('hides dialog when action button is pressed', (tester) async {
      await tester.renderWidget(TestWrapper());

      await tester.tapAndSettle(find.bySemanticsLabel('Open dialog'));
      expect(find.bySemanticsLabel('Title'), findsOneWidget);

      await tester.tapAndSettle(find.bySemanticsLabel('Got it'));
      expect(find.bySemanticsLabel('Title'), findsNothing);
    });
  });
}
