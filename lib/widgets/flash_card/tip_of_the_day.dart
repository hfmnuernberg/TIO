import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tiomusic/domain/flash_cards/flash_cards.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/widgets/flash_card/flash_card.dart';

class TipOfTheDay extends StatelessWidget {
  const TipOfTheDay({super.key});

  @override
  Widget build(BuildContext context) {
    final cards = FlashCards().load();
    final card = cards[Random().nextInt(cards.length)];
    final description = card.description(context.l10n);

    return Material(
      color: ColorTheme.primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lightbulb_outline, color: ColorTheme.surfaceTint, size: TIOMusicParams.titleFontSize),
                  const SizedBox(width: 8),
                  Text(
                    context.l10n.tipOfTheDayTitle,
                    style: const TextStyle(color: ColorTheme.primary, fontSize: TIOMusicParams.titleFontSize),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            FlashCard(category: card.category, description: description),
          ],
        ),
      ),
    );
  }
}
