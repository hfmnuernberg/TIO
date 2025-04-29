import 'package:flutter/material.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/util_functions.dart';
import 'package:tiomusic/widgets/small_icon_button.dart';

class ToolNavigationBar extends StatelessWidget {
  final Project project;
  final ProjectBlock toolBlock;

  const ToolNavigationBar({super.key, required this.project, required this.toolBlock});

  @override
  Widget build(BuildContext context) {
    if (project.blocks.length == 1) return const SizedBox();

    final tools = project.blocks;
    final index = tools.indexOf(toolBlock);

    final sameTools = tools.where((block) => block.kind == toolBlock.kind).toList();
    final sameToolsIndex = sameTools.indexOf(toolBlock);

    replaceTool(ProjectBlock tool, {bool ltr = false}) =>
        goToTool(context, project, tool, replace: true, transitionLeftToRight: ltr);

    return _ToolNavigationBar(
      toolIndex: index,
      toolCount: tools.length,
      prevToolIcon: index == 0 ? null : tools[(index - 1)].icon,
      nextToolIcon: index < tools.length - 1 ? tools[(index + 1)].icon : null,
      toolOfSameTypeIcon: toolBlock.icon,
      onPrevTool: index == 0 ? null : () => replaceTool(tools[(index - 1)], ltr: true),
      onNextTool: index < tools.length - 1 ? () => replaceTool(tools[(index + 1)]) : null,
      onPrevToolOfNextType: sameToolsIndex == 0 ? null : () => replaceTool(sameTools[(sameToolsIndex - 1)], ltr: true),
      onNextToolOfSameType:
          sameToolsIndex < sameTools.length - 1 ? () => replaceTool(sameTools[(sameToolsIndex + 1)]) : null,
    );
  }
}

class _ToolNavigationBar extends StatelessWidget {
  final int toolIndex;
  final int toolCount;
  final Widget? prevToolIcon;
  final Widget? nextToolIcon;
  final Widget? toolOfSameTypeIcon;
  final VoidCallback? onPrevTool;
  final VoidCallback? onNextTool;
  final VoidCallback? onPrevToolOfNextType;
  final VoidCallback? onNextToolOfSameType;

  const _ToolNavigationBar({
    required this.toolIndex,
    required this.toolCount,
    this.prevToolIcon,
    this.nextToolIcon,
    this.toolOfSameTypeIcon,
    this.onPrevTool,
    this.onNextTool,
    this.onPrevToolOfNextType,
    this.onNextToolOfSameType,
  });

  @override
  Widget build(BuildContext context) {
    const smallIconButtonWidth = 56.0;
    return BottomAppBar(
      padding: EdgeInsets.symmetric(horizontal: 12),
      color: Colors.transparent,
      height: 78,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (onPrevTool != null && prevToolIcon != null)
                SmallIconButton(icon: prevToolIcon!, onPressed: onPrevTool)
              else
                SizedBox(width: smallIconButtonWidth),
              if (onPrevToolOfNextType != null && toolOfSameTypeIcon != null && toolOfSameTypeIcon != prevToolIcon)
                SmallIconButton(icon: toolOfSameTypeIcon!, onPressed: onPrevToolOfNextType)
              else
                SizedBox(width: smallIconButtonWidth),
            ],
          ),
          Material(
            elevation: 16,
            borderRadius: BorderRadius.circular(800),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  InkWell(
                    onTap: onPrevTool,
                    child: Icon(
                      Icons.arrow_back,
                      color: onPrevTool == null ? ColorTheme.secondaryContainer : ColorTheme.primary80,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text('${toolIndex + 1} / $toolCount', style: TextStyle(color: ColorTheme.primary80, fontSize: 16)),
                  SizedBox(width: 10),
                  InkWell(
                    onTap: onNextTool,
                    child: Icon(
                      Icons.arrow_forward,
                      color: onNextTool == null ? ColorTheme.secondaryContainer : ColorTheme.primary80,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              if (onNextToolOfSameType != null && toolOfSameTypeIcon != null && toolOfSameTypeIcon != nextToolIcon)
                SmallIconButton(icon: toolOfSameTypeIcon!, onPressed: onNextToolOfSameType)
              else
                SizedBox(width: smallIconButtonWidth),
              if (onNextTool != null && nextToolIcon != null)
                SmallIconButton(icon: nextToolIcon!, onPressed: onNextTool)
              else
                SizedBox(width: smallIconButtonWidth),
            ],
          ),
        ],
      ),
    );
  }
}
