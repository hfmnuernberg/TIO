import 'package:flutter/material.dart';
import 'package:tiomusic/domain/flash_cards/category.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/widgets/flash_card/flash_card.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

class Wrapper extends StatelessWidget {
  final Widget child;

  const Wrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorTheme.secondaryContainer,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 480), child: child),
    );
  }
}

@widgetbook.UseCase(name: 'FlashCard', type: FlashCard)
Widget flashCard(BuildContext context) {
  return Wrapper(
    child: const FlashCard(category: FlashCardCategory.team, description: 'Some description'),
  );
}
