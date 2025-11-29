import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/image_block.dart';
import 'package:tiomusic/models/blocks/media_player_block.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/pages/project_page/edit_project_bar.dart';
import 'package:tiomusic/pages/project_page/choose_tool_page.dart';
import 'package:tiomusic/pages/project_page/editable_tool_list.dart';
import 'package:tiomusic/pages/project_page/export_project.dart';
import 'package:tiomusic/pages/project_page/tool_list.dart';
import 'package:tiomusic/services/file_references.dart';
import 'package:tiomusic/services/project_repository.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/util/app_orientation.dart';
import 'package:tiomusic/util/tool_navigation_utils.dart';
import 'package:tiomusic/util/tutorial_util.dart';
import 'package:tiomusic/util/util_functions.dart';
import 'package:tiomusic/widgets/common_buttons.dart';
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
  late ProjectRepository _projectRepo;
  late FileReferences _fileReferences;

  late bool _showBlocks;
  bool _isEditing = false;

  late Project _project;
  bool _withoutProject = false;

  final TextEditingController _titleController = TextEditingController();

  final Tutorial _tutorial = Tutorial();
  final GlobalKey _keyChangeTitle = GlobalKey();
  final GlobalKey _keyChangeToolOrder = GlobalKey();

  @override
  void initState() {
    super.initState();

    _projectRepo = context.read<ProjectRepository>();
    _fileReferences = context.read<FileReferences>();

    _withoutProject = widget.withoutRealProject;

    _project = Provider.of<Project>(context, listen: false);

    _titleController.text = _project.title;

    if (_project.blocks.isEmpty) {
      _showBlocks = false;
    } else {
      _showBlocks = true;
    }

    if (widget.goStraightToTool) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        goToTool(
          context,
          _project,
          widget.toolToOpenDirectly!,
          pianoAlreadyOn: widget.pianoAlreadyOn,
        ).then((_) => setState(() {}));
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _project.timeLastModified = getCurrentDateTime();

      AppOrientation.set(context, policy: OrientationPolicy.phonePortrait);

      if (!widget.goStraightToTool &&
          _project.blocks.isNotEmpty &&
          context.read<ProjectLibrary>().showProjectPageTutorial) {
        _createTutorial();
        _tutorial.show(context);
      }
    });
  }

  @override
  void dispose() {
    _tutorial.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _toggleEditingMode() => setState(() => _isEditing = !_isEditing);

  void _createTutorial() {
    final l10n = context.l10n;
    final targets = <CustomTargetFocus>[
      CustomTargetFocus(
        _keyChangeTitle,
        l10n.projectTutorialEditTitle,
        pointingDirection: PointingDirection.up,
        alignText: ContentAlign.bottom,
        shape: ShapeLightFocus.RRect,
      ),
      CustomTargetFocus(
        _keyChangeToolOrder,
        l10n.projectTutorialChangeToolOrder,
        buttonsPosition: ButtonsPosition.top,
        pointingDirection: PointingDirection.down,
        alignText: ContentAlign.top,
        shape: ShapeLightFocus.RRect,
      ),
    ];

    _tutorial.create(targets.map((e) => e.targetFocus).toList(), () async {
      context.read<ProjectLibrary>().showProjectPageTutorial = false;
      await _projectRepo.saveLibrary(context.read<ProjectLibrary>());
    }, context);
  }

  Future<void> _handleDeleteBlock(int index) async {
    bool? isConfirmed = await _confirmDeleteBlock();
    if (isConfirmed != true) return;

    if (!mounted) return;
    final projectLibrary = context.read<ProjectLibrary>();
    final block = _project.blocks[index];

    if (block is ImageBlock && _project.thumbnailPath == block.relativePath) _project.setDefaultThumbnail();
    if (block is ImageBlock) _fileReferences.dec(block.relativePath, projectLibrary);
    if (block is MediaPlayerBlock) _fileReferences.dec(block.relativePath, projectLibrary);

    _project.removeBlock(block, projectLibrary);

    await _projectRepo.saveLibrary(projectLibrary);

    setState(() {});
  }

  Future<void> _handleDeleteAllBlocks() async {
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

    await _projectRepo.saveLibrary(projectLibrary);

    setState(() {});
  }

  Future<bool?> _confirmDeleteBlock({bool deleteAll = false}) => showDialog<bool>(
    context: context,
    builder: (context) {
      final l10n = context.l10n;

      return AlertDialog(
        title: Text(l10n.commonDelete, style: TextStyle(color: ColorTheme.primary)),
        content: deleteAll
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

  Future<void> _createBlockAndGoToTool(BlockTypeInfo info, String blockTitle) async {
    final projectLibrary = context.read<ProjectLibrary>();

    if (_withoutProject) {
      projectLibrary.addProject(_project);
      _withoutProject = false;
    }

    final newBlock = info.createWithTitle(blockTitle);

    _project.addBlock(newBlock);
    await _projectRepo.saveLibrary(projectLibrary);

    setState(() => _showBlocks = true);

    if (!mounted) return;

    final result = await goToTool(context, _project, newBlock);

    if (!mounted) return;

    final canShowTutorial =
        result is Map && result[ReturnAction.showTutorial.name] == true && projectLibrary.showProjectPageTutorial;
    if (canShowTutorial) {
      _createTutorial();
      _tutorial.show(context);
    }
    setState(() {});
  }

  Future<void> _handleReorder(int oldIndex, int newIndex) async {
    final mutableBlocks = _project.blocks.toList();
    final block = mutableBlocks.removeAt(oldIndex);
    mutableBlocks.insert(newIndex > oldIndex ? newIndex - 1 : newIndex, block);
    _project.blocks = mutableBlocks;

    await _projectRepo.saveLibrary(context.read<ProjectLibrary>());

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_showBlocks) {
      return _buildProjectPage(context);
    } else {
      return ChooseToolPage(
        onBack: () => _project.blocks.isEmpty ? Navigator.of(context).pop() : setState(() => _showBlocks = true),
        onNewToolSelected: _onNewToolTilePressed,
      );
    }
  }

  Widget _buildProjectPage(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
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
            if (context.mounted) await _projectRepo.saveLibrary(context.read<ProjectLibrary>());
            setState(() {});
          },
          child: Text(
            key: _keyChangeTitle,
            _project.title,
            style: const TextStyle(color: ColorTheme.primary, fontSize: TIOMusicParams.titleFontSize),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
                tooltip: context.l10n.projectMenu,
              );
            },
            style: const MenuStyle(
              backgroundColor: WidgetStatePropertyAll(ColorTheme.surface),
              elevation: WidgetStatePropertyAll(0),
            ),
            menuChildren: [
              MenuItemButton(
                onPressed: () => exportProject(context, _project),
                child: Text(context.l10n.projectExport, style: TextStyle(color: ColorTheme.primary)),
              ),
              MenuItemButton(
                onPressed: () => setState(() {
                  _showBlocks = false;
                  _isEditing = false;
                }),
                child: Text(context.l10n.toolAddNew, style: TextStyle(color: ColorTheme.primary)),
              ),
              MenuItemButton(
                onPressed: _toggleEditingMode,
                child: Text(
                  _isEditing ? context.l10n.projectEditToolsDone : context.l10n.projectEditTools,
                  style: TextStyle(color: ColorTheme.primary),
                ),
              ),
              MenuItemButton(
                onPressed: _handleDeleteAllBlocks,
                child: Text(context.l10n.projectDeleteAllTools, style: TextStyle(color: ColorTheme.primary)),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        fit: StackFit.expand,
        children: [
          FittedBox(fit: BoxFit.cover, child: Image.asset('assets/images/tiomusic-bg.png')),
          if (_isEditing)
            EditableToolList(project: _project, onReorder: _handleReorder, onDeleteBlock: _handleDeleteBlock)
          else
            ToolList(
              project: _project,
              onOpenTool: (block) async {
                await goToTool(context, _project, block);
                setState(() {});
              },
            ),
        ],
      ),
      bottomNavigationBar: EditProjectBar(
        key: _keyChangeToolOrder,
        isEditing: _isEditing,
        onAddTool: () => setState(() {
          _showBlocks = false;
          _isEditing = false;
        }),
        onToggleEditing: _toggleEditingMode,
      ),
    );
  }

  Future<void> _onNewToolTilePressed(BlockTypeInfo info) async {
    final newTitle = await showEditTextDialog(
      context: context,
      label: context.l10n.projectNewTool,
      value: '${info.name} ${_project.toolCounter[info.kind]! + 1}',
      isNew: true,
    );
    if (newTitle == null) return;

    _project.increaseCounter(info.kind);
    if (mounted) {
      await _projectRepo.saveLibrary(context.read<ProjectLibrary>());
    }

    _createBlockAndGoToTool(info, newTitle);
  }
}
