import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/util_functions.dart';
import 'package:tiomusic/widgets/tio_icon_button.dart';

// TODO: Check what can derived from context, etc. to minimize params
// TODO: When only one piano block, set styling for edges > needs to be done in parent!
// TODO: Extract inner settings widget to a separate widget?
// TODO: Extract piano chevrons-navigation into a separate widget?
// TODO: clean up

class PianoToolNavigationBar extends StatelessWidget {
  final Project project;
  final ProjectBlock toolBlock;
  final VoidCallback onOctaveDown;
  final VoidCallback onToneDown;
  final VoidCallback onOctaveUp;
  final VoidCallback onToneUp;
  final Key? keyOctaveSwitch;
  final Key? keySettings;
  final Widget child;

  const PianoToolNavigationBar({
    super.key,
    required this.project,
    required this.toolBlock,
    required this.onOctaveDown,
    required this.onToneDown,
    required this.onOctaveUp,
    required this.onToneUp,
    this.keyOctaveSwitch,
    this.keySettings,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final tools = project.blocks;
    final index = tools.indexOf(toolBlock);

    final sameTools = tools.where((block) => block.kind == toolBlock.kind).toList();
    final sameToolsIndex = sameTools.indexOf(toolBlock);

    Future<void> replaceTool(ProjectBlock tool, {bool ltr = false}) =>
        goToTool(context, project, tool, replace: true, transitionLeftToRight: ltr);

    return _PianoToolNavigationBar(
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
      keyOctaveSwitch: keyOctaveSwitch,
      keySettings: keySettings,
      child: child,
    );
  }
}

class _PianoToolNavigationBar extends StatelessWidget {
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
  final Key? keyOctaveSwitch;
  final Key? keySettings;
  final Widget child;

  const _PianoToolNavigationBar({
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
    this.keyOctaveSwitch,
    this.keySettings,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final prevToolExists = onPrevTool != null && prevToolIcon != null;
    final nextToolExists = onNextTool != null && nextToolIcon != null;
    final prevToolOfSameTypeExists =
        onPrevToolOfSameType != null && toolOfSameTypeIcon != null && toolOfSameTypeIcon != prevToolIcon;
    final nextToolOfSameTypeExists =
        onNextToolOfSameType != null && toolOfSameTypeIcon != null && toolOfSameTypeIcon != nextToolIcon;

    return Row(
      children: [
        Row(
          children: [
            if (prevToolExists)
              Padding(
                padding: EdgeInsets.only(right: 12),
                child: TioIconButton.xs(icon: prevToolIcon!, tooltip: l10n.toolGoToPrev, onPressed: onPrevTool),
              ),

            if (prevToolOfSameTypeExists)
              Padding(
                padding: EdgeInsets.only(right: 12),
                child: TioIconButton.xs(
                  icon: toolOfSameTypeIcon!,
                  tooltip: l10n.toolGoToPrevOfSameType,
                  onPressed: onPrevToolOfSameType,
                ),
              ),
          ],
        ),

        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: ColorTheme.primaryFixedDim,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(20)),
            ),
            height: 52,
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              key: keyOctaveSwitch,
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

        if (!prevToolExists)
          Container(
            decoration: const BoxDecoration(color: ColorTheme.primaryFixedDim),
            height: 52,
            padding: const EdgeInsets.only(top: 10),
            child: const SizedBox(width: 50),
          ),
        if (!prevToolOfSameTypeExists)
          Container(
            decoration: const BoxDecoration(color: ColorTheme.primaryFixedDim),
            height: 52,
            padding: const EdgeInsets.only(top: 10),
            child: const SizedBox(width: 50),
          ),

        child,

        if (!nextToolOfSameTypeExists)
          Container(
            decoration: const BoxDecoration(color: ColorTheme.primaryFixedDim),
            height: 52,
            padding: const EdgeInsets.only(top: 10),
            child: const SizedBox(width: 50),
          ),
        if (!nextToolExists)
          Container(
            decoration: const BoxDecoration(color: ColorTheme.primaryFixedDim),
            height: 52,
            padding: const EdgeInsets.only(top: 10),
            child: const SizedBox(width: 50),
          ),

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

        Row(
          children: [
            if (nextToolOfSameTypeExists)
              Padding(
                padding: EdgeInsets.only(left: 12),
                child: TioIconButton.xs(
                  icon: toolOfSameTypeIcon!,
                  tooltip: l10n.toolGoToNextOfSameType,
                  onPressed: onNextToolOfSameType,
                ),
              ),
            if (nextToolExists)
              Padding(
                padding: EdgeInsets.only(left: 12),
                child: TioIconButton.xs(icon: nextToolIcon!, tooltip: l10n.toolGoToNext, onPressed: onNextTool),
              ),
          ],
        ),
      ],
    );
  }
}
