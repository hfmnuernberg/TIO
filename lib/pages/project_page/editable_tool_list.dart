import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/image_block.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/services/file_system.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants/constants.dart';
import 'package:tiomusic/util/util_functions.dart';
import 'package:tiomusic/widgets/card_list_tile.dart';

class EditableToolList extends StatelessWidget {
  final Project project;
  final Future<void> Function(int oldIndex, int newIndex) onReorder;
  final Future<void> Function(int index) onDeleteBlock;

  const EditableToolList({super.key, required this.project, required this.onReorder, required this.onDeleteBlock});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.l10n.projectToolList,
      child: ReorderableListView.builder(
        padding: const EdgeInsets.fromLTRB(0, TIOMusicParams.smallSpaceAboveList + 2, 0, 120),
        itemCount: project.blocks.length,
        onReorder: onReorder,
        buildDefaultDragHandles: false,
        itemBuilder: (context, index) {
          final l10n = context.l10n;
          final block = project.blocks[index];
          final fs = context.read<FileSystem>();
          final Object subtitle = (block is ImageBlock && block.relativePath.isNotEmpty)
              ? FileImage(File(fs.toAbsoluteFilePath(block.relativePath)))
              : formatSettingValues(block.getSettingsFormatted(l10n));

          return Container(
            key: ValueKey(block.id),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: CardListTile(
                title: block.title,
                subtitle: subtitle,
                leadingPicture: circleToolIcon(block.icon),
                trailingIcon: IconButton(
                  tooltip: l10n.commonReorder,
                  icon: ReorderableDragStartListener(index: index, child: const Icon(Icons.drag_handle)),
                  color: ColorTheme.primaryFixedDim,
                  onPressed: () {},
                ),
                menuIconOne: IconButton(
                  tooltip: l10n.projectDeleteTool,
                  icon: const Icon(Icons.delete_outlined),
                  color: ColorTheme.tertiary,
                  onPressed: () => onDeleteBlock(index),
                ),
                onTapFunction: () {},
              ),
            ),
          );
        },
      ),
    );
  }
}
