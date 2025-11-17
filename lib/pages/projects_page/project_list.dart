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

class ProjectList extends StatelessWidget {
  final void Function(Project project, bool withoutProject) onGoToProject;

  const ProjectList({super.key, required this.onGoToProject});

  @override
  Widget build(BuildContext context) {
    final ProjectLibrary projectLibrary = context.read<ProjectLibrary>();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 12),
      itemCount: projectLibrary.projects.length,
      itemBuilder: (context, index) {
        final project = projectLibrary.projects[index];

        return Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: CardListTile(
            title: project.title,
            subtitle: context.l10n.formatDateAndTime(project.timeLastModified),
            trailingIcon: IconButton(
              tooltip: context.l10n.projectDetails,
              icon: const Icon(Icons.arrow_forward),
              color: ColorTheme.primaryFixedDim,
              onPressed: () => onGoToProject(project, false),
            ),
            leadingPicture: project.thumbnailPath.isEmpty
                ? AssetImage(TIOMusicParams.tiomusicIconPath)
                : FileImage(File(context.read<FileSystem>().toAbsoluteFilePath(project.thumbnailPath))),
            onTapFunction: () => onGoToProject(project, false),
          ),
        );
      },
    );
  }
}
