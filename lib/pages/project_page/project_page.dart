import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/image_block.dart';
import 'package:tiomusic/models/file_io.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/pages/project_page/export_project.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/util/util_functions.dart';
import 'package:tiomusic/util/tutorial_util.dart';
import 'package:tiomusic/widgets/big_icon_button.dart';
import 'package:tiomusic/widgets/card_list_tile.dart';
import 'package:tiomusic/widgets/confirm_setting_button.dart';
import 'package:tiomusic/widgets/custom_border_shape.dart';
import 'package:tiomusic/widgets/input/edit_text_dialog.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class ProjectPage extends StatefulWidget {
  final bool goStraightToTool;
  final bool withoutRealProject;
  final ProjectBlock? toolToOpenDirectly;
  final bool pianoAlreadyOn;

  const ProjectPage({
    super.key,
    required this.goStraightToTool,
    this.toolToOpenDirectly,
    required this.withoutRealProject,
    this.pianoAlreadyOn = false,
  });

  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  late bool _showBlocks;

  late Project _project;
  bool _withoutProject = false;

  final List<MenuItemButton> _menuItems = List.empty(growable: true);
  final TextEditingController _titleController = TextEditingController();

  final Tutorial _tutorial = Tutorial();
  final GlobalKey _keyChangeTitle = GlobalKey();

  @override
  void initState() {
    super.initState();

    _withoutProject = widget.withoutRealProject;

    _project = Provider.of<Project>(context, listen: false);

    _titleController.text = _project.title;

    if (_project.blocks.isEmpty) {
      _showBlocks = false;
    } else {
      _showBlocks = true;
    }

    _project.timeLastModified = getCurrentDateTime();

    if (widget.goStraightToTool) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        goToTool(
          context,
          _project,
          widget.toolToOpenDirectly!,
          pianoAleadyOn: widget.pianoAlreadyOn,
        ).then((_) => setState(() {}));
      });
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    }

    _showTutorial();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_menuItems.isEmpty) {
      _menuItems.addAll([
        MenuItemButton(
          onPressed: () => exportProject(context, _project),
          child: Text(context.l10n.projectExport, style: TextStyle(color: ColorTheme.primary)),
        ),
        MenuItemButton(
          onPressed: () async {
            bool? deleteBlock = await _deleteBlock(deleteAll: true);
            if (deleteBlock != null && deleteBlock) {
              if (mounted) {
                _project.clearBlocks(context.read<ProjectLibrary>());
                FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());
                setState(() {});
              }
            }
          },
          child: Text(context.l10n.projectDeleteAllTools, style: TextStyle(color: ColorTheme.primary)),
        ),
      ]);
    }

    _showTutorial();
  }

  void _showTutorial() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final projectLibrary = context.read<ProjectLibrary>();

      if (projectLibrary.showHomepageTutorial) {
        projectLibrary.showHomepageTutorial = false;
        FileIO.saveProjectLibraryToJson(projectLibrary);
        _createTutorial();
        _tutorial.show(context);
      }
    });
  }

  void _createTutorial() {
    var targets = <CustomTargetFocus>[
      CustomTargetFocus(
        _keyChangeTitle,
        context.l10n.projectTutorialEditTitle,
        pointingDirection: PointingDirection.up,
        alignText: ContentAlign.bottom,
        shape: ShapeLightFocus.RRect,
      ),
    ];
    _tutorial.create(targets.map((e) => e.targetFocus).toList(), () {
      context.read<ProjectLibrary>().showProjectPageTutorial = false;
      FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());
    }, context);
  }

  Future<bool?> _deleteBlock({bool deleteAll = false}) => showDialog<bool>(
    context: context,
    builder: (context) {
      final l10n = context.l10n;

      return AlertDialog(
        title: Text(l10n.commonDelete, style: TextStyle(color: ColorTheme.primary)),
        content:
            deleteAll
                ? Text(l10n.projectDeleteAllToolsConfirmation, style: TextStyle(color: ColorTheme.primary))
                : Text(l10n.projectDeleteToolConfirmation, style: TextStyle(color: ColorTheme.primary)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text(l10n.commonNo),
          ),
          TIOFlatButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            text: l10n.commonYes,
            boldText: true,
          ),
        ],
      );
    },
  );

  void _deleteThumbnailWhenNecessary(Project project, ProjectBlock block) {
    if (block is! ImageBlock) return;
    if (project.thumbnailPath == block.relativePath) project.setThumbnail('');
  }

  void _createBlockAndGoToTool(BlockTypeInfo info, String blockTitle) {
    if (_withoutProject) {
      final projectLibrary = context.read<ProjectLibrary>();
      projectLibrary.addProject(_project);
      _withoutProject = false;
    }

    final newBlock = info.createWithTitle(blockTitle);

    _project.addBlock(newBlock);
    FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());

    setState(() {
      _showBlocks = true;
    });

    goToTool(context, _project, newBlock).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    if (_showBlocks) {
      return _buildProjectPage(context);
    } else {
      return _buildChooseToolPage();
    }
  }

  Widget _buildProjectPage(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: GestureDetector(
          onTap: () async {
            final newTitle = await showEditTextDialog(
              context: context,
              label: context.l10n.projectNew,
              value: _project.title,
            );
            if (newTitle == null) return;
            _project.title = newTitle;
            if (context.mounted) FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());
            setState(() {});
          },
          child: Text(
            _project.title,
            style: const TextStyle(color: ColorTheme.primary, fontSize: TIOMusicParams.titleFontSize),
          ),
        ),
        backgroundColor: ColorTheme.surfaceBright,
        foregroundColor: ColorTheme.primary,
        actions: [
          MenuAnchor(
            builder: (context, controller, child) {
              return IconButton(
                onPressed: () {
                  controller.isOpen ? controller.close() : controller.open();
                },
                icon: const Icon(Icons.more_vert),
              );
            },
            style: const MenuStyle(
              backgroundColor: WidgetStatePropertyAll(ColorTheme.surface),
              elevation: WidgetStatePropertyAll(0),
            ),
            menuChildren: _menuItems,
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        fit: StackFit.expand,
        children: [
          FittedBox(fit: BoxFit.cover, child: Image.asset('assets/images/tiomusic-bg.png')),
          Padding(
            padding: const EdgeInsets.only(top: TIOMusicParams.bigSpaceAboveList),
            child: ListView.builder(
              itemCount: _project.blocks.length + 1,
              itemBuilder: (context, index) {
                if (index >= _project.blocks.length) {
                  return const SizedBox(height: 120);
                } else {
                  return CardListTile(
                    title: _project.blocks[index].title,
                    subtitle: formatSettingValues(_project.blocks[index].getSettingsFormatted(context.l10n)),
                    leadingPicture: circleToolIcon(_project.blocks[index].icon),
                    trailingIcon: IconButton(
                      onPressed:
                          () => {goToTool(context, _project, _project.blocks[index]).then((_) => setState(() {}))},
                      icon: const Icon(Icons.arrow_forward),
                      color: ColorTheme.primaryFixedDim,
                    ),
                    menuIconOne: IconButton(
                      onPressed: () async {
                        bool? deleteBlock = await _deleteBlock();
                        if (deleteBlock != null && deleteBlock) {
                          if (context.mounted) {
                            _deleteThumbnailWhenNecessary(_project, _project.blocks[index]);
                            _project.removeBlock(_project.blocks[index], context.read<ProjectLibrary>());
                            await FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());
                          }
                          setState(() {});
                        }
                      },
                      icon: const Icon(Icons.delete_outlined),
                      color: ColorTheme.surfaceTint,
                    ),
                    onTapFunction: () {
                      goToTool(context, _project, _project.blocks[index]).then((_) => setState(() {}));
                    },
                  );
                }
              },
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // button to add a new tool
              BigIconButton(
                icon: Icons.add,
                onPressed: () {
                  setState(() {
                    _showBlocks = false;
                  });
                },
              ),
              const SizedBox(height: TIOMusicParams.spaceBetweenPlusButtonAndBottom),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChooseToolPage() {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(context.l10n.projectEmpty),
        backgroundColor: ColorTheme.surfaceBright,
        foregroundColor: ColorTheme.primary,
        leading: IconButton(
          onPressed: () {
            if (_project.blocks.isEmpty) {
              Navigator.of(context).pop();
            } else {
              setState(() {
                _showBlocks = true;
              });
            }
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          FittedBox(fit: BoxFit.cover, child: Image.asset('assets/images/tiomusic-bg.png')),
          Padding(
            padding: const EdgeInsets.only(top: TIOMusicParams.bigSpaceAboveList),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: BlockType.values.length,
              itemBuilder: (context, index) {
                var info = getBlockTypeInfos(context.l10n)[BlockType.values[index]]!;
                return CardListTile(
                  title: info.name,
                  subtitle: info.description,
                  trailingIcon: IconButton(
                    onPressed: () {
                      _onNewToolTilePressed(info);
                    },
                    icon: const Icon(Icons.add),
                    color: ColorTheme.surfaceTint,
                  ),
                  leadingPicture: circleToolIcon(info.icon),
                  onTapFunction: () {
                    _onNewToolTilePressed(info);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _onNewToolTilePressed(BlockTypeInfo info) async {
    final newTitle = await showEditTextDialog(
      context: context,
      label: context.l10n.projectNewTool,
      value: '${info.name} ${_project.toolCounter[info.kind]! + 1}',
      isNew: true,
    );
    if (newTitle == null) return;

    _project.increaseCounter(info.kind);
    if (mounted) {
      FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());
    }

    _createBlockAndGoToTool(info, newTitle);
  }
}
