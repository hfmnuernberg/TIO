import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/widgets/flash_cards/tip_of_the_day.dart';
import 'package:tiomusic/pages/projects_page/edit_projects_bar.dart';
import 'package:tiomusic/pages/projects_page/editable_project_list.dart';
import 'package:tiomusic/pages/projects_page/project_list.dart';

class ProjectsList extends StatelessWidget {
  const ProjectsList({
    super.key,
    required this.editProjectsKey,
    required this.isEditing,
    required this.onToggleEditing,
    required this.onAddProject,
    required this.onReorder,
    required this.onDelete,
    required this.onGoToProject,
  });

  final GlobalKey editProjectsKey;
  final bool isEditing;
  final VoidCallback onToggleEditing;
  final VoidCallback onAddProject;
  final Future<void> Function(int oldIndex, int newIndex) onReorder;
  final Future<void> Function(int index) onDelete;
  final Future<void> Function(Project project, bool withoutRealProject) onGoToProject;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverToBoxAdapter(
          child: Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 0), child: const TipOfTheDay()),
        ),
      ],
      body: Consumer<ProjectLibrary>(
        builder: (context, projectLibrary, child) => Stack(
          children: [
            if (projectLibrary.projects.isEmpty)
              Padding(
                padding: const EdgeInsets.all(40),
                child: Text(l10n.projectsNoProjects, style: const TextStyle(color: Colors.white, fontSize: 42)),
              )
            else
              Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Material(
                  color: ColorTheme.primaryContainer,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
                        child: Center(
                          child: Text(
                            l10n.projectsTitle,
                            style: const TextStyle(color: ColorTheme.primary, fontSize: TIOMusicParams.titleFontSize),
                          ),
                        ),
                      ),
                      Expanded(
                        child: isEditing
                            ? EditableProjectList(onDelete: onDelete, onReorder: onReorder)
                            : ProjectList(onGoToProject: onGoToProject),
                      ),
                    ],
                  ),
                ),
              ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.only(bottom: TIOMusicParams.smallSpaceAboveList + 2),
                child: EditProjectsBar(
                  key: editProjectsKey,
                  isEditing: isEditing,
                  onAddProject: onAddProject,
                  onToggleEditing: onToggleEditing,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
