import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/util_functions.dart';
import 'package:tiomusic/widgets/card_list_tile.dart';

class EditableProjectList extends StatelessWidget {
  final Project project;
  final void Function(int oldIndex, int newIndex) onReorder;
  final Future<bool?> Function(ProjectBlock block) onDeleteBlock;

  const EditableProjectList({
    super.key,
    required this.project,
    required this.onReorder,
    required this.onDeleteBlock,
  });

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.only(bottom: 120),
      itemCount: project.blocks.length,
      onReorder: onReorder,
      buildDefaultDragHandles: false,
      itemBuilder: (context, index) {
        final block = project.blocks[index];

        return Container(
          key: ValueKey(block.id),
          child: CardListTile(
            title: block.title,
            subtitle: formatSettingValues(block.getSettingsFormatted(context.l10n)),
            leadingPicture: circleToolIcon(block.icon),
            trailingIcon: IconButton(
              onPressed: () {},
              icon: ReorderableDragStartListener(index: index, child: const Icon(Icons.drag_handle)),
              color: ColorTheme.surfaceTint,
            ),
            menuIconOne: IconButton(
              onPressed: () => onDeleteBlock(block),
              icon: const Icon(Icons.delete_outlined),
              color: ColorTheme.surfaceTint,
            ),
            onTapFunction: () {},
          ),
        );
      },
    );
  }
}
