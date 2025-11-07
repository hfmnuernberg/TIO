import 'package:flutter/material.dart';
import 'package:tiomusic/util/color_constants.dart';

class FlashCard extends StatelessWidget {
  final String title;
  final String description;

  const FlashCard({super.key, required this.title, required this.description});

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
                  title,
                  style: const TextStyle(color: ColorTheme.primary, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(description, style: const TextStyle(color: ColorTheme.primary)),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
