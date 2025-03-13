import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/pages/home/home_page.dart';
import 'package:tiomusic/util/color_schemes.g.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class App extends StatelessWidget {
  final ProjectLibrary projectLibrary;
  final ThemeData? ourTheme;

  const App({super.key, required this.projectLibrary, this.ourTheme});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProjectLibrary>.value(
      value: projectLibrary,
      child: MaterialApp(
        navigatorObservers: [routeObserver],
        debugShowCheckedModeBanner: false,
        title: 'TIO Music',
        theme: ourTheme ?? ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
        home: const HomePage(),
      ),
    );
  }
}
