import 'package:flutter/material.dart';
import 'package:tiomusic/domain/flash_cards/flash_card_ids.dart';
import 'package:tiomusic/domain/flash_cards/flash_cards.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/util/color_constants.dart';

class FlashCard extends StatelessWidget {
  final String description;
  final FlashCardCategory category;

  const FlashCard({super.key, required this.description, required this.category});

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
                  alignment: Alignment.bottomRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: ColorTheme.primary92,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      category.label(context.l10n),
                      style: const TextStyle(color: ColorTheme.primary, fontSize: 12),
                    ),
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
