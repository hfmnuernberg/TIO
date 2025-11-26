import 'package:flutter/material.dart';
import 'package:tiomusic/domain/flash_cards/category.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/widgets/flash_cards/category_filter_button.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/widgets/flash_cards/flash_cards_list.dart';

class FlashCardsPage extends StatefulWidget {
  const FlashCardsPage({super.key});

  @override
  State<FlashCardsPage> createState() => _FlashCardsPageState();
}

class _FlashCardsPageState extends State<FlashCardsPage> {
  FlashCardCategory? selectedCategory;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      appBar: AppBar(
        title: Text(context.l10n.flashCardsPageTitle),
        backgroundColor: ColorTheme.surfaceBright,
        foregroundColor: ColorTheme.primary,
      ),
      backgroundColor: ColorTheme.primary92,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 32 + bottomInset),
          child: Column(
            children: [
              Row(
                children: [
                  CategoryFilterButton(
                    category: selectedCategory,
                    onSelected: (category) => setState(() => selectedCategory = category),
                  ),
                  SizedBox(width: 16),
                  Semantics(
                    label: context.l10n.filterBookmarkEnable,
                    button: true,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: ColorTheme.onPrimary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: InkWell(
                        onTap: () {},
                        borderRadius: BorderRadius.circular(8),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          child: Icon(Icons.bookmark_add_outlined, color: ColorTheme.primary),
                        ),
                      ),
                    ),
                  ),
                ]
              ),
              SizedBox(height: 16),
              Expanded(child: FlashCardsList(categoryFilter: selectedCategory)),
            ],
          ),
        ),
      ),
    );
  }
}
