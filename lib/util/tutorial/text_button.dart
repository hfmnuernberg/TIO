import 'package:flutter/material.dart';
import 'package:tiomusic/util/color_constants.dart';

class TutorialTextButton extends StatelessWidget {
  final double width;
  final String label;
  final VoidCallback onPressed;

  const TutorialTextButton({required this.width, required this.label, required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Center(
        child: TextButton(
          onPressed: onPressed,
          child: Text(label, style: const TextStyle(color: ColorTheme.onPrimary, fontSize: 16)),
        ),
      ),
    );
  }
}
