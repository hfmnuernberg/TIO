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
        // if there is no tool as island saved
        _empty = true;
      } else {
        // if there is a tool as island saved
        try {
          // search for the tool using the hashCode and the hashCode saved in the current tool
          final foundTools = widget.project!.blocks.where((block) => block.id == widget.toolBlock.islandToolID);

          // there should always only one to be found, because the id should be individual for each block
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
    if (!_isConnectionToAnotherToolAllowed) return _quickToolHintView();
    if (_empty) return _addButtonView();
    return _islandView();
  }

  // TODO: refactor all methods that return a widget
  Widget _islandView() {
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
            _getCorrectIslandView(),
            IconButton(onPressed: _chooseToolForIsland, icon: const Icon(Icons.more_vert, color: ColorTheme.primary)),
          ],
        ),
      ),
    );
  }

  Widget _addButtonView() {
    return Card(
      color: ColorTheme.surface,
      margin: const EdgeInsets.fromLTRB(TIOMusicParams.edgeInset, 8, TIOMusicParams.edgeInset, 0),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: IconButton(
        onPressed: _chooseToolForIsland,
        icon: const Icon(Icons.add_circle, color: ColorTheme.primary),
        tooltip: context.l10n.toolConnectAnother,
      ),
    );
  }

  Widget _quickToolHintView() {
    return Padding(
      padding: const EdgeInsets.only(left: TIOMusicParams.edgeInset, right: TIOMusicParams.edgeInset),
      child: Align(
        alignment: widget.toolBlock.kind == 'piano' ? Alignment.centerRight : Alignment.center,
        child: Text(context.l10n.toolUseBookmarkToSave, style: TextStyle(color: ColorTheme.surfaceTint, fontSize: 16)),
      ),
    );
  }

  Widget _getCorrectIslandView() {
    if (_loadedTool is TunerBlock) {
      return TunerIslandView(tunerBlock: _loadedTool! as TunerBlock);
    } else if (_loadedTool is MetronomeBlock) {
      return MetronomeIslandView(metronomeBlock: _loadedTool! as MetronomeBlock);
    } else if (_loadedTool is MediaPlayerBlock) {
      return MediaPlayerIslandView(mediaPlayerBlock: _loadedTool! as MediaPlayerBlock);
    } else if (_loadedTool is EmptyBlock) {
      return EmptyIsland(callOnInit: _setChosenIsland);
    } else {
      return Text(context.l10n.toolHasNoIslandView(_loadedTool.toString()));
    }
  }

  void _chooseToolForIsland() {
    final l10n = context.l10n;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => ModalBottomSheet(
            label: l10n.toolConnectAnother,
            titleChildren: [
              CardListTile(
                title: widget.project!.title,
                subtitle: l10n.formatDateAndTime(widget.project!.timeLastModified),
                trailingIcon: IconButton(onPressed: () {}, icon: const SizedBox()),
                leadingPicture:
                    widget.project!.thumbnailPath.isEmpty
                        ? const AssetImage(TIOMusicParams.tiomusicIconPath)
                        : FileImage(File(_fs.toAbsoluteFilePath(widget.project!.thumbnailPath))),
                onTapFunction: () {},
              ),
            ],
            contentChildren: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // TODO: show only when existing tools to show
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
                      ExistingToolsList(
                        project: widget.project!,
                        toolBlock: widget.toolBlock,
                        onSelectTool: _handleConnectExistingTool,
                      ),
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
                        project: widget.project!,
                        toolBlock: widget.toolBlock,
                        onSelectTool:
                            (blockTypeInfo) => _handleConnectNewTool(blockTypeInfo, widget.project!.blocks.length),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
    ).then((_) => setState(() {}));
  }

  Future<void> _handleConnectExistingTool(int index) async {
    _connectSelectedTool(index);
  }

  Future<void> _handleConnectNewTool(BlockTypeInfo blockTypeInfo, int index) async {
    await _addNewToolToProject(blockTypeInfo);
    _connectSelectedTool(0);
  }

  // TODO: check if can be merges with method from project page
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

    final newBlock = blockTypeInfo.createWithTitle(newTitle);
    project.addBlock(newBlock);
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

class NewToolsList extends StatelessWidget {
  final Project project;
  final ProjectBlock toolBlock;
  final void Function(BlockTypeInfo) onSelectTool;

  const NewToolsList({super.key, required this.project, required this.toolBlock, required this.onSelectTool});

  @override
  Widget build(BuildContext context) {
    final connectableTools = [BlockType.metronome, BlockType.mediaPlayer, BlockType.tuner];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: connectableTools.length,
      itemBuilder: (context, index) {
        if (toolBlock.kind == connectableTools[index].name.toSnakeCase()) return const SizedBox();
        var info = getBlockTypeInfos(context.l10n)[connectableTools[index]]!;
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

class ExistingToolsList extends StatelessWidget {
  final Project project;
  final ProjectBlock toolBlock;
  final void Function(int) onSelectTool;

  const ExistingToolsList({super.key, required this.project, required this.toolBlock, required this.onSelectTool});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: NeverScrollableScrollPhysics(),
      itemCount: project.blocks.length,
      itemBuilder: (context, index) {
        // TODO: get items to show first
        // don't show tools of the same type that you are currently in and
        // don't show the tool that is currently open
        if (project.blocks[index].kind == toolBlock.kind) {
          return const SizedBox();
          // only allow Tuner, Metronome and Media Player to be used as islands for now
        } else if (project.blocks[index].kind == 'tuner' ||
            project.blocks[index].kind == 'metronome' ||
            project.blocks[index].kind == 'media_player') {
          return CardListTile(
            title: project.blocks[index].title,
            subtitle: formatSettingValues(project.blocks[index].getSettingsFormatted(context.l10n)),
            trailingIcon: IconButton(onPressed: () => onSelectTool(index), icon: const SizedBox()),
            leadingPicture: circleToolIcon(project.blocks[index].icon),
            onTapFunction: () => onSelectTool(index),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }
}
