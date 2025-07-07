import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/widgets/piano/piano_settings_button_group.dart';
import 'package:tiomusic/widgets/tio_icon_button.dart';

class PianoNavigationBar extends StatelessWidget {
  final GlobalKey keyOctaveSwitch;
  final GlobalKey keySettings;
  final bool isHolding;
  final Widget? prevToolIcon;
  final Widget? nextToolIcon;
  final Widget? toolOfSameTypeIcon;

  final VoidCallback? onPrevTool;
  final VoidCallback? onNextTool;
  final VoidCallback? onPrevToolOfSameType;
  final VoidCallback? onNextToolOfSameType;

  final VoidCallback onOctaveDown;
  final VoidCallback onToneDown;
  final VoidCallback onOctaveUp;
  final VoidCallback onToneUp;

  final VoidCallback onOpenPitch;
  final VoidCallback onOpenVolume;
  final VoidCallback onOpenSound;

  final Function(bool isHolding) onSetHolding;

  const PianoNavigationBar({
    super.key,
    required this.keyOctaveSwitch,
    required this.keySettings,
    required this.isHolding,
    this.prevToolIcon,
    this.nextToolIcon,
    this.toolOfSameTypeIcon,
    this.onPrevTool,
    this.onNextTool,
    this.onPrevToolOfSameType,
    this.onNextToolOfSameType,
    required this.onOctaveDown,
    required this.onToneDown,
    required this.onOctaveUp,
    required this.onToneUp,
    required this.onOpenPitch,
    required this.onOpenVolume,
    required this.onOpenSound,
    required this.onSetHolding,
  });

  @override
  Widget build(BuildContext context) {
    final prevToolExists = onPrevTool != null && prevToolIcon != null;
    final nextToolExists = onNextTool != null && nextToolIcon != null;
    final prevToolOfSameTypeExists =
        onPrevToolOfSameType != null && toolOfSameTypeIcon != null && toolOfSameTypeIcon != prevToolIcon;
    final nextToolOfSameTypeExists =
        onNextToolOfSameType != null && toolOfSameTypeIcon != null && toolOfSameTypeIcon != nextToolIcon;

    return Column(
      children: [
        Row(
          children: [
            ToolNavLeftButtonGroup(
              prevToolIcon: prevToolIcon,
              toolOfSameTypeIcon: toolOfSameTypeIcon,
              onPrevTool: onPrevTool,
              onPrevToolOfSameType: onPrevToolOfSameType,
            ),

            ShiftKeysLeftButtonGroup(key: keyOctaveSwitch, onToneDown: onToneDown, onOctaveDown: onOctaveDown),

            if (!prevToolExists) Placeholder(),
            if (!prevToolOfSameTypeExists) Placeholder(),

            PianoSettingsButtonGroup(
              key: keySettings,
              onOpenPitch: onOpenPitch,
              onOpenVolume: onOpenVolume,
              onOpenSound: onOpenSound,
              isHolding: isHolding,
              onSetHolding: onSetHolding,
            ),

            if (!nextToolOfSameTypeExists) Placeholder(),
            if (!nextToolExists) Placeholder(),

            ShiftKeysRightButtonGroup(onToneUp: onToneUp, onOctaveUp: onOctaveUp),

            ToolNavRightButtonGroup(
              nextToolIcon: nextToolIcon,
              toolOfSameTypeIcon: toolOfSameTypeIcon,
              onNextTool: onNextTool,
              onNextToolOfSameType: onNextToolOfSameType,
            ),
          ],
        ),

        StyledBottomBar(
          prevToolExists: prevToolExists,
          nextToolExists: nextToolExists,
          prevToolOfSameTypeExists: prevToolOfSameTypeExists,
          nextToolOfSameTypeExists: nextToolOfSameTypeExists,
        ),
      ],
    );
  }
}

class StyledBottomBar extends StatelessWidget {
  final bool prevToolExists;
  final bool nextToolExists;
  final bool prevToolOfSameTypeExists;
  final bool nextToolOfSameTypeExists;

  const StyledBottomBar({
    super.key,
    required this.prevToolExists,
    required this.nextToolExists,
    required this.prevToolOfSameTypeExists,
    required this.nextToolOfSameTypeExists,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      decoration: BoxDecoration(
        color: ColorTheme.primaryFixedDim,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(prevToolExists || prevToolOfSameTypeExists ? 20 : 0),
          topRight: Radius.circular(nextToolExists || nextToolOfSameTypeExists ? 20 : 0),
        ),
      ),
    );
  }
}

