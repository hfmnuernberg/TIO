import 'package:flutter/material.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/util/util_functions.dart';

class QuickToolButton extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback onTap;

  const QuickToolButton({super.key, required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: ColorTheme.primary90),
        ),
        width: MediaQuery.of(context).size.width / 2 - TIOMusicParams.edgeInset,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                circleToolIcon(icon),
                const SizedBox(width: 8),
                Text(label, style: const TextStyle(color: ColorTheme.primary)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
