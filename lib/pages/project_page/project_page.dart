import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/models/blocks/image_block.dart';
import 'package:tiomusic/models/blocks/media_player_block.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/pages/project_page/export_project_dialog.dart';
import 'package:tiomusic/services/file_references.dart';
import 'package:tiomusic/services/project_library_repository.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/util/util_functions.dart';
import 'package:tiomusic/util/walkthrough_util.dart';
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
  late ProjectLibraryRepository _projectLibraryRepo;
  late FileReferences _fileReferences;

  late bool _showBlocks;

  late Project _project;
  bool _withoutProject = false;

  final List<MenuItemButton> _menuItems = List.empty(growable: true);
  final TextEditingController _titleController = TextEditingController();

  final Walkthrough _walkthrough = Walkthrough();
  final GlobalKey _keyChangeTitle = GlobalKey();

  @override
  void initState() {
    super.initState();
    _projectLibraryRepo = context.read<ProjectLibraryRepository>();
    _fileReferences = context.read<FileReferences>();

    _menuItems.add(
      MenuItemButton(
        onPressed: () => showExportProjectDialog(context: context, project: _project),
        child: const Text('Export Project', style: TextStyle(color: ColorTheme.primary)),
      ),
    );
    _menuItems.add(
      MenuItemButton(
        onPressed: _handleDeleteAllBlocks,
        child: const Text('Delete all Tools', style: TextStyle(color: ColorTheme.primary)),
      ),
    );

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

    if (context.read<ProjectLibrary>().showProjectPageTutorial && !widget.goStraightToTool) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _createWalkthrough();
        _walkthrough.show(context);
      });
    }
  }

  void _createWalkthrough() {
    var targets = <CustomTargetFocus>[
      CustomTargetFocus(
        _keyChangeTitle,
        'Tap here to edit the title of your project',
        pointingDirection: PointingDirection.up,
        alignText: ContentAlign.bottom,
        shape: ShapeLightFocus.RRect,
      ),
    ];
    _walkthrough.create(targets.map((e) => e.targetFocus).toList(), () async {
      context.read<ProjectLibrary>().showProjectPageTutorial = false;
      await _projectLibraryRepo.save(context.read<ProjectLibrary>());
    }, context);
  }

  Future<bool?> _confirmDeleteBlock({bool deleteAll = false}) => showDialog<bool>(
    context: context,
    builder:
        (context) => AlertDialog(
          title: const Text('Delete?', style: TextStyle(color: ColorTheme.primary)),
          content:
              deleteAll
                  ? const Text(
                    'Do you really want to delete all tools in this project?',
                    style: TextStyle(color: ColorTheme.primary),
                  )
                  : const Text('Do you really want to delete this tool?', style: TextStyle(color: ColorTheme.primary)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('No'),
            ),
            TIOFlatButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              text: 'Yes',
              boldText: true,
            ),
          ],
        ),
  );

  void _createBlockAndGoToTool(BlockTypeInfo info, String blockTitle) async {
    if (_withoutProject) {
      final projectLibrary = context.read<ProjectLibrary>();
      projectLibrary.addProject(_project);
      _withoutProject = false;
    }

    final newBlock = info.createWithTitle(blockTitle);

    _project.addBlock(newBlock);
    await _projectLibraryRepo.save(context.read<ProjectLibrary>());

    setState(() {
      _showBlocks = true;
    });

    if (!mounted) return;

    goToTool(context, _project, newBlock).then((_) => setState(() {}));
  }

  void _handleDeleteBlock(int index) async {
    bool? isConfirmed = await _confirmDeleteBlock();
    if (isConfirmed != true) return;

    if (!mounted) return;
    final projectLibrary = context.read<ProjectLibrary>();
    final block = _project.blocks[index];

    if (block is ImageBlock && _project.thumbnailPath == block.relativePath) _project.setDefaultThumbnail();
    if (block is ImageBlock) _fileReferences.dec(block.relativePath, projectLibrary);
    if (block is MediaPlayerBlock) _fileReferences.dec(block.relativePath, projectLibrary);

    _project.removeBlock(block, projectLibrary);

    await _projectLibraryRepo.save(projectLibrary);

    setState(() {});
  }

  void _handleDeleteAllBlocks() async {
    bool? isConfirmed = await _confirmDeleteBlock(deleteAll: true);
    if (isConfirmed != true) return;

    if (!mounted) return;
    final projectLibrary = context.read<ProjectLibrary>();
    final blocks = _project.blocks;

    for (final block in blocks) {
      if (block is ImageBlock && _project.thumbnailPath == block.relativePath) _project.setDefaultThumbnail();
      if (block is ImageBlock) _fileReferences.dec(block.relativePath, projectLibrary);
      if (block is MediaPlayerBlock) _fileReferences.dec(block.relativePath, projectLibrary);
    }

    _project.clearBlocks(projectLibrary);

    await _projectLibraryRepo.save(projectLibrary);

    setState(() {});
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
            final newTitle = await showEditTextDialog(context: context, label: 'Project title', value: _project.title);
            if (newTitle == null) return;
            _project.title = newTitle;
            if (context.mounted) await _projectLibraryRepo.save(context.read<ProjectLibrary>());
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
                tooltip: 'Project menu',
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
                    subtitle: formatSettingValues(_project.blocks[index].getSettingsFormatted()),
                    leadingPicture: circleToolIcon(_project.blocks[index].icon),
                    trailingIcon: IconButton(
                      onPressed:
                          () => {goToTool(context, _project, _project.blocks[index]).then((_) => setState(() {}))},
                      icon: const Icon(Icons.arrow_forward),
                      color: ColorTheme.primaryFixedDim,
                    ),
                    menuIconOne: IconButton(
                      onPressed: () => _handleDeleteBlock(index),
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
        title: const Text('Choose Type of Tool'),
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
                var info = blockTypeInfos[BlockType.values[index]]!;
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
      label: 'Tool title',
      value: '${info.name} ${_project.toolCounter[info.kind]! + 1}',
      isNew: true,
    );
    if (newTitle == null) return;

    _project.increaseCounter(info.kind);
    if (mounted) {
      await _projectLibraryRepo.save(context.read<ProjectLibrary>());
    }

    _createBlockAndGoToTool(info, newTitle);
  }
}
