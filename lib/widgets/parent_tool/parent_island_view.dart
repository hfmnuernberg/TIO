import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/empty_block.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/widgets/input/flat_edit_text_dialog.dart';
import 'package:tiomusic/widgets/parent_tool/empty_island_view.dart';
import 'package:tiomusic/widgets/parent_tool/existing_tools_list.dart';
import 'package:tiomusic/widgets/parent_tool/modal_bottom_sheet.dart';
import 'package:tiomusic/widgets/parent_tool/new_tools_list.dart';
import 'package:tiomusic/widgets/parent_tool/no_island_view.dart';
import 'package:tiomusic/widgets/parent_tool/selected_island_view.dart';
import 'package:tiomusic/services/file_system.dart';
import 'package:tiomusic/services/project_repository.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants/constants.dart';
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
  static final logger = createPrefixLogger('ParentIslandView');

  late FileSystem fs;
  late ProjectRepository projectRepo;

  bool empty = true;
  bool isConnectionToAnotherToolAllowed = false;
  ProjectBlock? loadedTool;

  int? indexOfChosenIsland;

  @override
  void initState() {
    super.initState();

    fs = context.read<FileSystem>();
    projectRepo = context.read<ProjectRepository>();

    isConnectionToAnotherToolAllowed = widget.project != null;

    if (isConnectionToAnotherToolAllowed) {
      if (widget.toolBlock.islandToolID == null) {
        empty = true;
      } else {
        try {
          final foundTools = widget.project!.blocks.where((block) => block.id == widget.toolBlock.islandToolID);
          if (foundTools.length > 1) {
            throw 'WARNING: When looking for the tool of an island view, there where more than one tool found! But there should only be one tool found.';
          }

          loadedTool = foundTools.first;
          empty = false;
        } catch (e) {
          logger.e('Unable to find right tool for island view. Does the tool still exist?', error: e);
        }
      }
    }
  }

  void showToolSelectionBottomSheet() {
    final l10n = context.l10n;
    final project = widget.project!;
    final filteredExistingTools = getFilteredExistingTools();
    final filteredNewToolTypes = getFilteredNewToolTypes();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ModalBottomSheet(
        label: l10n.toolConnectAnother,
        titleChildren: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: CardListTile(
              title: project.title,
              subtitle: l10n.formatDateAndTime(project.timeLastModified),
              trailingIcon: IconButton(onPressed: () {}, icon: const SizedBox()),
              leadingPicture: project.thumbnailPath.isEmpty
                  ? const AssetImage(TIOMusicParams.tiomusicIconPath)
                  : FileImage(File(fs.toAbsoluteFilePath(project.thumbnailPath))),
              onTapFunction: () {},
            ),
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
                    ExistingToolsList(tools: filteredExistingTools, onSelect: handleConnectExistingTool),
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
                  NewToolsList(tools: filteredNewToolTypes, onSelect: handleConnectNewTool),
                ],
              ),
            ),
          ),
        ],
      ),
    ).then((_) => setState(() {}));
  }

  List<MapEntry<int, ProjectBlock>> getFilteredExistingTools() {
    final allowedKinds = ['tuner', 'metronome', 'media_player'];

    return widget.project!.blocks.asMap().entries.where((entry) {
      final isAllowedKind = allowedKinds.contains(entry.value.kind);
      final isNotSelf = entry.value.id != widget.toolBlock.id;

      final isSameKind = entry.value.kind == widget.toolBlock.kind;
      final allowSameKind = widget.toolBlock.kind == 'media_player';

      return isAllowedKind && isNotSelf && (!isSameKind || allowSameKind);
    }).toList();
  }

  List<BlockType> getFilteredNewToolTypes() {
    final connectableToolTypes = [BlockType.metronome, BlockType.mediaPlayer, BlockType.tuner];

    final allowSameKind = widget.toolBlock.kind == 'media_player';

    return connectableToolTypes.where((blockType) {
      if (allowSameKind) return true;

      final blockTypeKind = getBlockTypeInfos(context.l10n)[blockType]!.kind;
      return widget.toolBlock.kind != blockTypeKind;
    }).toList();
  }

  Future<void> handleConnectExistingTool(int projectToolIndex) async {
    connectSelectedTool(projectToolIndex);
  }

  Future<void> handleConnectNewTool(BlockType blockType) async {
    await addNewToolToProject(blockType);
    connectSelectedTool(0);
  }

  Future<void> addNewToolToProject(BlockType blockType) async {
    final project = widget.project!;
    final info = getBlockTypeInfos(context.l10n)[blockType]!;

    final newTitle = await _buildTextDialog(info);
    if (newTitle == null) return;

    project.increaseCounter(info.kind);

    project.addBlock(info.createWithTitle(newTitle));
    if (mounted) await projectRepo.saveLibrary(context.read<ProjectLibrary>());
  }

  Future<String?> _buildTextDialog(BlockTypeInfo info) {
    final label = context.l10n.projectNewTool;
    final initialTitle = '${info.name} ${widget.project!.toolCounter[info.kind]! + 1}';
    if (widget.toolBlock.kind == BlockType.piano.name) {
      return showFlatEditTextDialog(context: context, label: label, value: initialTitle, isNew: true);
    } else {
      return showEditTextDialog(context: context, label: label, value: initialTitle, isNew: true);
    }
  }

  void connectSelectedTool(int projectToolIndex) async {
    indexOfChosenIsland = projectToolIndex;
    // to force calling the initState of the new island, first open an empty island
    // and then in init of empty island open the new island
    loadedTool = EmptyBlock(context.l10n.toolEmpty);
    widget.toolBlock.islandToolID = 'empty';
    await projectRepo.saveLibrary(context.read<ProjectLibrary>());
    empty = false;

    if (!mounted) return;
    Navigator.of(context).pop();

    setState(() {});
  }

  void setChosenIsland() async {
    if (indexOfChosenIsland != null) {
      loadedTool = widget.project!.blocks[indexOfChosenIsland!];
      widget.toolBlock.islandToolID = widget.project!.blocks[indexOfChosenIsland!].id;
      await projectRepo.saveLibrary(context.read<ProjectLibrary>());

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isConnectionToAnotherToolAllowed) {
      return NoIslandView(alignment: widget.toolBlock.kind == 'piano' ? Alignment.centerRight : Alignment.center);
    }

    if (empty) return EmptyIslandView(onPressed: showToolSelectionBottomSheet);

    return SelectedIslandView(
      loadedTool: loadedTool,
      onShowToolSelection: showToolSelectionBottomSheet,
      onEmptyIslandInit: setChosenIsland,
    );
  }
}
