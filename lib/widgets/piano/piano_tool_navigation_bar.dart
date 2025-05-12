import 'package:flutter/material.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/util/util_functions.dart';
import 'package:tiomusic/widgets/small_icon_button.dart';

class PianoToolNavigationBar extends StatelessWidget {
  final Widget pianoSettings;
  final Project project;
  final ProjectBlock toolBlock;

  const PianoToolNavigationBar({
    super.key,
    required this.pianoSettings,
    required this.project,
    required this.toolBlock,
  });

  @override
  Widget build(BuildContext context) {
    if (project.blocks.length == 1) return pianoSettings;

    final tools = project.blocks;
    final index = tools.indexOf(toolBlock);

    final sameTools = tools.where((block) => block.kind == toolBlock.kind).toList();
    final sameToolsIndex = sameTools.indexOf(toolBlock);

    Future<void> replaceTool(ProjectBlock tool, {bool ltr = false}) =>
        goToTool(context, project, tool, replace: true, transitionLeftToRight: ltr);

    return _PianoToolNavigationBar(
      pianoSettings: pianoSettings,
      prevToolIcon: index == 0 ? null : tools[(index - 1)].icon,
      nextToolIcon: index < tools.length - 1 ? tools[index + 1].icon : null,
      toolOfSameTypeIcon: toolBlock.icon,
      onPrevTool: index == 0 ? null : () => replaceTool(tools[(index - 1)], ltr: true),
      onNextTool: index < tools.length - 1 ? () => replaceTool(tools[index + 1]) : null,
      onPrevToolOfSameType: sameToolsIndex == 0 ? null : () => replaceTool(sameTools[(sameToolsIndex - 1)], ltr: true),
      onNextToolOfSameType:
          sameToolsIndex < sameTools.length - 1 ? () => replaceTool(sameTools[sameToolsIndex + 1]) : null,
    );
  }
}

class _PianoToolNavigationBar extends StatelessWidget {
  final Widget pianoSettings;
  final Widget? prevToolIcon;
  final Widget? nextToolIcon;
  final Widget? toolOfSameTypeIcon;
  final VoidCallback? onPrevTool;
  final VoidCallback? onNextTool;
  final VoidCallback? onPrevToolOfSameType;
  final VoidCallback? onNextToolOfSameType;

  const _PianoToolNavigationBar({
    required this.pianoSettings,
    this.prevToolIcon,
    this.nextToolIcon,
    this.toolOfSameTypeIcon,
    this.onPrevTool,
    this.onNextTool,
    this.onPrevToolOfSameType,
    this.onNextToolOfSameType,
  });

  @override
  Widget build(BuildContext context) {
    const smallIconButtonWidth = 56.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (onPrevTool != null && prevToolIcon != null)
              SmallIconButton(icon: prevToolIcon!, onPressed: onPrevTool)
            else
              const SizedBox(width: smallIconButtonWidth),
            if (onPrevToolOfSameType != null && toolOfSameTypeIcon != null && toolOfSameTypeIcon != prevToolIcon)
              SmallIconButton(icon: toolOfSameTypeIcon!, onPressed: onPrevToolOfSameType)
            else
              const SizedBox(width: smallIconButtonWidth),
          ],
        ),
        Expanded(child: pianoSettings),
        Row(
          children: [
            if (onNextToolOfSameType != null && toolOfSameTypeIcon != null && toolOfSameTypeIcon != nextToolIcon)
              SmallIconButton(icon: toolOfSameTypeIcon!, onPressed: onNextToolOfSameType)
            else
              const SizedBox(width: smallIconButtonWidth),
            if (onNextTool != null && nextToolIcon != null)
              SmallIconButton(icon: nextToolIcon!, onPressed: onNextTool)
            else
              const SizedBox(width: smallIconButtonWidth),
          ],
        ),
      ],
    );
  }
}
