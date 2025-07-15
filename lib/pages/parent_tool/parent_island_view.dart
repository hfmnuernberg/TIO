import 'dart:io';

import 'package:change_case/change_case.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/empty_block.dart';
import 'package:tiomusic/models/blocks/media_player_block.dart';
import 'package:tiomusic/models/blocks/metronome_block.dart';
import 'package:tiomusic/models/blocks/tuner_block.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/pages/media_player/media_player_island_view.dart';
import 'package:tiomusic/pages/metronome/metronome_island_view.dart';
import 'package:tiomusic/pages/parent_tool/empty_island.dart';
import 'package:tiomusic/pages/parent_tool/modal_bottom_sheet.dart';
import 'package:tiomusic/pages/tuner/tuner_island_view.dart';
import 'package:tiomusic/services/file_system.dart';
import 'package:tiomusic/services/project_repository.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/util/log.dart';
import 'package:tiomusic/util/util_functions.dart';
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
}

class NoIslandView extends StatelessWidget {
  final Alignment alignment;

  const NoIslandView({super.key, required this.alignment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: TIOMusicParams.edgeInset, right: TIOMusicParams.edgeInset),
      child: Align(
        alignment: alignment,
        child: Text(context.l10n.toolUseBookmarkToSave, style: TextStyle(color: ColorTheme.surfaceTint, fontSize: 16)),
      ),
    );
  }
}

class EmptyIslandView extends StatelessWidget {
  final VoidCallback onPressed;

  const EmptyIslandView({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: ColorTheme.surface,
      margin: const EdgeInsets.fromLTRB(TIOMusicParams.edgeInset, 8, TIOMusicParams.edgeInset, 0),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: IconButton(
        onPressed: onPressed,
        icon: const Icon(Icons.add_circle, color: ColorTheme.primary),
        tooltip: context.l10n.toolConnectAnother,
      ),
    );
  }
}

class SelectedIslandView extends StatelessWidget {
  final ProjectBlock? loadedTool;
  final VoidCallback onShowToolSelection;
  final VoidCallback onEmptyIslandInit;

  const SelectedIslandView({
    super.key,
    required this.loadedTool,
    required this.onShowToolSelection,
    required this.onEmptyIslandInit,
  });

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (loadedTool is TunerBlock) {
      child = TunerIslandView(tunerBlock: loadedTool! as TunerBlock);
    } else if (loadedTool is MetronomeBlock) {
      child = MetronomeIslandView(metronomeBlock: loadedTool! as MetronomeBlock);
    } else if (loadedTool is MediaPlayerBlock) {
      child = MediaPlayerIslandView(mediaPlayerBlock: loadedTool! as MediaPlayerBlock);
    } else if (loadedTool is EmptyBlock) {
      child = EmptyIsland(callOnInit: onEmptyIslandInit);
    } else {
      child = Text(context.l10n.toolHasNoIslandView(loadedTool.toString()));
    }

    return Card(
      color: ColorTheme.surface,
      margin: const EdgeInsets.fromLTRB(TIOMusicParams.edgeInset, 8, TIOMusicParams.edgeInset, 0),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            child,
            IconButton(onPressed: onShowToolSelection, icon: const Icon(Icons.more_vert, color: ColorTheme.primary)),
          ],
        ),
      ),
    );
  }
}

class ExistingToolsList extends StatelessWidget {
  final List<MapEntry<int, ProjectBlock>> tools;
  final void Function(int) onSelectTool;

  const ExistingToolsList({super.key, required this.tools, required this.onSelectTool});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: NeverScrollableScrollPhysics(),
      itemCount: tools.length,
      itemBuilder: (context, index) {
        final toolEntry = tools[index];
        final tool = toolEntry.value;
        final originalIndex = toolEntry.key;

        return CardListTile(
          title: tool.title,
          subtitle: formatSettingValues(tool.getSettingsFormatted(context.l10n)),
          trailingIcon: IconButton(onPressed: () => onSelectTool(originalIndex), icon: const SizedBox()),
          leadingPicture: circleToolIcon(tool.icon),
          onTapFunction: () => onSelectTool(originalIndex),
        );
      },
    );
  }
}

class NewToolsList extends StatelessWidget {
  final List<BlockType> toolTypes;
  final void Function(BlockTypeInfo) onSelectTool;

  const NewToolsList({super.key, required this.toolTypes, required this.onSelectTool});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: toolTypes.length,
      itemBuilder: (context, index) {
        final blockType = toolTypes[index];
        final info = getBlockTypeInfos(context.l10n)[blockType]!;

        return CardListTile(
          title: info.name,
          subtitle: info.description,
          trailingIcon: IconButton(
            onPressed: () => onSelectTool(info),
            icon: const Icon(Icons.add),
            color: ColorTheme.surfaceTint,
          ),
          leadingPicture: circleToolIcon(info.icon),
          onTapFunction: () => onSelectTool(info),
        );
      },
    );
  }
}
