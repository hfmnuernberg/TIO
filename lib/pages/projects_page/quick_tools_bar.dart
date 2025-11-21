import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/pages/projects_page/quick_tool_button.dart';

class QuickToolsBar extends StatelessWidget {
  final void Function(BlockType) onQuickToolTapped;

  const QuickToolsBar({super.key, required this.onQuickToolTapped});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final blockTypes = getBlockTypeInfos(l10n);

    return Container(
      padding: const EdgeInsets.only(top: TIOMusicParams.edgeInset, bottom: TIOMusicParams.edgeInset),
      color: ColorTheme.surface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              QuickToolButton(
                icon: blockTypes[BlockType.metronome]!.icon,
                label: l10n.metronome,
                onTap: () => onQuickToolTapped(BlockType.metronome),
              ),
              QuickToolButton(
                icon: blockTypes[BlockType.mediaPlayer]!.icon,
                label: l10n.mediaPlayer,
                onTap: () => onQuickToolTapped(BlockType.mediaPlayer),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              QuickToolButton(
                icon: blockTypes[BlockType.tuner]!.icon,
                label: l10n.tuner,
                onTap: () => onQuickToolTapped(BlockType.tuner),
              ),
              QuickToolButton(
                icon: blockTypes[BlockType.piano]!.icon,
                label: l10n.piano,
                onTap: () => onQuickToolTapped(BlockType.piano),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
