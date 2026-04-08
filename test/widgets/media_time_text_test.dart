import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiomusic/widgets/media_time_text.dart';

void main() {
  Future<void> pump(WidgetTester tester, Duration duration) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: MediaTimeText(duration: duration)),
      ),
    );
  }

  testWidgets('renders sub-minute as S.mmm', (tester) async {
    await pump(tester, const Duration(seconds: 12, milliseconds: 345));
    expect(find.text('12.345'), findsOneWidget);
  });

  testWidgets('renders minutes as M:SS.mmm', (tester) async {
    await pump(tester, const Duration(minutes: 2, seconds: 5, milliseconds: 7));
    expect(find.text('2:05.007'), findsOneWidget);
  });

  testWidgets('renders hours as H:MM:SS.mmm with milliseconds preserved', (tester) async {
    await pump(tester, const Duration(hours: 1, minutes: 15, seconds: 30, milliseconds: 42));
    expect(find.text('1:15:30.042'), findsOneWidget);
  });
}
