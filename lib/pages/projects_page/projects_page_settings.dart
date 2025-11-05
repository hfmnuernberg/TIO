import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/pages/flash_cards/flash_cards_page.dart';
import 'package:tiomusic/pages/info_pages/about_page.dart';
import 'package:tiomusic/pages/info_pages/feedback_page.dart';
import 'package:tiomusic/pages/projects_page/import_project.dart';
import 'package:tiomusic/util/color_constants.dart';

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
    required this.onDeleteAll,
    required this.onShowTutorialAgain,
  });

  final bool isEditing;
  final ValueChanged<bool> onSetEditing;
  final VoidCallback onAddNew;
  final Future<void> Function() onDeleteAll;
  final VoidCallback onShowTutorialAgain;

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
        await onDeleteAll();
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

  @override
  Widget build(BuildContext context) {
    return MenuItems(isEditing: isEditing, onSelected: (action) => _handleAction(context, action));
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
