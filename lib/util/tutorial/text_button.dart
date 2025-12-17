import 'package:flutter/material.dart';
import 'package:tiomusic/util/color_constants.dart';

class TutorialTextButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const TutorialTextButton({required this.label, required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      child: Center(
        child: CircleAvatar(
          backgroundColor: ColorTheme.primary,
          radius: 45,
          child: TextButton(
            onPressed: onPressed,
            child: Text(label, style: const TextStyle(color: ColorTheme.onPrimary, fontSize: 12)),
          ),
        ),
      ),
    );
  }
}
