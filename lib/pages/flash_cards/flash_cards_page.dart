import 'package:flutter/material.dart';
import 'package:tiomusic/domain/flash_cards/flash_cards.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/widgets/flash_card/flash_card.dart';

class FlashCardsPage extends StatelessWidget {
  const FlashCardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      appBar: AppBar(
        title: Text(context.l10n.flashCardsPageTitle),
        backgroundColor: ColorTheme.surfaceBright,
        foregroundColor: ColorTheme.primary,
      ),
      backgroundColor: ColorTheme.primary92,
      body: SafeArea(bottom: false, child: _FlashCardsList()),
    );
  }
}

class _FlashCardsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cards = FlashCards().load(context.l10n);

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (_, i) => FlashCard(description: cards[i].description),
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemCount: cards.length,
    );
  }
}
