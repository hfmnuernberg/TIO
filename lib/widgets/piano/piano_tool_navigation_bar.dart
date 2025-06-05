import 'package:flutter/material.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/util/util_functions.dart';
import 'package:tiomusic/widgets/piano/piano_navigation_bar.dart';

class PianoToolNavigationBar extends StatelessWidget {
  final Project project;
  final ProjectBlock toolBlock;
  final GlobalKey keyOctaveSwitch;
  final GlobalKey keySettings;

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
    required this.keyOctaveSwitch,
    required this.keySettings,
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
      keyOctaveSwitch: keyOctaveSwitch,
      keySettings: keySettings,
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
