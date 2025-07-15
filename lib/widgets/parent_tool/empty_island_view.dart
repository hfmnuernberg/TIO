import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';

class EmptyIslandView extends StatelessWidget {
  final VoidCallback onPressed;

  const EmptyIslandView({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: ColorTheme.surface,
      margin: const EdgeInsets.fromLTRB(TIOMusicParams.edgeInset, 8, TIOMusicParams.edgeInset, 0),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: IconButton(
        onPressed: onPressed,
        icon: const Icon(Icons.add_circle, color: ColorTheme.primary),
        tooltip: context.l10n.toolConnectAnother,
      ),
    );
  }
}
