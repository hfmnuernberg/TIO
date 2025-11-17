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
  final void Function(int index) onDelete;
  final Future<void> Function(int oldIndex, int newIndex) onReorder;

  const EditableProjectList({super.key, required this.onDelete, required this.onReorder});

  @override
  Widget build(BuildContext context) {
    final ProjectLibrary projectLibrary = context.read<ProjectLibrary>();

    return ReorderableListView.builder(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 12),
      itemCount: projectLibrary.projects.length,
      onReorder: (oldIndex, newIndex) async => onReorder(oldIndex, newIndex),
      itemBuilder: (context, index) {
        final project = projectLibrary.projects[index];
        final l10n = context.l10n;

        return Container(
          key: ValueKey(project.id),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
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
              leadingPicture: project.thumbnailPath.isEmpty
                  ? AssetImage(TIOMusicParams.tiomusicIconPath)
                  : FileImage(File(context.read<FileSystem>().toAbsoluteFilePath(project.thumbnailPath))),
              onTapFunction: () {},
            ),
          ),
        );
      },
    );
  }
}
