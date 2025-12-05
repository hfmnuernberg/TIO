import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants/piano_constants.dart';

class PianoSettingsButtonGroup extends StatelessWidget {
  final bool isHolding;
  final VoidCallback onOpenPitch;
  final VoidCallback onOpenVolume;
  final VoidCallback onOpenSound;
  final VoidCallback? onToggleHold;

  const PianoSettingsButtonGroup({
    super.key,
    required this.isHolding,
    required this.onOpenPitch,
    required this.onOpenVolume,
    required this.onOpenSound,
    this.onToggleHold,
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
            icon: CircleAvatar(
              backgroundColor: onToggleHold == null
                  ? ColorTheme.secondary.withValues(alpha: 0.3)
                  : (isHolding ? ColorTheme.tertiary : ColorTheme.primary50),
              child: SvgPicture.asset(
                PianoParams.pedalIcon,
                colorFilter: ColorFilter.mode(ColorTheme.onPrimary, BlendMode.srcIn),
              ),
            ),
            padding: EdgeInsets.zero,
            onPressed: onToggleHold,
          ),
          SizedBox(height: 24, child: VerticalDivider(width: 10, thickness: 1, color: ColorTheme.onPrimary)),
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
