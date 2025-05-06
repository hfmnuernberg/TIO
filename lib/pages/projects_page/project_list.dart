import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/services/file_system.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/widgets/card_list_tile.dart';

class ProjectList extends StatelessWidget {
  final FileSystem fs;
  final ProjectLibrary projectLibrary;
  final void Function(Project project, bool withoutProject) onGoToProject;
  final void Function(int index) onDeleteProject;

  const ProjectList({
    super.key,
    required this.fs,
    required this.projectLibrary,
    required this.onGoToProject,
    required this.onDeleteProject,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ListView.builder(
      itemCount: projectLibrary.projects.length,
      itemBuilder: (context, idx) {
        return CardListTile(
          title: projectLibrary.projects[idx].title,
          subtitle: l10n.formatDateAndTime(projectLibrary.projects[idx].timeLastModified),
          trailingIcon: IconButton(
            tooltip: l10n.projectDetails,
            icon: const Icon(Icons.arrow_forward),
            color: ColorTheme.primaryFixedDim,
            onPressed: () => onGoToProject(projectLibrary.projects[idx], false),
          ),
          menuIconOne: IconButton(
            tooltip: l10n.projectDelete,
            icon: const Icon(Icons.delete_outlined),
            color: ColorTheme.surfaceTint,
            onPressed: () => onDeleteProject(idx),
          ),
          leadingPicture:
              projectLibrary.projects[idx].thumbnailPath.isEmpty
                  ? const AssetImage(TIOMusicParams.tiomusicIconPath)
                  : FileImage(File(fs.toAbsoluteFilePath(projectLibrary.projects[idx].thumbnailPath))),
          onTapFunction: () => onGoToProject(projectLibrary.projects[idx], false),
        );
      },
    );
  }
}
