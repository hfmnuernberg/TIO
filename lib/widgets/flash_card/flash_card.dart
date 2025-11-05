import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/util/color_constants.dart';

class FlashCard extends StatelessWidget {
  const FlashCard({super.key});

  @override
  Widget build(BuildContext context) => Material(
    color: ColorTheme.onPrimary,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l10n.flashCardTitle,
                  style: const TextStyle(color: ColorTheme.primary, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(context.l10n.flashCardDescription, style: const TextStyle(color: ColorTheme.primary)),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
