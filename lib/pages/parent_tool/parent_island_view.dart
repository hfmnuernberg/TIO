import 'dart:io';

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
import 'package:tiomusic/pages/tuner/tuner_island_view.dart';
import 'package:tiomusic/services/file_system.dart';
import 'package:tiomusic/services/project_library_repository.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/util/log.dart';
import 'package:tiomusic/util/util_functions.dart';
import 'package:tiomusic/widgets/card_list_tile.dart';

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
  late ProjectLibraryRepository _projectLibraryRepo;

  bool _empty = true;
  bool _possibleToolForIslandExists = false;
  ProjectBlock? _loadedTool;

  int? _indexOfChoosenIsland;

  @override
  void initState() {
    super.initState();

    _fs = context.read<FileSystem>();
    _projectLibraryRepo = context.read<ProjectLibraryRepository>();

    // if project is null (if we are in a quick tool), there is no possible tool to open
    _possibleToolForIslandExists = checkIslandPossible(widget.project, widget.toolBlock);

    if (_possibleToolForIslandExists) {
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
    // if possible tool exists
    if (_possibleToolForIslandExists) {
      // if island is empty
      if (_empty) {
        // show the add button
        return _addButtonView();
      } else {
        // else show the island view
        return _islandView();
      }
      // else if no possible tool exists
    } else {
      // if tool is quick tool
      if (widget.project == null) {
        // show hint for quick tool
        return _quickToolHintView();
      } else {
        // else show nothing
        return _voidView();
      }
    }
  }

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
      child: IconButton(onPressed: _chooseToolForIsland, icon: const Icon(Icons.add_circle, color: ColorTheme.primary)),
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

  Widget _voidView() {
    return const SizedBox();
  }

  Widget _getCorrectIslandView() {
    if (_loadedTool is TunerBlock) {
      return TunerIslandView(tunerBlock: _loadedTool! as TunerBlock);
    } else if (_loadedTool is MetronomeBlock) {
      return MetronomeIslandView(metronomeBlock: _loadedTool! as MetronomeBlock);
    } else if (_loadedTool is MediaPlayerBlock) {
      return MediaPlayerIslandView(mediaPlayerBlock: _loadedTool! as MediaPlayerBlock);
    } else if (_loadedTool is EmptyBlock) {
      return EmptyIsland(callOnInit: _setChoosenIsland);
    } else {
      return Text(context.l10n.toolHasNoIslandView(_loadedTool.toString()));
    }
  }

  void _chooseToolForIsland() {
    ourModalBottomSheet(
      context,
      [
        CardListTile(
          title: widget.project!.title,
          subtitle: context.l10n.formatDateAndTime(widget.project!.timeLastModified),
          trailingIcon: IconButton(onPressed: () {}, icon: const SizedBox()),
          leadingPicture:
              widget.project!.thumbnailPath.isEmpty
                  ? const AssetImage(TIOMusicParams.tiomusicIconPath)
                  : FileImage(File(_fs.toAbsoluteFilePath(widget.project!.thumbnailPath))),
          onTapFunction: () {},
        ),
      ],
      [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: TIOMusicParams.smallSpaceAboveList),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.project!.blocks.length,
              itemBuilder: (context, index) {
                if (widget.project!.blocks.length < 2) {
                  return Card(child: Text(context.l10n.toolNoOtherToolAvailable));
                } else {
                  // don't show tools of the same type that you are currently in and
                  // don't show the tool that is currently open
                  if (widget.project!.blocks[index].kind == widget.toolBlock.kind) {
                    return const SizedBox();
                    // only allow Tuner, Metronome and Media Player to be used as islands for now
                  } else if (widget.project!.blocks[index].kind == 'tuner' ||
                      widget.project!.blocks[index].kind == 'metronome' ||
                      widget.project!.blocks[index].kind == 'media_player') {
                    return CardListTile(
                      title: widget.project!.blocks[index].title,
                      subtitle: formatSettingValues(widget.project!.blocks[index].getSettingsFormatted(context.l10n)),
                      trailingIcon: IconButton(onPressed: () => _onToolTap(index), icon: const SizedBox()),
                      leadingPicture: circleToolIcon(widget.project!.blocks[index].icon),
                      onTapFunction: () => _onToolTap(index),
                    );
                  } else {
                    return const SizedBox();
                  }
                }
              },
            ),
          ),
        ),
      ],
    ).then((_) => setState(() {}));
  }

  void _onToolTap(int index) async {
    _indexOfChoosenIsland = index;
    // to force calling the initState of the new island, first open an empty island
    // and then in init of empty island open the new island
    _loadedTool = EmptyBlock(context.l10n.toolEmpty);
    widget.toolBlock.islandToolID = 'empty';
    await _projectLibraryRepo.save(context.read<ProjectLibrary>());
    _empty = false;

    if (!mounted) return;
    Navigator.of(context).pop();

    setState(() {});
  }

  void _setChoosenIsland() async {
    if (_indexOfChoosenIsland != null) {
      _loadedTool = widget.project!.blocks[_indexOfChoosenIsland!];
      widget.toolBlock.islandToolID = widget.project!.blocks[_indexOfChoosenIsland!].id;
      await _projectLibraryRepo.save(context.read<ProjectLibrary>());

      setState(() {});
    }
  }
}
