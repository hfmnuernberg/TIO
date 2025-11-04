import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/widgets/flash_card/flash_card.dart';

class FlashCardsPage extends StatelessWidget {
  const FlashCardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(context.l10n.flashCardsPageTitle),
        backgroundColor: ColorTheme.surfaceBright,
        foregroundColor: ColorTheme.primary,
      ),
      backgroundColor: ColorTheme.primary92,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: FlashCard(),
          ),
        ),
      ),
    );
  }
}
