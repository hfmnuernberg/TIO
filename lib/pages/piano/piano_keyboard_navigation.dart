import 'package:flutter/material.dart';
import 'package:tiomusic/util/color_constants.dart';

class PianoKeyboardNavigation extends StatelessWidget {
  final VoidCallback onOctaveDown;
  final VoidCallback onToneDown;
  final VoidCallback onOctaveUp;
  final VoidCallback onToneUp;
  final Widget child;

  const PianoKeyboardNavigation({
    super.key,
    required this.onOctaveDown,
    required this.onToneDown,
    required this.onOctaveUp,
    required this.onToneUp,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: ColorTheme.primaryFixedDim,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(20)),
            ),
            height: 52,
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.keyboard_double_arrow_left, color: ColorTheme.primary),
                  padding: EdgeInsets.zero,
                  onPressed: onOctaveDown,
                ),
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_left, color: ColorTheme.primary),
                  padding: EdgeInsets.zero,
                  onPressed: onToneDown,
                ),
              ],
            ),
          ),
        ),

        child,

        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: ColorTheme.primaryFixedDim,
              borderRadius: BorderRadius.only(topRight: Radius.circular(20)),
            ),
            height: 52,
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_right, color: ColorTheme.primary),
                  padding: EdgeInsets.zero,
                  onPressed: onToneUp,
                ),
                IconButton(
                  icon: const Icon(Icons.keyboard_double_arrow_right, color: ColorTheme.primary),
                  padding: EdgeInsets.zero,
                  onPressed: onOctaveUp,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
