import 'package:flutter/material.dart';
import 'package:tiomusic/util/color_constants.dart';

class TutorialNextButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const TutorialNextButton({required this.label, required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      child: Center(
        child: CircleAvatar(
          backgroundColor: ColorTheme.primary.withAlpha(400),
          radius: 50,
          child: TextButton(
            onPressed: onPressed,
            child: Text(label, style: const TextStyle(color: ColorTheme.onPrimary, fontSize: 24)),
          ),
        ),
      ),
    );
  }
}
