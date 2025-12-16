import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/util/app_orientation.dart';
import 'package:tiomusic/util/tool_navigation_utils.dart';
import 'package:tiomusic/widgets/parent_tool/modal_bottom_sheet.dart';
import 'package:tiomusic/services/file_system.dart';
import 'package:tiomusic/services/project_repository.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants/constants.dart';
import 'package:tiomusic/util/util_functions.dart';
import 'package:tiomusic/util/tutorial/tutorial_util.dart';
import 'package:tiomusic/widgets/card_list_tile.dart';
import 'package:tiomusic/widgets/common_buttons.dart';
import 'package:tiomusic/widgets/custom_border_shape.dart';
import 'package:tiomusic/widgets/input/edit_text_dialog.dart';
import 'package:tiomusic/widgets/tool_navigation_bar.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class ParentTool extends StatefulWidget {
  final String barTitle;
  final bool isQuickTool;
  final ProjectBlock toolBlock;
  final Project? project;
  final Widget? island;
  final Widget centerModule;
  final List<Widget> settingTiles;
  final List<IconButton>? customActions;
  final List<MenuItemButton>? menuItems;
  final Function()? functionBeforeNavigatingBack;
  final Widget? floatingActionButton;
  final double? heightForCenterModule;
  final GlobalKey? keySettingsList;
  final Function()? onParentTutorialFinished;
  final bool deactivateScroll;
  final GlobalKey? islandToolTutorialKey;

  const ParentTool({
    super.key,
    required this.barTitle,
    required this.isQuickTool,
    required this.toolBlock,
    this.island,
    required this.centerModule,
    required this.settingTiles,
    this.customActions,
    this.menuItems,
    this.functionBeforeNavigatingBack,
    this.floatingActionButton,
    this.heightForCenterModule,
    this.keySettingsList,
    this.onParentTutorialFinished,
    this.project,
    this.deactivateScroll = false,
    this.islandToolTutorialKey,
  });

  @override
  State<ParentTool> createState() => _ParentToolState();
}

class _ParentToolState extends State<ParentTool> {
  late FileSystem _fs;
  late ProjectRepository _projectRepo;

  Icon _bookmarkIcon = const Icon(Icons.bookmark_add_outlined);
  Color? _highlightColorOnSave;
  final TextEditingController _toolTitle = TextEditingController();

  final Tutorial _tutorial = Tutorial();
  final GlobalKey _keySaveCopyInProject = GlobalKey();
  final GlobalKey _keySaveInProject = GlobalKey();
  final GlobalKey _keyChangeTitle = GlobalKey();

