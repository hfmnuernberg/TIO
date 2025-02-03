import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiomusic/widgets/input/edit_text_dialog.dart';

final int maxLength = 100;

extension WidgetTesterPumpExtension on WidgetTester {
  Future<void> renderWidget(Widget widget) => pumpWidget(MaterialApp(home: Scaffold(body: widget)));
}

class TestWrapper extends StatelessWidget {
  const TestWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => showEditTextDialog(context: context, label: 'Label', value: 'Old title'),
      child: Text('Open Dialog'),
    );
  }
}

void main() {
  setUpAll(() {
    WidgetsFlutterBinding.ensureInitialized();
  });

  group('edit text dialog', () {
    testWidgets('calls submit with edited text when save is pressed', (WidgetTester tester) async {
      String editedText = 'Never called';
      await tester.renderWidget(
        EditTextDialog(label: "Label", value: "Old title", onSave: (text) => editedText = text, onCancel: () {}),
      );

      await tester.enterText(find.bySemanticsLabel('Label'), "New title");
      await tester.pump();
      await tester.tap(find.bySemanticsLabel('Submit'));

      expect(editedText, "New title");
    });

    testWidgets('calls cancel when cancel is pressed', (WidgetTester tester) async {
      var wasOnCancelCalled = false;
      await tester.renderWidget(
        EditTextDialog(label: "Label", value: "Old title", onSave: (_) {}, onCancel: () => wasOnCancelCalled = true),
      );

      await tester.tap(find.bySemanticsLabel('Cancel'));

      expect(wasOnCancelCalled, true);
    });

    testWidgets('does not save new title when title has not changed', (WidgetTester tester) async {
      var wasOnSaveCalled = false;
      await tester.renderWidget(
        EditTextDialog(label: "Label", value: "Old title", onSave: (_) => wasOnSaveCalled = true, onCancel: () {}),
      );

      await tester.tap(find.bySemanticsLabel('Submit'));

      expect(wasOnSaveCalled, false);
    });

    testWidgets('does not save new title when new title is empty', (WidgetTester tester) async {
      var wasOnSaveCalled = false;
      await tester.renderWidget(
        EditTextDialog(label: "Label", value: "Old title", onSave: (_) => wasOnSaveCalled = true, onCancel: () {}),
      );

      await tester.enterText(find.text('Old title'), '');
      await tester.tap(find.bySemanticsLabel('Submit'));

      expect(wasOnSaveCalled, false);
    });

    testWidgets('shows edit text dialog when open dialog is pressed', (WidgetTester tester) async {
      await tester.renderWidget(TestWrapper());
      expect(find.text('Old title'), findsNothing);

      await tester.tap(find.bySemanticsLabel('Open Dialog'));
      await tester.pump();
      expect(find.text('Old title'), findsOneWidget);
    });

    testWidgets('hides edit text dialog when cancel is pressed', (WidgetTester tester) async {
      await tester.renderWidget(TestWrapper());

      await tester.tap(find.bySemanticsLabel('Open Dialog'));
      await tester.pump();

      expect(find.text('Old title'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pump();
      expect(find.text('Old title'), findsNothing);
    });

    testWidgets('does not allow entering new title longer than max value', (WidgetTester tester) async {
      await tester.renderWidget(TestWrapper());

      await tester.tap(find.bySemanticsLabel('Open Dialog'));
      await tester.pump();

      expect(find.text('Old title'), findsOneWidget);

      await tester.enterText(find.text('Old title'), 'a'.padLeft(maxLength + 1, 'a'));
      await tester.pump();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text.length, 100);
    });
  });
}
