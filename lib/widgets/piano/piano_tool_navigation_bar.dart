import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/util_functions.dart';
import 'package:tiomusic/widgets/piano/piano_settings_button_group.dart';
import 'package:tiomusic/widgets/tio_icon_button.dart';

class PianoToolNavigationBar extends StatelessWidget {
  final Project project;
  final ProjectBlock toolBlock;

  final VoidCallback onOctaveDown;
  final VoidCallback onToneDown;
  final VoidCallback onOctaveUp;
  final VoidCallback onToneUp;

  final VoidCallback onOpenPitch;
  final VoidCallback onOpenVolume;
  final VoidCallback onOpenSound;

  const PianoToolNavigationBar({
    super.key,
    required this.project,
    required this.toolBlock,
    required this.onOctaveDown,
    required this.onToneDown,
    required this.onOctaveUp,
    required this.onToneUp,
    required this.onOpenPitch,
    required this.onOpenVolume,
    required this.onOpenSound,
  });

  @override
  Widget build(BuildContext context) {
    final tools = project.blocks;
    final index = tools.indexOf(toolBlock);

    final sameTools = tools.where((block) => block.kind == toolBlock.kind).toList();
    final sameToolsIndex = sameTools.indexOf(toolBlock);

    Future<void> replaceTool(ProjectBlock tool, {bool ltr = false}) =>
        goToTool(context, project, tool, replace: true, transitionLeftToRight: ltr);

    return PianoNavigationBar(
      prevToolIcon: index > 0 ? tools[(index - 1)].icon : null,
      nextToolIcon: index < tools.length - 1 ? tools[index + 1].icon : null,
      toolOfSameTypeIcon: toolBlock.icon,
      onPrevTool: index > 0 ? () => replaceTool(tools[(index - 1)], ltr: true) : null,
      onNextTool: index < tools.length - 1 ? () => replaceTool(tools[index + 1]) : null,
      onPrevToolOfSameType: sameToolsIndex > 0 ? () => replaceTool(sameTools[(sameToolsIndex - 1)], ltr: true) : null,
      onNextToolOfSameType:
          sameToolsIndex < sameTools.length - 1 ? () => replaceTool(sameTools[sameToolsIndex + 1]) : null,
      onOctaveDown: onOctaveDown,
      onToneDown: onToneDown,
      onOctaveUp: onOctaveUp,
      onToneUp: onToneUp,
      onOpenPitch: onOpenPitch,
      onOpenVolume: onOpenVolume,
      onOpenSound: onOpenSound,
    );
  }
}

class PianoNavigationBar extends StatelessWidget {
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

  const PianoNavigationBar({
    super.key,
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

            ShiftKeysLeftButtonGroup(onToneDown: onToneDown, onOctaveDown: onOctaveDown),

            if (!prevToolExists) Placeholder(),
            if (!prevToolOfSameTypeExists) Placeholder(),

            PianoSettingsButtonGroup(onOpenPitch: onOpenPitch, onOpenVolume: onOpenVolume, onOpenSound: onOpenSound),

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
          topLeft: Radius.circular(prevToolExists && prevToolOfSameTypeExists ? 20 : 0),
          topRight: Radius.circular(nextToolExists && nextToolOfSameTypeExists ? 20 : 0),
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
            padding: EdgeInsets.only(right: 12),
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
            padding: EdgeInsets.only(left: 12),
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
