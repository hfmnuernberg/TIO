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
  final ProjectLibrary projectLibrary;
  final void Function(Project project, bool withoutProject) onGoToProject;

  const ProjectList({super.key, required this.projectLibrary, required this.onGoToProject});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(0, 18, 0, 12),
      itemCount: projectLibrary.projects.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return const _ProjectsHeader();
        }

        final projectIndex = index - 1;
        final project = projectLibrary.projects[projectIndex];
        final isFirstProject = projectIndex == 0;
        final isLastProject = projectIndex == projectLibrary.projects.length - 1;

        return _ProjectListItem(
          project: project,
          isFirst: isFirstProject,
          isLast: isLastProject,
          onGoToProject: onGoToProject,
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

class _ProjectListItem extends StatelessWidget {
  final Project project;
  final bool isFirst;
  final bool isLast;
  final void Function(Project project, bool withoutProject) onGoToProject;

  const _ProjectListItem({
    required this.project,
    required this.isFirst,
    required this.isLast,
    required this.onGoToProject,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fs = context.read<FileSystem>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: ColorTheme.primaryContainer,
        child: Padding(
          padding: EdgeInsets.fromLTRB(12, isFirst ? 0 : 4, 12, isLast ? 12 : 4),
          child: CardListTile(
            title: project.title,
            subtitle: l10n.formatDateAndTime(project.timeLastModified),
            trailingIcon: IconButton(
              tooltip: l10n.projectDetails,
              icon: const Icon(Icons.arrow_forward),
              color: ColorTheme.primaryFixedDim,
              onPressed: () => onGoToProject(project, false),
            ),
            leadingPicture: project.thumbnailPath.isEmpty
                ? AssetImage(TIOMusicParams.tiomusicIconPath)
                : FileImage(File(fs.toAbsoluteFilePath(project.thumbnailPath))),
            onTapFunction: () => onGoToProject(project, false),
          ),
        ),
      ),
    );
  }
}
