import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiomusic/widgets/confirm_setting_button.dart';

void main() {
  setUpAll(() async {
    WidgetsFlutterBinding.ensureInitialized();
  });

  group('edit text dialog', () {
    testWidgets('todo', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: Text("todo"))));

      expect(find.bySemanticsLabel("todo"), findsOneWidget);
    });

    testWidgets('todo2', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: ConfirmButton(onTap: () {})));

      expect(find.byType(ConfirmButton), findsOneWidget);
    });
  });
}
