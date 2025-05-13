import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/util/util_functions.dart';
import 'package:tiomusic/widgets/card_list_tile.dart';

class ToolList extends StatelessWidget {
  final Project project;
  final void Function(ProjectBlock block) onOpenTool;

  const ToolList({super.key, required this.project, required this.onOpenTool});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(0, TIOMusicParams.smallSpaceAboveList + 2, 0, 120),
      itemCount: project.blocks.length,
      itemBuilder: (context, index) {
        final block = project.blocks[index];

        return CardListTile(
          title: block.title,
          subtitle: formatSettingValues(block.getSettingsFormatted(context.l10n)),
          leadingPicture: circleToolIcon(block.icon),
          trailingIcon: IconButton(
            onPressed: () => onOpenTool(block),
            icon: const Icon(Icons.arrow_forward),
            color: ColorTheme.primaryFixedDim,
          ),
          onTapFunction: () => onOpenTool(block),
        );
      },
    );
  }
}
