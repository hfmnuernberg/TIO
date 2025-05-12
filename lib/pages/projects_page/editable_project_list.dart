import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/services/file_system.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/widgets/card_list_tile.dart';

class EditableProjectList extends StatelessWidget {
  final ProjectLibrary projectLibrary;
  final void Function(int index) onDelete;
  final Future<void> Function(int newIndex, int oldIndex) onReorder;

  const EditableProjectList({super.key, required this.projectLibrary, required this.onDelete, required this.onReorder});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fs = context.read<FileSystem>();

    return ReorderableListView.builder(
      padding: const EdgeInsets.only(bottom: 120),
      itemCount: projectLibrary.projects.length,
      onReorder: onReorder,
      itemBuilder: (context, index) {
        final project = projectLibrary.projects[index];

        return Container(
          key: ValueKey(project.id),
          child: CardListTile(
            title: project.title,
            subtitle: l10n.formatDateAndTime(project.timeLastModified),
            trailingIcon: IconButton(
              tooltip: l10n.commonReorder,
              icon: ReorderableDragStartListener(index: index, child: const Icon(Icons.drag_handle)),
              color: ColorTheme.primaryFixedDim,
              onPressed: () {},
            ),
            menuIconOne: IconButton(
              tooltip: l10n.projectDelete,
              icon: const Icon(Icons.delete_outlined),
              color: ColorTheme.tertiary,
              onPressed: () => onDelete(index),
            ),
            leadingPicture:
                project.thumbnailPath.isEmpty
                    ? AssetImage(TIOMusicParams.tiomusicIconPath)
                    : FileImage(File(fs.toAbsoluteFilePath(project.thumbnailPath))),
            onTapFunction: () {},
          ),
        );
      },
    );
  }
}
