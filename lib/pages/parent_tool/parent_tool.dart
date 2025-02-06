import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/models/file_io.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/util/util_functions.dart';
import 'package:tiomusic/util/walkthrough_util.dart';
import 'package:tiomusic/widgets/card_list_tile.dart';
import 'package:tiomusic/widgets/confirm_setting_button.dart';
import 'package:tiomusic/widgets/custom_border_shape.dart';
import 'package:tiomusic/widgets/input/edit_text_dialog.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class ParentTool extends StatefulWidget {
  final String barTitle;
  final bool isQuickTool;
  final ProjectBlock toolBlock;
  final Project? project;
  final Widget? island;
  final Widget centerModule;
  final List<Widget> settingTiles;
  final List<MenuItemButton>? menuItems;
  final Function()? functionBeforeNavigatingBack;
  final Widget? floatingActionButton;
  final double? heightForCenterModule;
  final GlobalKey? keySettingsList;
  final Function()? onParentWalkthroughFinished;
  final bool deactivateScroll;

  const ParentTool({
    required this.barTitle, required this.isQuickTool, required this.toolBlock, required this.centerModule, required this.settingTiles, super.key,
    this.island,
    this.menuItems,
    this.functionBeforeNavigatingBack,
    this.floatingActionButton,
    this.heightForCenterModule,
    this.keySettingsList,
    this.onParentWalkthroughFinished,
    this.project,
    this.deactivateScroll = false,
  });

  @override
  State<ParentTool> createState() => _ParentToolState();
}

class _ParentToolState extends State<ParentTool> {
  Icon _bookmarkIcon = const Icon(Icons.bookmark_add_outlined);
  Color? _highlightColorOnSave;
  final TextEditingController _toolTitle = TextEditingController();

  final Walkthrough _walkthroughQuickTool = Walkthrough();
  final Walkthrough _walkthroughTool = Walkthrough();
  final GlobalKey _keyBookmarkSave = GlobalKey();
  final GlobalKey _keyChangeTitle = GlobalKey();

  final Walkthrough _walkthroughIsland = Walkthrough();
  final GlobalKey _keyIsland = GlobalKey();

