import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/image_block.dart';
import 'package:tiomusic/models/blocks/media_player_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/pages/flash_cards/flash_cards_page.dart';
import 'package:tiomusic/pages/info_pages/about_page.dart';
import 'package:tiomusic/pages/info_pages/feedback_page.dart';
import 'package:tiomusic/pages/projects_page/import_project.dart';
import 'package:tiomusic/services/file_references.dart';
import 'package:tiomusic/services/project_repository.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/widgets/confirm_setting_button.dart';

enum ProjectMenuAction {
  about,
  feedback,
  importProject,
  addNew,
  toggleEditingMode,
  deleteAll,
  tutorialStart,
  flashCards,
}

class ProjectsPageSettings extends StatelessWidget {
  const ProjectsPageSettings({
    super.key,
    required this.isEditing,
    required this.onSetEditing,
    required this.onAddNew,
    required this.onShowTutorialAgain,
  });

  final bool isEditing;
  final ValueChanged<bool> onSetEditing;
  final VoidCallback onAddNew;
  final VoidCallback onShowTutorialAgain;

  @override
  Widget build(BuildContext context) {
    return MenuItems(isEditing: isEditing, onSelected: (action) => _handleAction(context, action));
  }

  Future<void> _handleAction(BuildContext context, ProjectMenuAction action) async {
    switch (action) {
      case ProjectMenuAction.about:
        _aboutPage(context);
      case ProjectMenuAction.feedback:
        _feedbackPage(context);
      case ProjectMenuAction.importProject:
        await importProject(context);
      case ProjectMenuAction.addNew:
        onAddNew();
      case ProjectMenuAction.toggleEditingMode:
        onSetEditing(!isEditing);
      case ProjectMenuAction.deleteAll:
        await _deleteAllProjects(context);
      case ProjectMenuAction.tutorialStart:
        onShowTutorialAgain();
      case ProjectMenuAction.flashCards:
        _flashCardsPage(context);
    }
  }

  void _aboutPage(BuildContext context) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => AboutPage()));

  void _feedbackPage(BuildContext context) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FeedbackPage()));

  void _flashCardsPage(BuildContext context) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => FlashCardsPage()));

  Future<void> _deleteAllProjects(BuildContext context) async {
    final confirmed = await _confirmDeleteDialog(context, deleteAll: true);
    if (confirmed != true) return;

    if (!context.mounted) return;

    final library = context.read<ProjectLibrary>();
    final fileReferences = context.read<FileReferences>();

    for (final project in library.projects) {
      for (final block in project.blocks) {
        if (block is ImageBlock) fileReferences.dec(block.relativePath, library);
        if (block is MediaPlayerBlock) fileReferences.dec(block.relativePath, library);
      }
    }

    library.clearProjects();

    await context.read<ProjectRepository>().saveLibrary(library);
  }

  Future<bool?> _confirmDeleteDialog(BuildContext context, {required bool deleteAll}) {
    final l10n = context.l10n;

    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.commonDelete, style: const TextStyle(color: ColorTheme.primary)),
        content: Text(
          deleteAll ? l10n.projectsDeleteAllConfirmation : l10n.projectsDeleteConfirmation,
          style: const TextStyle(color: ColorTheme.primary),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l10n.commonNo)),
          TIOFlatButton(onPressed: () => Navigator.of(ctx).pop(true), text: l10n.commonYes, boldText: true),
        ],
      ),
    );
  }
}

class MenuItems extends StatelessWidget {
  const MenuItems({super.key, required this.isEditing, required this.onSelected});

  final bool isEditing;
  final ValueChanged<ProjectMenuAction> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final items = [
      MenuItemButton(
        onPressed: () => onSelected(ProjectMenuAction.about),
        semanticsLabel: l10n.homeAbout,
        child: Text(l10n.homeAbout, style: const TextStyle(color: ColorTheme.primary)),
      ),
      MenuItemButton(
        onPressed: () => onSelected(ProjectMenuAction.feedback),
        semanticsLabel: l10n.homeFeedback,
        child: Text(l10n.homeFeedback, style: const TextStyle(color: ColorTheme.primary)),
      ),
      MenuItemButton(
        onPressed: () => onSelected(ProjectMenuAction.importProject),
        semanticsLabel: l10n.projectsImport,
        child: Text(l10n.projectsImport, style: const TextStyle(color: ColorTheme.primary)),
      ),
      MenuItemButton(
        onPressed: () => onSelected(ProjectMenuAction.addNew),
        semanticsLabel: l10n.projectsAddNew,
        child: Text(l10n.projectsAddNew, style: const TextStyle(color: ColorTheme.primary)),
      ),
      MenuItemButton(
        onPressed: () => onSelected(ProjectMenuAction.toggleEditingMode),
        semanticsLabel: isEditing ? l10n.projectsEditDone : l10n.projectsEdit,
        child: Text(
          isEditing ? l10n.projectsEditDone : l10n.projectsEdit,
          style: const TextStyle(color: ColorTheme.primary),
        ),
      ),
      MenuItemButton(
        onPressed: () => onSelected(ProjectMenuAction.deleteAll),
        semanticsLabel: l10n.projectsDeleteAll,
        child: Text(l10n.projectsDeleteAll, style: const TextStyle(color: ColorTheme.primary)),
      ),
      MenuItemButton(
        onPressed: () => onSelected(ProjectMenuAction.tutorialStart),
        semanticsLabel: l10n.projectsTutorialStart,
        child: Text(l10n.projectsTutorialStart, style: const TextStyle(color: ColorTheme.primary)),
      ),
      MenuItemButton(
        onPressed: () => onSelected(ProjectMenuAction.flashCards),
        semanticsLabel: l10n.projectsFlashCards,
        child: Text(l10n.projectsFlashCards, style: const TextStyle(color: ColorTheme.primary)),
      ),
    ];

    return MenuAnchor(
      builder: (context, controller, child) {
        return IconButton(
          onPressed: () => controller.isOpen ? controller.close() : controller.open(),
          icon: const Icon(Icons.more_vert),
          tooltip: l10n.projectsMenu,
        );
      },
      style: const MenuStyle(
        backgroundColor: WidgetStatePropertyAll(ColorTheme.surface),
        elevation: WidgetStatePropertyAll(0),
      ),
      menuChildren: items,
    );
  }
}
