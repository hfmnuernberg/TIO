import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/util/util_functions.dart';
import 'package:tiomusic/widgets/card_list_tile.dart';

class NewToolsList extends StatelessWidget {
  final List<BlockType> tools;
  final void Function(BlockType) onSelect;

  const NewToolsList({super.key, required this.tools, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tools.length,
      itemBuilder: (context, index) {
        final blockType = tools[index];
        final info = getBlockTypeInfos(context.l10n)[blockType]!;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: CardListTile(
            title: info.name,
            subtitle: info.description,
            trailingIcon: IconButton(
              onPressed: () => onSelect(blockType),
              icon: const Icon(Icons.add),
              color: ColorTheme.surfaceTint,
            ),
            leadingPicture: circleToolIcon(info.icon),
            onTapFunction: () => onSelect(blockType),
          ),
        );
      },
    );
  }
}
