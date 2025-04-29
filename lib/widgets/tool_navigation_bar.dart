import 'package:flutter/material.dart';
import 'package:tiomusic/util/color_constants.dart';

class ToolNavigationBar extends StatelessWidget {
  final int currentIndex;
  final int totalCount;
  final VoidCallback onPreviousPressed;
  final VoidCallback onNextPressed;

  const ToolNavigationBar({
    super.key,
    required this.currentIndex,
    required this.totalCount,
    required this.onPreviousPressed,
    required this.onNextPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (totalCount <= 1) return const SizedBox();

    return BottomAppBar(
      color: ColorTheme.surfaceBright,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(icon: const Icon(Icons.arrow_back_ios, color: ColorTheme.primary), onPressed: onPreviousPressed),
            Text('${currentIndex + 1} / $totalCount', style: const TextStyle(color: ColorTheme.primary)),
            IconButton(icon: const Icon(Icons.arrow_forward_ios, color: ColorTheme.primary), onPressed: onNextPressed),
          ],
        ),
      ),
    );
  }
}
