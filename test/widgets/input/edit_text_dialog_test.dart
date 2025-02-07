import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiomusic/widgets/input/edit_text_dialog.dart';

extension WidgetTesterPumpExtension on WidgetTester {
  Future<void> renderWidget(Widget widget) => pumpWidget(MaterialApp(home: Scaffold(body: widget)));
}

class TestWrapper extends StatefulWidget {
  const TestWrapper({super.key});

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
    );
    setState(() {
      text = newText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        text == null ? Text('not updated') : Text(text!),
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
    testWidgets('calls submit with edited text when save is pressed', (WidgetTester tester) async {
      await tester.renderWidget(TestWrapper());
      expect(find.text('Old title'), findsNothing);

      await tester.tap(find.bySemanticsLabel('Open Dialog'));
      await tester.pumpAndSettle();
      expect(find.text('Old title'), findsOneWidget);

      await tester.enterText(find.bySemanticsLabel('Label'), 'Edited title');
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Submit'));

      expect(find.text('Edited title'), findsOneWidget);
      expect(find.text('Old title'), findsNothing);
    });

    testWidgets('calls cancel when cancel is pressed', (WidgetTester tester) async {
      var wasOnCancelCalled = false;
      await tester.renderWidget(
        EditTextDialog(label: "Label", value: "Old title", onSave: (_) {}, onCancel: () => wasOnCancelCalled = true),
      );

      await tester.tap(find.bySemanticsLabel('Cancel'));

      expect(wasOnCancelCalled, true);
    });

    testWidgets('does not save title when title is empty', (WidgetTester tester) async {
      var wasOnSaveCalled = false;
      String oldValue = 'Old title';
      TextEditingController controller = TextEditingController(text: oldValue);

      await tester.renderWidget(
        EditTextDialog(label: 'Label', value: oldValue, controller: controller, onSave: (_) => wasOnSaveCalled = true, onCancel: () {}),
      );

      await tester.enterText(find.text('Old title'), '');
      await tester.tap(find.bySemanticsLabel('Submit'));

      expect(wasOnSaveCalled, false);
    });

    testWidgets('does not save title when title has not changed', (WidgetTester tester) async {
      var wasOnSaveCalled = false;
      String oldValue = 'Old title';
      TextEditingController controller = TextEditingController(text: oldValue);

      await tester.renderWidget(
        EditTextDialog(label: 'Label', value: oldValue, controller: controller, onSave: (_) => wasOnSaveCalled = true, onCancel: () {}),
      );

      await tester.tap(find.bySemanticsLabel('Submit'));

      expect(wasOnSaveCalled, false);
    });

    testWidgets('submits title when title has not changed but is marked as new', (WidgetTester tester) async {
      String editedText = 'Never called';
      String oldValue = 'Old title';
      TextEditingController controller = TextEditingController(text: oldValue);

      await tester.renderWidget(
        EditTextDialog(
            label: 'Label', value: oldValue, isNew: true, controller: controller, onSave: (text) => editedText = text, onCancel: () {}),
      );

      await tester.tap(find.bySemanticsLabel('Submit'));

      expect(editedText, 'Old title');
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

    testWidgets('does not allow entering title longer than max value', (WidgetTester tester) async {
      await tester.renderWidget(TestWrapper());

      await tester.tap(find.bySemanticsLabel('Open Dialog'));
      await tester.pump();

      expect(find.text('Old title'), findsOneWidget);

      await tester.enterText(find.text('Old title'), 'a'.padLeft(100 + 1, 'a'));
      await tester.pump();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, 'a'.padLeft(100, 'a'));
    });
  });
}
