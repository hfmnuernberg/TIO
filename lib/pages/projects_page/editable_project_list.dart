import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/services/file_system.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/widgets/card_list_tile.dart';

class EditableProjectList extends StatelessWidget {
  final ProjectLibrary projectLibrary;
  final void Function(int index) onDelete;
  final Future<void> Function(int oldIndex, int newIndex) onReorder;

  const EditableProjectList({super.key, required this.projectLibrary, required this.onDelete, required this.onReorder});

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.fromLTRB(0, 18, 0, 12),
      itemCount: projectLibrary.projects.length + 1,
      onReorder: (oldIndex, newIndex) async {
        if (oldIndex == 0 || newIndex == 0) return;

        final projectOldIndex = oldIndex - 1;
        final projectNewIndex = newIndex - 1;

        await onReorder(projectOldIndex, projectNewIndex);
      },
      proxyDecorator: (child, index, animation) {
        if (index == 0) return child;

        final projectIndex = index - 1;
        final project = projectLibrary.projects[projectIndex];
        final isFirstProject = projectIndex == 0;
        final isLastProject = projectIndex == projectLibrary.projects.length - 1;

        return Material(
          elevation: 6,
          clipBehavior: Clip.antiAlias,
          child: _EditableProjectListItem(
            project: project,
            index: projectIndex,
            isFirst: isFirstProject,
            isLast: isLastProject,
            onDelete: onDelete,
            showBackground: false,
          ),
        );
      },
      itemBuilder: (context, index) {
        if (index == 0) {
          return const KeyedSubtree(key: ValueKey('projects-header'), child: _ProjectsHeader());
        }

        final projectIndex = index - 1;
        final project = projectLibrary.projects[projectIndex];
        final isFirstProject = projectIndex == 0;
        final isLastProject = projectIndex == projectLibrary.projects.length - 1;

        return _EditableProjectListItem(
          key: ValueKey(project.id),
          project: project,
          index: projectIndex,
          isFirst: isFirstProject,
          isLast: isLastProject,
          onDelete: onDelete,
        );
      },
    );
  }
}

class _ProjectsHeader extends StatelessWidget {
  const _ProjectsHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: ColorTheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
          child: Center(
            child: Text(
              context.l10n.projectsTitle,
              style: const TextStyle(color: ColorTheme.primary, fontSize: TIOMusicParams.titleFontSize),
            ),
          ),
        ),
      ),
    );
  }
}

class _EditableProjectListItem extends StatelessWidget {
  final Project project;
  final int index;
  final bool isFirst;
  final bool isLast;
  final void Function(int index) onDelete;
  final bool showBackground;

  const _EditableProjectListItem({
    super.key,
    required this.project,
    required this.index,
    required this.isFirst,
    required this.isLast,
    required this.onDelete,
    this.showBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fs = context.read<FileSystem>();

    final tile = CardListTile(
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
          : FileImage(File(fs.toAbsoluteFilePath(project.thumbnailPath))),
      onTapFunction: () {},
    );

    if (!showBackground) {
      return tile;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: ColorTheme.primaryContainer,
        child: Padding(padding: EdgeInsets.fromLTRB(12, isFirst ? 0 : 4, 12, isLast ? 12 : 4), child: tile),
      ),
    );
  }
}
