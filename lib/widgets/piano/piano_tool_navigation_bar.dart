import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/util_functions.dart';
import 'package:tiomusic/widgets/tio_icon_button.dart';

// TODO: Check what can derived from context, etc. to minimize params
// TODO: Extract inner settings widget to a separate widget
// TODO: Extract piano chevrons-navigation into a separate widget
// TODO: clean up

class PianoToolNavigationBar extends StatelessWidget {
  // final Widget pianoSettings;
  final Project project;
  final ProjectBlock toolBlock;
  final VoidCallback onOctaveDown;
  final VoidCallback onToneDown;
  final VoidCallback onOctaveUp;
  final VoidCallback onToneUp;
  final VoidCallback onOpenPitch;
  final VoidCallback onOpenVolume;
  final VoidCallback onOpenSound;
  final Key? keyOctaveSwitch;
  final Key? keySettings;

  const PianoToolNavigationBar({
    super.key,
    // required this.pianoSettings,
    required this.project,
    required this.toolBlock,
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
    // if (project.blocks.length == 1) return pianoSettings;

    final tools = project.blocks;
    final index = tools.indexOf(toolBlock);

    final sameTools = tools.where((block) => block.kind == toolBlock.kind).toList();
    final sameToolsIndex = sameTools.indexOf(toolBlock);

    Future<void> replaceTool(ProjectBlock tool, {bool ltr = false}) =>
        goToTool(context, project, tool, replace: true, transitionLeftToRight: ltr);

    return _PianoToolNavigationBar(
      // pianoSettings: pianoSettings,
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
      keyOctaveSwitch: keyOctaveSwitch,
      keySettings: keySettings,
    );
  }
}

class _PianoToolNavigationBar extends StatelessWidget {
  // final Widget pianoSettings;
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
  final Key? keyOctaveSwitch;
  final Key? keySettings;

  const _PianoToolNavigationBar({
    // required this.pianoSettings,
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
    this.keyOctaveSwitch,
    this.keySettings,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Row(
      children: [
        Row(
          children: [
            if (onPrevTool != null && prevToolIcon != null)
              Padding(
                padding: EdgeInsets.only(right: 12),
                child: TioIconButton.xs(icon: prevToolIcon!, tooltip: l10n.toolGoToPrev, onPressed: onPrevTool),
              ),

            if (onPrevToolOfSameType != null && toolOfSameTypeIcon != null && toolOfSameTypeIcon != prevToolIcon)
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

        // Expanded(child: pianoSettings),
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
          ),
        ),

        Container(
          decoration: const BoxDecoration(color: ColorTheme.primaryFixedDim),
          height: 52,
          padding: const EdgeInsets.only(top: 10),
          child: Row(
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
        ),

        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: ColorTheme.primaryFixedDim,
              borderRadius: BorderRadius.only(topRight: Radius.circular(20)),
            ),
            height: 52,
            padding: const EdgeInsets.only(top: 10),
            child: Row(
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
          ),
        ),

        Row(
          children: [
            if (onNextToolOfSameType != null && toolOfSameTypeIcon != null && toolOfSameTypeIcon != nextToolIcon)
              Padding(
                padding: EdgeInsets.only(left: 12),
                child: TioIconButton.xs(
                  icon: toolOfSameTypeIcon!,
                  tooltip: l10n.toolGoToNextOfSameType,
                  onPressed: onNextToolOfSameType,
                ),
              ),
            if (onNextTool != null && nextToolIcon != null)
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
