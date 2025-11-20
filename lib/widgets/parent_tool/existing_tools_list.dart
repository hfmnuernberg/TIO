import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/util/util_functions.dart';
import 'package:tiomusic/widgets/card_list_tile.dart';

class ExistingToolsList extends StatelessWidget {
  final List<MapEntry<int, ProjectBlock>> tools;
  final void Function(int projectToolIndex) onSelect;

  const ExistingToolsList({super.key, required this.tools, required this.onSelect});

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

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: CardListTile(
            title: tool.title,
            subtitle: formatSettingValues(tool.getSettingsFormatted(context.l10n)),
            trailingIcon: IconButton(onPressed: () => onSelect(originalIndex), icon: const SizedBox()),
            leadingPicture: circleToolIcon(tool.icon),
            onTapFunction: () => onSelect(originalIndex),
          ),
        );
      },
    );
  }
}
