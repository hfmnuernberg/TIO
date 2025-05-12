import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/util_functions.dart';
import 'package:tiomusic/widgets/card_list_tile.dart';

class EditableToolList extends StatelessWidget {
  final Project project;
  final Future<void> Function(int oldIndex, int newIndex) onReorder;
  final Future<void> Function(int index) onDeleteBlock;

  const EditableToolList({super.key, required this.project, required this.onReorder, required this.onDeleteBlock});

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.only(bottom: 120),
      itemCount: project.blocks.length,
      onReorder: onReorder,
      buildDefaultDragHandles: false,
      itemBuilder: (context, index) {
        final l10n = context.l10n;
        final block = project.blocks[index];

        return Container(
          key: ValueKey(block.id),
          child: CardListTile(
            title: block.title,
            subtitle: formatSettingValues(block.getSettingsFormatted(l10n)),
            leadingPicture: circleToolIcon(block.icon),
            trailingIcon: IconButton(
              tooltip: l10n.commonReorder,
              icon: ReorderableDragStartListener(index: index, child: const Icon(Icons.drag_handle)),
              color: ColorTheme.primaryFixedDim,
              onPressed: () {},
            ),
            menuIconOne: IconButton(
              tooltip: l10n.projectDeleteTool,
              icon: const Icon(Icons.delete_outlined),
              color: ColorTheme.tertiary,
              onPressed: () => onDeleteBlock(index),
            ),
            onTapFunction: () {},
          ),
        );
      },
    );
  }
}
