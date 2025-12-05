import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants/constants.dart';

class NoIslandView extends StatelessWidget {
  final Alignment alignment;

  const NoIslandView({super.key, required this.alignment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: TIOMusicParams.edgeInset, right: TIOMusicParams.edgeInset),
      child: Align(
        alignment: alignment,
        child: Text(context.l10n.toolUseBookmarkToSave, style: TextStyle(color: ColorTheme.surfaceTint, fontSize: 16)),
      ),
    );
  }
}
