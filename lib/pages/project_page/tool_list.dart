import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/image_block.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/services/file_system.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants/constants.dart';
import 'package:tiomusic/util/util_functions.dart';
import 'package:tiomusic/widgets/card_list_tile.dart';

class ToolList extends StatelessWidget {
  final Project project;
  final void Function(ProjectBlock block) onOpenTool;

  const ToolList({super.key, required this.project, required this.onOpenTool});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.l10n.projectToolList,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(0, TIOMusicParams.smallSpaceAboveList + 2, 0, 120),
        itemCount: project.blocks.length,
        itemBuilder: (context, index) {
          final block = project.blocks[index];
          final fs = context.read<FileSystem>();
          final Object subtitle = (block is ImageBlock && block.relativePath.isNotEmpty)
              ? FileImage(File(fs.toAbsoluteFilePath(block.relativePath)))
              : formatSettingValues(block.getSettingsFormatted(context.l10n));

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: CardListTile(
              title: block.title,
              subtitle: subtitle,
              leadingPicture: circleToolIcon(block.icon),
              trailingIcon: IconButton(
                onPressed: () => onOpenTool(block),
                icon: const Icon(Icons.arrow_forward),
                color: ColorTheme.primaryFixedDim,
              ),
              onTapFunction: () => onOpenTool(block),
            ),
          );
        },
      ),
    );
  }
}
