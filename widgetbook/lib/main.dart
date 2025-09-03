import 'package:accessibility_tools/accessibility_tools.dart';
import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/l10n.dart';
import 'package:tiomusic_widgetbook/main.directories.g.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

void main() {
  runApp(const WidgetbookApp());
}

@widgetbook.App()
class WidgetbookApp extends StatelessWidget {
  const WidgetbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      directories: directories,
      addons: [
        ViewportAddon([Viewports.none, ...IosViewports.all, ...AndroidViewports.all]),
        LocalizationAddon(locales: supportedLocales, localizationsDelegates: localizationsDelegates),
        GridAddon(10),
        InspectorAddon(),
        BuilderAddon(
          name: 'Accessibility',
          builder: (context, child) => AccessibilityTools(child: child),
        ),
        SemanticsAddon(),
      ],
    );
  }
}
