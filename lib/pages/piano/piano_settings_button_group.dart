import 'package:flutter/material.dart';
import 'package:tiomusic/util/color_constants.dart';

class PianoSettingsButtonGroup extends StatelessWidget {
  final VoidCallback onOpenPitch;
  final VoidCallback onOpenVolume;
  final VoidCallback onOpenSound;

  const PianoSettingsButtonGroup({
    super.key,
    required this.onOpenPitch,
    required this.onOpenVolume,
    required this.onOpenSound,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: ColorTheme.primaryFixedDim),
      height: 52,
      padding: const EdgeInsets.only(top: 10),
      child: Row(
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
    );
  }
}