  @override
  void initState() {
    super.initState();

    _fs = context.read<FileSystem>();
    _projectRepo = context.read<ProjectRepository>();

    _toolTitle.text = widget.barTitle;

    var projectLibrary = Provider.of<ProjectLibrary>(context, listen: false);
    projectLibrary.visitedToolsCounter++;

    unawaited(_projectRepo.saveLibrary(projectLibrary));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      AppOrientation.set(context, policy: OrientationPolicy.phonePortrait);
      _createTutorial();
      _tutorial.show(context);
    });
  }

  void _createTutorial() {
    final targets = <CustomTargetFocus>[
      if (context.read<ProjectLibrary>().showQuickToolTutorial && widget.isQuickTool)
        CustomTargetFocus(
          _keySaveInProject,
          context.l10n.toolTutorialSave,
          hideBack: true,
          alignText: ContentAlign.left,
          pointingDirection: PointingDirection.right,
          pointerOffset: -25,
        ),
      if (context.read<ProjectLibrary>().showToolTutorial && !widget.isQuickTool)
        CustomTargetFocus(
          _keySaveCopyInProject,
          context.l10n.appTutorialToolSave,
          alignText: ContentAlign.left,
          pointingDirection: PointingDirection.right,
        ),
      if (context.read<ProjectLibrary>().showToolTutorial && context.read<ProjectLibrary>().showQuickToolTutorial)
        CustomTargetFocus(
          _keyChangeTitle,
          context.l10n.toolTutorialEditTitle,
          alignText: ContentAlign.bottom,
          pointingDirection: PointingDirection.up,
          pointerOffset: -80,
          shape: ShapeLightFocus.RRect,
        ),
    ];

    if (targets.isEmpty) {
      if (widget.onParentTutorialFinished != null) widget.onParentTutorialFinished!();
      return;
    }

    _tutorial.create(targets.map((e) => e.targetFocus).toList(), () async {
      final projectLibrary = context.read<ProjectLibrary>();

      if (context.read<ProjectLibrary>().showQuickToolTutorial && widget.isQuickTool) {
        projectLibrary.showQuickToolTutorial = false;
      }

      if (context.read<ProjectLibrary>().showToolTutorial && !widget.isQuickTool) {
        projectLibrary.showToolTutorial = false;
      }

      await _projectRepo.saveLibrary(projectLibrary);

      if (widget.onParentTutorialFinished != null) widget.onParentTutorialFinished!();
    }, context);
  }

  @override
  void dispose() {
    _tutorial.dispose();
    _toolTitle.dispose();
    super.dispose();
  }

  PreferredSizeWidget _appBar(BuildContext context) {
    List<Widget> appBarActions = [
      Semantics(
        label: context.l10n.toolSave,
        child: IconButton(
          key: widget.isQuickTool ? _keySaveInProject : _keySaveCopyInProject,
          onPressed: _openBottomSheetAndSaveTool,
          icon: Icon(widget.isQuickTool ? Icons.bookmark_outline : Icons.bookmark_add_outlined),
        ),
      ),
    ];

    if (widget.customActions != null && widget.customActions!.isNotEmpty) appBarActions.addAll(widget.customActions!);

    if (widget.menuItems != null && widget.menuItems!.isNotEmpty) {
      appBarActions.add(
        MenuAnchor(
          builder: (context, controller, child) => IconButton(
            onPressed: () => controller.isOpen ? controller.close() : controller.open(),
            icon: const Icon(Icons.more_vert),
          ),
          style: const MenuStyle(
            backgroundColor: WidgetStatePropertyAll(ColorTheme.surface),
            elevation: WidgetStatePropertyAll(0),
          ),
          menuChildren: widget.menuItems!,
        ),
      );
    }

    var backButton = BackButton(
      onPressed: () async {
        if (widget.functionBeforeNavigatingBack != null) widget.functionBeforeNavigatingBack!();

        if (widget.isQuickTool && !blockValuesSameAsDefaultBlock(widget.toolBlock, context.l10n)) {
          final save = await askForSavingQuickTool(context);

          if (save == null) return;

          if (save) {
            _openBottomSheetAndSaveTool();
          } else {
            if (context.mounted) Navigator.of(context).pop();
          }
        } else {
          Navigator.of(context).pop({ReturnAction.showTutorial.name: true});
        }
      },
    );

    return AppBar(
      leading: backButton,
      centerTitle: false,
      title: GestureDetector(
        key: _keyChangeTitle,
        onTap: () async {
          final newTitle = await showEditTextDialog(
            context: context,
            label: context.l10n.toolNewTitle,
            value: widget.toolBlock.title,
          );
          if (newTitle == null) return;
          widget.toolBlock.title = newTitle;
          if (context.mounted) await _projectRepo.saveLibrary(context.read<ProjectLibrary>());
          setState(() {});
        },
        child: Text(
          widget.toolBlock.title,
          style: const TextStyle(color: ColorTheme.primary, fontSize: TIOMusicParams.titleFontSize),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      backgroundColor: ColorTheme.surfaceBright,
      foregroundColor: ColorTheme.primary,
      actions: appBarActions,
    );
  }

  void _openBottomSheetAndSaveTool() {
    var projectLibrary = Provider.of<ProjectLibrary>(context, listen: false);
    final l10n = context.l10n;
    final label = widget.isQuickTool ? l10n.toolSaveIn : l10n.toolSaveCopy;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ModalBottomSheet(
        label: label,
        titleChildren: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: CardListTile(
              title: widget.barTitle,
              subtitle: formatSettingValues(widget.toolBlock.getSettingsFormatted(context.l10n)),
              trailingIcon: IconButton(onPressed: () {}, icon: const SizedBox()),
              leadingPicture: circleToolIcon(widget.toolBlock.icon),
              onTapFunction: () {},
            ),
          ),
        ],
        contentChildren: [
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 32),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(label, style: TextStyle(fontSize: 18, color: ColorTheme.surfaceTint)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: TIOMusicParams.smallSpaceAboveList),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: projectLibrary.projects.length,
                itemBuilder: (context, index) {
                  return StatefulBuilder(
                    builder: (context, setTileState) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: CardListTile(
                          title: projectLibrary.projects[index].title,
                          subtitle: l10n.formatDateAndTime(projectLibrary.projects[index].timeLastModified),
                          highlightColor: _highlightColorOnSave,
                          trailingIcon: IconButton(
                            onPressed: () => _onSaveInProjectTap(setTileState, index, widget.toolBlock),
                            icon: _bookmarkIcon,
                            color: ColorTheme.surfaceTint,
                          ),
                          leadingPicture: projectLibrary.projects[index].thumbnailPath.isEmpty
                              ? const AssetImage(TIOMusicParams.tiomusicIconPath)
                              : FileImage(File(_fs.toAbsoluteFilePath(projectLibrary.projects[index].thumbnailPath))),
                          onTapFunction: () => _onSaveInProjectTap(setTileState, index, widget.toolBlock),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          TIOFlatButton(onPressed: _handleSaveTool, text: l10n.toolSaveInNewProject),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _handleSaveTool() async {
    final newTitles = await editTwoTitles(
      context,
      context.l10n.formatDateAndTime(DateTime.now()),
      '${widget.toolBlock.title} - ${context.l10n.toolTitleCopy}',
    );

    if (!mounted) return;

    if (newTitles == null || newTitles.isEmpty) {
      Navigator.of(context).pop();
      return;
    }

    Navigator.of(context).pop();
    saveToolInNewProject(context, widget.toolBlock, widget.isQuickTool, newTitles[0], newTitles[1]);
  }

  void _onSaveInProjectTap(StateSetter setTileState, int index, ProjectBlock toolBlock) async {
    final newTitle = await showEditTextDialog(
      context: context,
      label: context.l10n.toolNewTitle,
      value: '${toolBlock.title} - ${context.l10n.toolTitleCopy}',
      isNew: true,
    );
    if (newTitle == null) {
      if (mounted) Navigator.of(context).pop();
      return;
    }

    setTileState(() {
      _bookmarkIcon = const Icon(Icons.bookmark_added_outlined);
      _highlightColorOnSave = ColorTheme.primaryFixedDim;
    });
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) Navigator.of(context).pop();

    if (mounted) await saveToolInProject(context, index, toolBlock, widget.isQuickTool, newTitle);
  }

  Widget _settingsList(List<Widget> tiles) {
    return ListView.builder(
      key: widget.keySettingsList,
      itemBuilder: (context, index) => tiles[index],
      itemCount: tiles.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
    );
  }

  Widget _body() {
    bool hasSettingTiles = true;
    if (widget.settingTiles.isEmpty) hasSettingTiles = false;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (widget.island == null)
          const SizedBox()
        else
          SizedBox(
            key: widget.islandToolTutorialKey,
            height: ParentToolParams.islandHeight,
            width: MediaQuery.of(context).size.width,
            child: widget.island,
          ),
        if (hasSettingTiles)
          SizedBox(
            height: widget.heightForCenterModule ?? MediaQuery.of(context).size.height / 2.5,
            child: widget.centerModule,
          )
        else
          widget.centerModule,
        const SizedBox(height: 8),
        if (hasSettingTiles) _settingsList(widget.settingTiles) else const SizedBox(),
        const SizedBox(height: 32),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final project = context.read<Project?>();

    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(ParentToolParams.appBarHeight),
        child: _appBar(context),
      ),
      backgroundColor: ColorTheme.primary92,
      body: widget.deactivateScroll ? _body() : SingleChildScrollView(child: _body()),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: widget.floatingActionButton,
      bottomNavigationBar: project == null ? null : ToolNavigationBar(project: project, toolBlock: widget.toolBlock),
    );
  }
}
