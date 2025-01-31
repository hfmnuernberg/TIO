import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiomusic/widgets/input/edit_text_dialog.dart';

extension WidgetTesterPumpExtension on WidgetTester {
  Future<void> renderWidget(Widget widget) => pumpWidget(MaterialApp(home: Scaffold(body: widget)));
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
  });
}
