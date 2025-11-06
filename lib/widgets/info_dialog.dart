import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/util/color_constants.dart';

Future<void> showInfoDialog({required BuildContext context, required String title, required Widget content}) {
  final l10n = context.l10n;

  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title, style: TextStyle(color: ColorTheme.primary)),
      content: content,
      actions: [TextButton(child: Text(l10n.commonGotIt), onPressed: () => Navigator.pop(context))],
    ),
  );
}
