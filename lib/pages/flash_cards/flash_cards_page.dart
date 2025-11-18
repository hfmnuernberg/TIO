import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/services/flash_cards.dart';
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
    final cards = context.read<FlashCards>().load();
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 32 + bottomInset),
      itemBuilder: (_, i) => FlashCard(category: cards[i].category, description: cards[i].description(context.l10n)),
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemCount: cards.length,
    );
  }
}
