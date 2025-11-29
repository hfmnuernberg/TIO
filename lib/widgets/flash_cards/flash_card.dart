import 'package:flutter/material.dart';
import 'package:tiomusic/domain/flash_cards/category.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/flash_card_category_extension.dart';

class FlashCard extends StatelessWidget {
  final FlashCardCategory category;
  final String description;
  final bool isBookmarked;
  final VoidCallback onToggle;

  const FlashCard({
    super.key,
    required this.category,
    required this.description,
    required this.isBookmarked,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      hint: context.l10n.flashCard,
      child: Material(
        color: ColorTheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 2),
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
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(category.icon, color: ColorTheme.surfaceTint, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              context.l10n.categoryLabel(category),
                              style: const TextStyle(color: ColorTheme.primary, fontSize: 12),
                            ),
                          ],
                        ),
                        Transform.translate(
                          offset: const Offset(16, 0),
                          child: IconButton(
                            onPressed: onToggle,
                            icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border),
                            tooltip: isBookmarked
                                ? context.l10n.flashCardRemoveBookmark
                                : context.l10n.flashCardAddBookmark,
                            color: ColorTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
