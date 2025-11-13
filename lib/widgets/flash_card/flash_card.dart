import 'package:flutter/material.dart';
import 'package:tiomusic/domain/flash_cards/flash_cards.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/util/color_constants.dart';

class FlashCard extends StatelessWidget {
  final FlashCardCategory category;
  final String description;

  const FlashCard({super.key, required this.category, required this.description});

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
                Text(description, style: const TextStyle(color: ColorTheme.primary)),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(category.icon, color: ColorTheme.surfaceTint, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        context.l10n.categoryLabel(category),
                        style: const TextStyle(color: ColorTheme.primary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
