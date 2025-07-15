import 'dart:io';

import 'package:change_case/change_case.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/empty_block.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/widgets/parent_tool/empty_island_view.dart';
import 'package:tiomusic/widgets/parent_tool/existing_tools_list.dart';
import 'package:tiomusic/widgets/parent_tool/modal_bottom_sheet.dart';
import 'package:tiomusic/widgets/parent_tool/new_tools_list.dart';
import 'package:tiomusic/widgets/parent_tool/no_island_view.dart';
import 'package:tiomusic/widgets/parent_tool/selected_island_view.dart';
import 'package:tiomusic/services/file_system.dart';
import 'package:tiomusic/services/project_repository.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/util/log.dart';
import 'package:tiomusic/widgets/card_list_tile.dart';
import 'package:tiomusic/widgets/input/edit_text_dialog.dart';

class ParentIslandView extends StatefulWidget {
  final Project? project;
  final ProjectBlock toolBlock;

  const ParentIslandView({super.key, required this.project, required this.toolBlock});

  @override
  State<ParentIslandView> createState() => _ParentIslandViewState();
}

class _ParentIslandViewState extends State<ParentIslandView> {
  static final _logger = createPrefixLogger('ParentIslandView');

  late FileSystem _fs;
  late ProjectRepository _projectRepo;

  bool _empty = true;
  bool _isConnectionToAnotherToolAllowed = false;
  ProjectBlock? _loadedTool;

  int? _indexOfChosenIsland;

  @override
  void initState() {
    super.initState();

    _fs = context.read<FileSystem>();
    _projectRepo = context.read<ProjectRepository>();

    _isConnectionToAnotherToolAllowed = widget.project != null;

    if (_isConnectionToAnotherToolAllowed) {
      if (widget.toolBlock.islandToolID == null) {
        _empty = true;
      } else {
        try {
          final foundTools = widget.project!.blocks.where((block) => block.id == widget.toolBlock.islandToolID);
          if (foundTools.length > 1) {
            throw 'WARNING: When looking for the tool of an island view, there where more than one tool found! But there should only be one tool found.';
          }

          _loadedTool = foundTools.first;
          _empty = false;
        } catch (e) {
          _logger.e('Unable to find right tool for island view. Does the tool still exist?', error: e);
        }
      }
    }
  }

  void _showToolSelectionBottomSheet() {
    final l10n = context.l10n;
    final project = widget.project!;
    final filteredExistingTools = _getFilteredExistingTools();
    final filteredNewToolTypes = _getFilteredNewToolTypes();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => ModalBottomSheet(
            label: l10n.toolConnectAnother,
            titleChildren: [
              CardListTile(
                title: project.title,
                subtitle: l10n.formatDateAndTime(project.timeLastModified),
                trailingIcon: IconButton(onPressed: () {}, icon: const SizedBox()),
                leadingPicture:
                    project.thumbnailPath.isEmpty
                        ? const AssetImage(TIOMusicParams.tiomusicIconPath)
                        : FileImage(File(_fs.toAbsoluteFilePath(project.thumbnailPath))),
                onTapFunction: () {},
              ),
            ],
            contentChildren: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (filteredExistingTools.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.only(left: 32, top: 16, bottom: 8),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              l10n.toolConnectExistingTool,
                              style: TextStyle(fontSize: 18, color: ColorTheme.surfaceTint),
                            ),
                          ),
                        ),
                        ExistingToolsList(tools: filteredExistingTools, onSelectTool: _handleConnectExistingTool),
                      ],
                      Padding(
                        padding: const EdgeInsets.only(left: 32, top: 8, bottom: 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            l10n.toolConnectNewTool,
                            style: TextStyle(fontSize: 18, color: ColorTheme.surfaceTint),
                          ),
                        ),
                      ),
                      NewToolsList(
                        toolTypes: filteredNewToolTypes,
                        onSelectTool: (blockTypeInfo) => _handleConnectNewTool(blockTypeInfo, project.blocks.length),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
    ).then((_) => setState(() {}));
  }

  List<MapEntry<int, ProjectBlock>> _getFilteredExistingTools() {
    final allowedKinds = ['tuner', 'metronome', 'media_player'];
    return widget.project!.blocks
        .asMap()
        .entries
        .where((entry) => entry.value.kind != widget.toolBlock.kind && allowedKinds.contains(entry.value.kind))
        .toList();
  }

  List<BlockType> _getFilteredNewToolTypes() {
    final connectableToolTypes = [BlockType.metronome, BlockType.mediaPlayer, BlockType.tuner];
    return connectableToolTypes.where((blockType) => widget.toolBlock.kind != blockType.name.toSnakeCase()).toList();
  }

  Future<void> _handleConnectExistingTool(int index) async {
    _connectSelectedTool(index);
  }

  Future<void> _handleConnectNewTool(BlockTypeInfo blockTypeInfo, int index) async {
    await _addNewToolToProject(blockTypeInfo);
    _connectSelectedTool(0);
  }

  Future<void> _addNewToolToProject(BlockTypeInfo blockTypeInfo) async {
    final project = widget.project!;
    final newTitle = await showEditTextDialog(
      context: context,
      label: context.l10n.projectNewTool,
      value: '${blockTypeInfo.name} ${project.toolCounter[blockTypeInfo.kind]! + 1}',
      isNew: true,
    );
    if (newTitle == null) return;

    project.increaseCounter(blockTypeInfo.kind);

    project.addBlock(blockTypeInfo.createWithTitle(newTitle));
    if (mounted) await _projectRepo.saveLibrary(context.read<ProjectLibrary>());
  }

  void _connectSelectedTool(int index) async {
    _indexOfChosenIsland = index;
    // to force calling the initState of the new island, first open an empty island
    // and then in init of empty island open the new island
    _loadedTool = EmptyBlock(context.l10n.toolEmpty);
    widget.toolBlock.islandToolID = 'empty';
    await _projectRepo.saveLibrary(context.read<ProjectLibrary>());
    _empty = false;

    if (!mounted) return;
    Navigator.of(context).pop();

    setState(() {});
  }

  void _setChosenIsland() async {
    if (_indexOfChosenIsland != null) {
      _loadedTool = widget.project!.blocks[_indexOfChosenIsland!];
      widget.toolBlock.islandToolID = widget.project!.blocks[_indexOfChosenIsland!].id;
      await _projectRepo.saveLibrary(context.read<ProjectLibrary>());

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isConnectionToAnotherToolAllowed) {
      return NoIslandView(alignment: widget.toolBlock.kind == 'piano' ? Alignment.centerRight : Alignment.center);
    }

    if (_empty) return EmptyIslandView(onPressed: _showToolSelectionBottomSheet);

    return SelectedIslandView(
      loadedTool: _loadedTool,
      onShowToolSelection: _showToolSelectionBottomSheet,
      onEmptyIslandInit: _setChosenIsland,
    );
  }
}