class ToolNavLeftButtonGroup extends StatelessWidget {
  final Widget? prevToolIcon;
  final Widget? toolOfSameTypeIcon;

  final VoidCallback? onPrevTool;
  final VoidCallback? onPrevToolOfSameType;

  const ToolNavLeftButtonGroup({
    super.key,
    required this.prevToolIcon,
    required this.toolOfSameTypeIcon,
    required this.onPrevTool,
    required this.onPrevToolOfSameType,
  });

  @override
  Widget build(BuildContext context) {
    final prevToolExists = onPrevTool != null && prevToolIcon != null;
    final prevToolOfSameTypeExists =
        onPrevToolOfSameType != null && toolOfSameTypeIcon != null && toolOfSameTypeIcon != prevToolIcon;

    return Row(
      children: [
        if (prevToolExists)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: TioIconButton.xs(icon: prevToolIcon!, tooltip: context.l10n.toolGoToPrev, onPressed: onPrevTool),
          ),

        if (prevToolOfSameTypeExists)
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: TioIconButton.xs(
              icon: toolOfSameTypeIcon!,
              tooltip: context.l10n.toolGoToPrevOfSameType,
              onPressed: onPrevToolOfSameType,
            ),
          ),
      ],
    );
  }
}

class ToolNavRightButtonGroup extends StatelessWidget {
  final Widget? nextToolIcon;
  final Widget? toolOfSameTypeIcon;

  final VoidCallback? onNextTool;
  final VoidCallback? onNextToolOfSameType;

  const ToolNavRightButtonGroup({
    super.key,
    required this.nextToolIcon,
    required this.toolOfSameTypeIcon,
    required this.onNextTool,
    required this.onNextToolOfSameType,
  });

  @override
  Widget build(BuildContext context) {
    final nextToolExists = onNextTool != null && nextToolIcon != null;
    final nextToolOfSameTypeExists =
        onNextToolOfSameType != null && toolOfSameTypeIcon != null && toolOfSameTypeIcon != nextToolIcon;

    return Row(
      children: [
        if (nextToolOfSameTypeExists)
          Padding(
            padding: EdgeInsets.only(left: 12),
            child: TioIconButton.xs(
              icon: toolOfSameTypeIcon!,
              tooltip: context.l10n.toolGoToNextOfSameType,
              onPressed: onNextToolOfSameType,
            ),
          ),
        if (nextToolExists)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: TioIconButton.xs(icon: nextToolIcon!, tooltip: context.l10n.toolGoToNext, onPressed: onNextTool),
          ),
      ],
    );
  }
}

class Placeholder extends StatelessWidget {
  const Placeholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: ColorTheme.primaryFixedDim),
      height: 52,
      padding: const EdgeInsets.only(top: 10),
      child: const SizedBox(width: 50),
    );
  }
}

class ShiftKeysLeftButtonGroup extends StatelessWidget {
  final VoidCallback onToneDown;
  final VoidCallback onOctaveDown;

  const ShiftKeysLeftButtonGroup({super.key, required this.onToneDown, required this.onOctaveDown});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: const BoxDecoration(
          color: ColorTheme.primaryFixedDim,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20)),
        ),
        height: 52,
        padding: const EdgeInsets.only(top: 10),
        child: Row(
          children: [
            ShiftKeyButton(icon: Icons.keyboard_double_arrow_left, onPressed: onOctaveDown),
            ShiftKeyButton(icon: Icons.keyboard_arrow_left, onPressed: onToneDown),
          ],
        ),
      ),
    );
  }
}

class ShiftKeysRightButtonGroup extends StatelessWidget {
  final VoidCallback onToneUp;
  final VoidCallback onOctaveUp;

  const ShiftKeysRightButtonGroup({super.key, required this.onToneUp, required this.onOctaveUp});

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
            ShiftKeyButton(icon: Icons.keyboard_arrow_right, onPressed: onToneUp),
            ShiftKeyButton(icon: Icons.keyboard_double_arrow_right, onPressed: onOctaveUp),
          ],
        ),
      ),
    );
  }
}

class ShiftKeyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const ShiftKeyButton({super.key, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(icon: Icon(icon, color: ColorTheme.primary), padding: EdgeInsets.zero, onPressed: onPressed);
  }
}
