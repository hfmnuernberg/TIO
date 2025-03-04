import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/main.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/util/color_schemes.g.dart';

extension WidgetTesterPumpExtension on WidgetTester {
  Future<void> renderScaffoldWithProjectLibrary(Widget scaffold) async {
    await pumpWidget(
      ChangeNotifierProvider<ProjectLibrary>.value(
        value: ProjectLibrary.withDefaults()..dismissAllTutorials(),
        child: MaterialApp(
          navigatorObservers: [routeObserver],
          theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
          home: scaffold,
        ),
      ),
    );
    await pumpAndSettle();
  }

  Future<void> renderWidget(Widget widget) async {
    await pumpWidget(MaterialApp(home: Scaffold(body: widget)));
    await pumpAndSettle();
  }

  Future<void> tapAndSettle(FinderBase<Element> finder) async {
    await tap(finder);
    await pumpAndSettle();
  }

  Future<void> enterTextAndSettle(FinderBase<Element> finder, String text) async {
    await enterText(finder, text);
    await pumpAndSettle();
  }
}
