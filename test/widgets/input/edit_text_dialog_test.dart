import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiomusic/widgets/input/edit_text_dialog.dart';

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
      String? editedText;
      await tester.renderWidget(
          EditTextDialog(label: "Label", value: "Old title", onSave: (text) => editedText = text, onCancel: () {}),
      );

      await tester.enterText(find.bySemanticsLabel('Label'), "New title");
      await tester.tap(find.bySemanticsLabel('Submit'));

      expect("New title", editedText);
    });

    testWidgets('calls cancel when cancel is pressed', (WidgetTester tester) async {
      var wasOnCancelCalled = false;
      await tester.renderWidget(
        EditTextDialog(label: "Label", value: "Old title", onSave: (_) {}, onCancel: () => wasOnCancelCalled = true),
      );

      await tester.tap(find.bySemanticsLabel('Cancel'));

      expect(true, wasOnCancelCalled);
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

    testWidgets('hides edit text dialog when submit is pressed', (WidgetTester tester) async {
      await tester.renderWidget(TestWrapper());

      await tester.tap(find.bySemanticsLabel('Open Dialog'));
      await tester.pump();

      expect(find.text('Old title'), findsOneWidget);

      await tester.tap(find.text('Submit'));
      await tester.pump();
      expect(find.text('Old title'), findsNothing);
    });
  });
}
