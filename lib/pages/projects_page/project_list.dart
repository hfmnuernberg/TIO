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
    final l10n = context.l10n;
    final fs = context.read<FileSystem>();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        0,
        TIOMusicParams.smallSpaceAboveList + 2,
        0,
        TIOMusicParams.smallSpaceAboveList - 4,
      ),
      itemCount: projectLibrary.projects.length,
      itemBuilder: (context, index) {
        final project = projectLibrary.projects[index];

        final item = Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Material(
            color: ColorTheme.primaryContainer,
            child: Padding(
              padding: EdgeInsets.fromLTRB(8, 0, 8, index == projectLibrary.projects.length - 1 ? 8 : 0),
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

        if (index == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Material(
                  color: ColorTheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 12, 8, 6),
                    child: Center(
                      child: Text(
                        context.l10n.projectsTitle,
                        style: const TextStyle(
                          color: ColorTheme.primary,
                          fontSize: TIOMusicParams.titleFontSize,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              item,
            ],
          );
        }

        return item;
      },
    );
  }
}
