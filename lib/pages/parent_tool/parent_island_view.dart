import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiomusic/models/blocks/empty_block.dart';
import 'package:tiomusic/models/blocks/media_player_block.dart';
import 'package:tiomusic/models/blocks/metronome_block.dart';
import 'package:tiomusic/models/blocks/tuner_block.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/models/file_io.dart';
import 'package:tiomusic/pages/media_player/media_player_island_view.dart';
import 'package:tiomusic/pages/metronome/metronome_island_view.dart';
import 'package:tiomusic/pages/parent_tool/empty_island.dart';
import 'package:tiomusic/pages/tuner/tuner_island_view.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/util/util_functions.dart';
import 'package:tiomusic/widgets/card_list_tile.dart';

class ParentIslandView extends StatefulWidget {
  final Project? project;
  final ProjectBlock toolBlock;

  const ParentIslandView({
    required this.project, required this.toolBlock, super.key,
  });

  @override
  State<ParentIslandView> createState() => _ParentIslandViewState();
}

class _ParentIslandViewState extends State<ParentIslandView> {
  bool _empty = true;
  bool _possibleToolForIslandExists = false;
  ProjectBlock? _loadedTool;

  final EmptyBlock _emptyBlock = EmptyBlock();
  int? _indexOfChoosenIsland;

  @override
  void initState() {
    super.initState();

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
            throw ("WARNING: When looking for the tool of an island view, there where more than one tool found! But there should only be one tool found.");
          }
          _loadedTool = foundTools.first;
          _empty = false;
        } catch (e) {
          debugPrint(
              "Something went wrong trying to find the right tool for an island view: $e. Maybe the tool doesn't exist anymore.");
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
      elevation: 0.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _getCorrectIslandView(),
            IconButton(
              onPressed: () => _chooseToolForIsland(),
              icon: const Icon(
                Icons.more_vert,
                color: ColorTheme.primary,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _addButtonView() {
    return Card(
      color: ColorTheme.surface,
      margin: const EdgeInsets.fromLTRB(TIOMusicParams.edgeInset, 8, TIOMusicParams.edgeInset, 0),
      elevation: 0.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: IconButton(
        onPressed: () {
          // open bottom sheet to choose another tool of the same project as island
          _chooseToolForIsland();
        },
        icon: const Icon(Icons.add_circle, color: ColorTheme.primary),
      ),
    );
  }

  Widget _quickToolHintView() {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
      child: Align(
        alignment: widget.toolBlock.kind == "piano" ? Alignment.centerRight : Alignment.center,
        child: const Text(
          "Use bookmark to save a tool",
          style: TextStyle(
            color: ColorTheme.surfaceTint,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _voidView() {
    return const SizedBox();
  }

  Widget _getCorrectIslandView() {
    if (_loadedTool is TunerBlock) {
      return TunerIslandView(tunerBlock: _loadedTool as TunerBlock);
    } else if (_loadedTool is MetronomeBlock) {
      return MetronomeIslandView(metronomeBlock: _loadedTool as MetronomeBlock);
    } else if (_loadedTool is MediaPlayerBlock) {
      return MediaPlayerIslandView(mediaPlayerBlock: _loadedTool as MediaPlayerBlock);
    } else if (_loadedTool is EmptyBlock) {
      return EmptyIsland(callOnInit: _setChoosenIsland);
    } else {
      return Text("$_loadedTool has no Island View!");
    }
  }

  void _chooseToolForIsland() {
    ourModalBottomSheet(context, [
      CardListTile(
        title: widget.project!.title,
        subtitle: getDateAndTimeFormatted(widget.project!.timeLastModified),
        trailingIcon: IconButton(onPressed: () {}, icon: const SizedBox()),
        leadingPicture: widget.project!.thumbnail,
        onTapFunction: () {},
      ),
    ], [
      Expanded(
        child: Padding(
          padding: const EdgeInsets.only(top: TIOMusicParams.smallSpaceAboveList),
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: widget.project!.blocks.length,
            itemBuilder: (BuildContext context, int index) {
              if (widget.project!.blocks.length < 2) {
                return const Card(
                    child: Text(
                        "There is no other tool in this project. Please save another tool first to use it as an island."));
              } else {
                // don't show tools of the same type that you are currently in and
                // don't show the tool that is currently open
                if (widget.project!.blocks[index].kind == widget.toolBlock.kind) {
                  return const SizedBox();
                  // only allow Tuner, Metronome and Media Player to be used as islands for now
                } else if (widget.project!.blocks[index].kind == "tuner" ||
                    widget.project!.blocks[index].kind == "metronome" ||
                    widget.project!.blocks[index].kind == "media_player") {
                  return CardListTile(
                    title: widget.project!.blocks[index].title,
                    subtitle: formatSettingValues(widget.project!.blocks[index].getSettingsFormatted()),
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
    ]).then((_) => setState(() {}));
  }

  void _onToolTap(int index) {
    _indexOfChoosenIsland = index;
    // to force calling the initState of the new island, first open an empty island
    // and then in init of empty island open the new island
    _loadedTool = _emptyBlock;
    widget.toolBlock.islandToolID = "empty";
    FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());
    _empty = false;

    Navigator.of(context).pop();

    setState(() {});
  }

  void _setChoosenIsland() {
    if (_indexOfChoosenIsland != null) {
      _loadedTool = widget.project!.blocks[_indexOfChoosenIsland!];
      widget.toolBlock.islandToolID = widget.project!.blocks[_indexOfChoosenIsland!].id;
      FileIO.saveProjectLibraryToJson(context.read<ProjectLibrary>());

      setState(() {});
    }
  }
}
