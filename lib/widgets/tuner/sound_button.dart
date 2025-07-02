import 'package:flutter/material.dart';
import 'package:tiomusic/util/color_constants.dart';

const double buttonWidth = 40;
const double buttonPadding = 4;

class SoundButton extends StatelessWidget {
  final bool isActive;
  final String label;
  final VoidCallback onToggle;

  const SoundButton({super.key, required this.isActive, required this.label, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.all(buttonPadding),
        child: Container(
          width: buttonWidth,
          height: 60,
          decoration: BoxDecoration(
            color: isActive ? ColorTheme.primary : ColorTheme.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(label, style: TextStyle(color: isActive ? ColorTheme.surface : ColorTheme.primary)),
          ),
        ),
      ),
    );
  }
}
