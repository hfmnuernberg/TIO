import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:tiomusic/l10n/delegate.dart';
import 'package:tiomusic/util/color_schemes.g.dart';

extension WidgetTesterRenderExtension on WidgetTester {
  Future<void> renderScaffold(Widget scaffold, [List<SingleChildWidget> providers = const []]) async {
    await pumpWidget(
      MultiProvider(
        providers: providers,
        child: MaterialApp(
          navigatorObservers: [RouteObserver<PageRoute>()],
          theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
          localizationsDelegates: [...GlobalMaterialLocalizations.delegates, AppLocalizationsDelegate()],
          supportedLocales: const [Locale('en', 'US'), Locale('de', 'DE')],
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
}
