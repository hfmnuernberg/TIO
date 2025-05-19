import 'package:flutter/material.dart';
import 'package:tiomusic/util/color_constants.dart';

class PianoSettings extends StatelessWidget {
  final VoidCallback onOctaveDown;
  final VoidCallback onToneDown;
  final VoidCallback onOctaveUp;
  final VoidCallback onToneUp;
  final VoidCallback onOpenPitch;
  final VoidCallback onOpenVolume;
  final VoidCallback onOpenSound;
  final Key? keyOctaveSwitch;
  final Key? keySettings;

  const PianoSettings({
    super.key,
    required this.onOctaveDown,
    required this.onToneDown,
    required this.onOctaveUp,
    required this.onToneUp,
    required this.onOpenPitch,
    required this.onOpenVolume,
    required this.onOpenSound,
    this.keyOctaveSwitch,
    this.keySettings,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          key: keyOctaveSwitch,
          mainAxisSize: MainAxisSize.min,
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

        Row(
          key: keySettings,
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const CircleAvatar(
                backgroundColor: ColorTheme.primary50,
                child: Text('Hz', style: TextStyle(color: ColorTheme.onPrimary, fontSize: 20)),
              ),
              padding: EdgeInsets.zero,
              onPressed: onOpenPitch,
            ),
            IconButton(
              icon: const CircleAvatar(
                backgroundColor: ColorTheme.primary50,
                child: Icon(Icons.volume_up, color: ColorTheme.onPrimary),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              onPressed: onOpenVolume,
            ),
            IconButton(
              icon: const CircleAvatar(
                backgroundColor: ColorTheme.primary50,
                child: Icon(Icons.library_music_outlined, color: ColorTheme.onPrimary),
              ),
              padding: EdgeInsets.zero,
              onPressed: onOpenSound,
            ),
          ],
        ),

        Row(
          mainAxisSize: MainAxisSize.min,
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
      ],
    );
  }
}
