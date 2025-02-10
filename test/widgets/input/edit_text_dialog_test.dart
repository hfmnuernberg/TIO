import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiomusic/widgets/input/edit_text_dialog.dart';

extension WidgetTesterPumpExtension on WidgetTester {
  Future<void> renderWidget(Widget widget) => pumpWidget(MaterialApp(home: Scaffold(body: widget)));
}

class TestWrapper extends StatefulWidget {
  final bool isNew;

  const TestWrapper({
    super.key,
    this.isNew = false
  });

  @override
  State<TestWrapper> createState() => _TestWrapperState();
}

class _TestWrapperState extends State<TestWrapper> {
  String? text;

  @override
  void initState() {
    super.initState();
  }

  Future<void> handleDialog() async {
    final newText = await showEditTextDialog(
      context: context,
      label: 'Label',
      value: 'Old title',
      isNew: widget.isNew,
    );
    setState(() {
      text = newText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        text == null ? Text('Old title') : Text(text!),
        TextButton(
          onPressed: handleDialog,
          child: Text('Open Dialog'),
        ),
      ],
    );
  }
}

void main() {
  setUpAll(() {
    WidgetsFlutterBinding.ensureInitialized();
  });

  group('edit text dialog', () {
    testWidgets('shows edit text dialog when open dialog is pressed', (WidgetTester tester) async {
      await tester.renderWidget(TestWrapper());
      expect(find.byType(AlertDialog), findsNothing);

      await tester.tap(find.bySemanticsLabel('Open Dialog'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('hides edit text dialog when cancel is pressed', (WidgetTester tester) async {
      await tester.renderWidget(TestWrapper());

      await tester.tap(find.bySemanticsLabel('Open Dialog'));
      await tester.pump();
      expect(find.byType(AlertDialog), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pump();
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('does not allow entering title longer than max value', (WidgetTester tester) async {
      await tester.renderWidget(TestWrapper());

      await tester.tap(find.bySemanticsLabel('Open Dialog'));
      await tester.pump();
      await tester.enterText(find.text('Old title'), 'a'.padLeft(100 + 1, 'a'));
      await tester.pump();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, 'a'.padLeft(100, 'a'));
    });

    testWidgets('shows new title when title change is submitted', (WidgetTester tester) async {
      await tester.renderWidget(TestWrapper());
      expect(find.text('Old title'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Open Dialog'));
      await tester.pumpAndSettle();
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, 'Old title');

      await tester.enterText(find.bySemanticsLabel('Label'), 'Edited title');
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Submit'));
      await tester.pumpAndSettle();

      expect(find.text('Edited title'), findsOneWidget);
      expect(find.text('Old title'), findsNothing);
    });

    testWidgets('shows old title when title change is canceled', (WidgetTester tester) async {
      await tester.renderWidget(TestWrapper());
      expect(find.text('Old title'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Open Dialog'));
      await tester.pumpAndSettle();
      await tester.enterText(find.bySemanticsLabel('Label'), 'Edited title');
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Edited title'), findsNothing);
      expect(find.text('Old title'), findsOneWidget);
    });

    testWidgets('disables submit button when title is empty', (WidgetTester tester) async {
      await tester.renderWidget(TestWrapper());

      await tester.tap(find.bySemanticsLabel('Open Dialog'));
      await tester.pumpAndSettle();
      await tester.enterText(find.bySemanticsLabel('Label'), '');
      await tester.pumpAndSettle();

      final Finder buttonFinder = find.ancestor(
        of: find.bySemanticsLabel('Submit'),
        matching: find.byType(ElevatedButton),
      );
      final ElevatedButton button = tester.widget(buttonFinder);
      expect(button.onPressed, isNull);
    });

    testWidgets('disables submit button when title has not changed', (WidgetTester tester) async {
      await tester.renderWidget(TestWrapper());

      await tester.tap(find.bySemanticsLabel('Open Dialog'));
      await tester.pumpAndSettle();

      final Finder buttonFinder = find.ancestor(
        of: find.bySemanticsLabel('Submit'),
        matching: find.byType(ElevatedButton),
      );
      final ElevatedButton button = tester.widget(buttonFinder);
      expect(button.onPressed, isNull);
    });

    testWidgets('submits title when title has not changed but is marked as new', (WidgetTester tester) async {
      await tester.renderWidget(TestWrapper(isNew: true));
      expect(find.text('Old title'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Open Dialog'));
      await tester.pumpAndSettle();
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, 'Old title');

      await tester.tap(find.bySemanticsLabel('Submit'));
      await tester.pumpAndSettle();

      expect(find.text('Old title'), findsOneWidget);
    });

    testWidgets('does not close dialog when clicking outside of dialog', (WidgetTester tester) async {
      await tester.renderWidget(TestWrapper());

      await tester.tap(find.bySemanticsLabel('Open Dialog'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);

      final dialogRect = tester.getRect(find.byType(AlertDialog));
      final Offset outsideTapOffset = Offset(dialogRect.left - 10, dialogRect.top + 10);
      await tester.tapAt(outsideTapOffset);
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
    });
  });
}