  @override
  void initState() {
    super.initState();

    _toolTitle.text = widget.barTitle;

    var projectLibrary = Provider.of<ProjectLibrary>(context, listen: false);
    projectLibrary.visitedToolsCounter++;

    FileIO.saveProjectLibraryToJson(projectLibrary);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isQuickTool) {
        if (context.read<ProjectLibrary>().showQuickToolTutorial) {
          _createWalkthroughQuickTool();
          Future.delayed(Duration.zero, () => _walkthroughQuickTool.show(context));
        } else if (context.read<ProjectLibrary>().showIslandTutorial &&
            checkIslandPossible(widget.project, widget.toolBlock)) {
          _createWalkthroughIsland();
          Future.delayed(Duration.zero, () => _walkthroughIsland.show(context));
        } else {
          if (widget.onParentWalkthroughFinished != null) {
            widget.onParentWalkthroughFinished!();
          }
        }
      } else {
        if (context.read<ProjectLibrary>().showToolTutorial) {
          _createWalkthroughTool();
          Future.delayed(Duration.zero, () => _walkthroughTool.show(context));
        } else if (context.read<ProjectLibrary>().showIslandTutorial &&
            checkIslandPossible(widget.project, widget.toolBlock)) {
          _createWalkthroughIsland();
          Future.delayed(Duration.zero, () => _walkthroughIsland.show(context));
        } else {
          if (widget.onParentWalkthroughFinished != null) {
            widget.onParentWalkthroughFinished!();
          }
        }
      }
    });
  }

  void _createWalkthroughQuickTool() {
    // add the targets here
    var targets = <CustomTargetFocus>[
      CustomTargetFocus(
        _keyBookmarkSave,
        "Tap here to save the tool to a project",
        alignText: ContentAlign.left,
        pointingDirection: PointingDirection.right,
      ),
    ];
    _walkthroughQuickTool.create(
      targets.map((e) => e.targetFocus).toList(),
      () {
        context.read<ProjectLibrary>().showQuickToolTutorial = false;
        FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());

        // start island tutorial
        if (context.read<ProjectLibrary>().showIslandTutorial &&
            checkIslandPossible(widget.project, widget.toolBlock)) {
          _createWalkthroughIsland();
          Future.delayed(Duration.zero, () => _walkthroughIsland.show(context));
        } else if (widget.onParentWalkthroughFinished != null) {
          widget.onParentWalkthroughFinished!();
        }
      },
      context,
    );
  }

  void _createWalkthroughTool() {
    // add the targets here
    var targets = <CustomTargetFocus>[
      CustomTargetFocus(
        _keyBookmarkSave,
        "Tap here to copy your tool to another project",
        alignText: ContentAlign.left,
        pointingDirection: PointingDirection.right,
      ),
      CustomTargetFocus(
        _keyChangeTitle,
        "Tap here to edit the title of your tool",
        pointingDirection: PointingDirection.up,
        alignText: ContentAlign.bottom,
        shape: ShapeLightFocus.RRect,
      ),
    ];
    _walkthroughTool.create(
      targets.map((e) => e.targetFocus).toList(),
      () {
        context.read<ProjectLibrary>().showToolTutorial = false;
        FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());

        // start island tutorial
        if (context.read<ProjectLibrary>().showIslandTutorial &&
            checkIslandPossible(widget.project, widget.toolBlock)) {
          _createWalkthroughIsland();
          Future.delayed(Duration.zero, () => _walkthroughIsland.show(context));
        } else if (widget.onParentWalkthroughFinished != null) {
          widget.onParentWalkthroughFinished!();
        }
      },
      context,
    );
  }

  void _createWalkthroughIsland() {
    // add the targets here
    var targets = <CustomTargetFocus>[
      CustomTargetFocus(
        _keyIsland,
        "Tap here to combine your tool with a metronome, tuner or media player",
        pointingDirection: PointingDirection.up,
        alignText: ContentAlign.bottom,
        shape: ShapeLightFocus.RRect,
      ),
    ];
    _walkthroughIsland.create(
      targets.map((e) => e.targetFocus).toList(),
      () {
        context.read<ProjectLibrary>().showIslandTutorial = false;
        FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());

        // start specific tool tutorial
        if (widget.onParentWalkthroughFinished != null) {
          widget.onParentWalkthroughFinished!();
        }
      },
      context,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  PreferredSizeWidget _appBar(BuildContext context) {
    List<Widget> appBarActions = [
      // Icon Button for saving the tool
      IconButton(
        key: _keyBookmarkSave,
        onPressed: () {
          _openBottomSheetAndSaveTool();
        },
        icon: Icon(widget.isQuickTool ? Icons.bookmark_outline : Icons.bookmark_add_outlined),
      ),
    ];

    if (widget.menuItems != null && widget.menuItems!.isNotEmpty) {
      appBarActions.add(
        MenuAnchor(
          builder: (BuildContext context, MenuController controller, Widget? child) {
            return IconButton(
              onPressed: () {
                controller.isOpen ? controller.close() : controller.open();
              },
              icon: const Icon(Icons.more_vert),
            );
          },
          style: const MenuStyle(
            backgroundColor: WidgetStatePropertyAll(ColorTheme.surface),
            elevation: WidgetStatePropertyAll(0.0),
          ),
          menuChildren: widget.menuItems!,
        ),
      );
    }

    var backButton = BackButton(
      onPressed: () async {
        if (widget.functionBeforeNavigatingBack != null) {
          widget.functionBeforeNavigatingBack!();
        }

        // if quick tool and values have been changed: ask for saving
        if (widget.isQuickTool && !blockValuesSameAsDefaultBlock(widget.toolBlock)) {
          final save = await askForSavingQuickTool(context);

          // if user taps outside the dialog, we dont want to exit the quick tool and we dont want to save
          if (save == null) return;

          if (save) {
            _openBottomSheetAndSaveTool();
          } else {
            if (context.mounted) Navigator.of(context).pop();
          }
        } else {
          Navigator.of(context).pop();
        }
      },
    );

    return AppBar(
      leading: backButton,
      title: GestureDetector(
        onTap: () async {
          final newTitle = await showEditTextDialog(
            context: context,
            label: 'New tool:',
            value: widget.toolBlock.title,
          );
          if (newTitle == null) return;
          widget.toolBlock.title = newTitle;
          if (context.mounted) FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());
          setState(() {});
        },
        child: Text(
          widget.toolBlock.title,
          style: const TextStyle(color: ColorTheme.primary, fontSize: TIOMusicParams.titleFontSize),
        ),
      ),
      backgroundColor: ColorTheme.surfaceBright,
      foregroundColor: ColorTheme.primary,
      actions: appBarActions,
    );
  }

  void _openBottomSheetAndSaveTool() {
    var projectLibrary = Provider.of<ProjectLibrary>(context, listen: false);

    ourModalBottomSheet(context, [
      CardListTile(
        title: widget.barTitle,
        subtitle: formatSettingValues(widget.toolBlock.getSettingsFormatted()),
        trailingIcon: IconButton(onPressed: () {}, icon: const SizedBox()),
        leadingPicture: circleToolIcon(widget.toolBlock.icon),
        onTapFunction: () {},
      ),
    ], [
      Padding(
        padding: const EdgeInsets.only(top: 16, left: 32),
        child: Align(
          alignment: Alignment.centerLeft,
          child: widget.isQuickTool
              ? const Text(
                  "Save in ...",
                  style: TextStyle(fontSize: 18, color: ColorTheme.surfaceTint),
                )
              : const Text(
                  "Save copy in ...",
                  style: TextStyle(fontSize: 18, color: ColorTheme.surfaceTint),
                ),
        ),
      ),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.only(top: TIOMusicParams.smallSpaceAboveList),
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: projectLibrary.projects.length,
            itemBuilder: (BuildContext context, int index) {
              return StatefulBuilder(
                builder: (BuildContext context, StateSetter setTileState) {
                  return CardListTile(
                    title: projectLibrary.projects[index].title,
                    subtitle: getDateAndTimeFormatted(projectLibrary.projects[index].timeLastModified),
                    highlightColor: _highlightColorOnSave,
                    trailingIcon: IconButton(
                      onPressed: () {
                        _onSaveInProjectTap(setTileState, index, widget.toolBlock);
                      },
                      icon: _bookmarkIcon,
                      color: ColorTheme.surfaceTint,
                    ),
                    leadingPicture: projectLibrary.projects[index].thumbnail,
                    onTapFunction: () {
                      _onSaveInProjectTap(setTileState, index, widget.toolBlock);
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
      TIOFlatButton(
        // creating a new project to save the tool in it
        onPressed: () async {
          final newTitles = await editTwoTitles(context, getDateAndTimeNow(), "${widget.toolBlock.title} - copy");
          if (newTitles == null || newTitles.isEmpty) {
            if (mounted) {
              // close the bottom up sheet
              Navigator.of(context).pop();
            }
            return;
          }
          if (mounted) {
            // close the bottom up sheet
            Navigator.of(context).pop();

            saveToolInNewProject(context, widget.toolBlock, widget.isQuickTool, newTitles[0], newTitles[1]);
          }
        },
        text: "Save in a new project",
      ),
      const SizedBox(height: 16),
    ]);
  }

  void _onSaveInProjectTap(StateSetter setTileState, int index, ProjectBlock toolBlock) async {
    final newTitle = await showEditTextDialog(
      context: context,
      label: 'Tool title:',
      value: "${toolBlock.title} - copy",
      isNew: true,
    );
    if (newTitle == null) {
      if (mounted) {
        // close the bottom up sheet
        Navigator.of(context).pop();
      }
      return;
    }

    // highlight tile and change icon to get a tick mark
    setTileState(() {
      _bookmarkIcon = const Icon(Icons.bookmark_added_outlined);
      _highlightColorOnSave = ColorTheme.primaryFixedDim;
    });
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      // close the bottom up sheet
      Navigator.of(context).pop();
    }

    // saving the tool in a project
    if (mounted) {
      saveToolInProject(context, index, toolBlock, widget.isQuickTool, newTitle);
    }
  }

  Widget _settingsList(List<Widget> tiles) {
    return ListView.builder(
      key: widget.keySettingsList,
      itemBuilder: (BuildContext context, int index) {
        return tiles[index];
      },
      itemCount: tiles.length,
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(ParentToolParams.appBarHeight),
        child: _appBar(context),
      ),
      backgroundColor: ColorTheme.primary92,
      body: widget.deactivateScroll ? _body() : SingleChildScrollView(child: _body()),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: widget.floatingActionButton,
    );
  }

  Widget _body() {
    bool hasSettingTiles = true;
    if (widget.settingTiles.isEmpty) {
      hasSettingTiles = false;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // island or no island
        widget.island == null
            ? const SizedBox()
            : SizedBox(
                key: _keyIsland,
                height: ParentToolParams.islandHeight,
                width: MediaQuery.of(context).size.width,
                child: widget.island,
              ),
        // center module
        hasSettingTiles
            ? SizedBox(
                height: widget.heightForCenterModule ?? MediaQuery.of(context).size.height / 2.5,
                child: widget.centerModule,
              )
            : widget.centerModule,
        // empty space between center module and settings
        const SizedBox(height: 8),
        // setting tiles or no setting tiles
        hasSettingTiles ? _settingsList(widget.settingTiles) : const SizedBox(),
        // empty space at the bottom
        const SizedBox(height: 32),
      ],
    );
  }
}
