import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/widgets/card_list_tile.dart';

class ProjectList extends StatelessWidget {
  final ProjectLibrary projectLibrary;
  final List<ImageProvider<Object>> projectThumbnails;
  final void Function(Project project, bool withoutProject) onGoToProject;

  const ProjectList({
    super.key,
    required this.projectLibrary,
    required this.projectThumbnails,
    required this.onGoToProject,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ListView.builder(
      itemCount: projectLibrary.projects.length,
      itemBuilder: (context, index) {
        return CardListTile(
          title: projectLibrary.projects[index].title,
          subtitle: l10n.formatDateAndTime(projectLibrary.projects[index].timeLastModified),
          trailingIcon: IconButton(
            tooltip: l10n.projectDetails,
            icon: const Icon(Icons.arrow_forward),
            color: ColorTheme.primaryFixedDim,
            onPressed: () => onGoToProject(projectLibrary.projects[index], false),
          ),
          leadingPicture: projectThumbnails[index],
          onTapFunction: () => onGoToProject(projectLibrary.projects[index], false),
        );
      },
    );
  }
}
