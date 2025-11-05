import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/pages/flash_cards/flash_cards_page.dart';
import 'package:tiomusic/pages/info_pages/about_page.dart';
import 'package:tiomusic/pages/info_pages/feedback_page.dart';
import 'package:tiomusic/pages/projects_page/import_project.dart';
import 'package:tiomusic/util/color_constants.dart';

enum MenuAction { about, feedback, importProject, addNew, toggleEditingMode, deleteAll, tutorialStart, flashCards }

class ProjectsMenu extends StatelessWidget {
  const ProjectsMenu({
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

  Future<void> _handleAction(BuildContext context, MenuAction action) async {
    switch (action) {
      case MenuAction.about:
        _aboutPage(context);
      case MenuAction.feedback:
        _feedbackPage(context);
      case MenuAction.importProject:
        await importProject(context);
      case MenuAction.addNew:
        onAddNew();
      case MenuAction.toggleEditingMode:
        onSetEditing(!isEditing);
      case MenuAction.deleteAll:
        await onDeleteAll();
      case MenuAction.tutorialStart:
        onShowTutorialAgain();
      case MenuAction.flashCards:
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
  final ValueChanged<MenuAction> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final items = [
      MenuItemButton(
        onPressed: () => onSelected(MenuAction.about),
        semanticsLabel: l10n.homeAbout,
        child: Text(l10n.homeAbout, style: const TextStyle(color: ColorTheme.primary)),
      ),
      MenuItemButton(
        onPressed: () => onSelected(MenuAction.feedback),
        semanticsLabel: l10n.homeFeedback,
        child: Text(l10n.homeFeedback, style: const TextStyle(color: ColorTheme.primary)),
      ),
      MenuItemButton(
        onPressed: () => onSelected(MenuAction.importProject),
        semanticsLabel: l10n.projectsImport,
        child: Text(l10n.projectsImport, style: const TextStyle(color: ColorTheme.primary)),
      ),
      MenuItemButton(
        onPressed: () => onSelected(MenuAction.addNew),
        semanticsLabel: l10n.projectsAddNew,
        child: Text(l10n.projectsAddNew, style: const TextStyle(color: ColorTheme.primary)),
      ),
      MenuItemButton(
        onPressed: () => onSelected(MenuAction.toggleEditingMode),
        semanticsLabel: isEditing ? l10n.projectsEditDone : l10n.projectsEdit,
        child: Text(
          isEditing ? l10n.projectsEditDone : l10n.projectsEdit,
          style: const TextStyle(color: ColorTheme.primary),
        ),
      ),
      MenuItemButton(
        onPressed: () => onSelected(MenuAction.deleteAll),
        semanticsLabel: l10n.projectsDeleteAll,
        child: Text(l10n.projectsDeleteAll, style: const TextStyle(color: ColorTheme.primary)),
      ),
      MenuItemButton(
        onPressed: () => onSelected(MenuAction.tutorialStart),
        semanticsLabel: l10n.projectsTutorialStart,
        child: Text(l10n.projectsTutorialStart, style: const TextStyle(color: ColorTheme.primary)),
      ),
      // TODO: Enable flash cards feature with flash cards list and real content
      // MenuItemButton(
      //   onPressed: () => onSelected(MenuAction.flashCards),
      //   semanticsLabel: l10n.projectsFlashCards,
      //   child: Text(l10n.projectsFlashCards, style: const TextStyle(color: ColorTheme.primary)),
      // ),
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
