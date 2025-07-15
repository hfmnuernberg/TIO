import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/util/util_functions.dart';
import 'package:tiomusic/widgets/card_list_tile.dart';

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
