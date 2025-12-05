import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/blocks/empty_block.dart';
import 'package:tiomusic/models/blocks/media_player_block.dart';
import 'package:tiomusic/models/blocks/metronome_block.dart';
import 'package:tiomusic/models/blocks/tuner_block.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/pages/media_player/media_player_island_view.dart';
import 'package:tiomusic/pages/metronome/metronome_island_view.dart';
import 'package:tiomusic/pages/tuner/tuner_island_view.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants/constants.dart';
import 'package:tiomusic/widgets/parent_tool/empty_island.dart';

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
            IconButton(
              onPressed: onShowToolSelection,
              icon: const Icon(Icons.more_vert, color: ColorTheme.primary),
            ),
          ],
        ),
      ),
    );
  }
}
