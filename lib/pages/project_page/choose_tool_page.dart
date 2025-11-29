import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/util/util_functions.dart';
import 'package:tiomusic/widgets/card_list_tile.dart';

class ChooseToolPage extends StatelessWidget {
  final VoidCallback onBack;
  final ValueChanged<BlockTypeInfo> onNewToolSelected;

  const ChooseToolPage({super.key, required this.onBack, required this.onNewToolSelected});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final blockTypeInfos = getBlockTypeInfos(l10n);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(l10n.projectEmpty),
        backgroundColor: ColorTheme.surfaceBright,
        foregroundColor: ColorTheme.primary,
        leading: IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back)),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          FittedBox(fit: BoxFit.cover, child: Image.asset('assets/images/tiomusic-bg.png')),
          Semantics(
            label: l10n.projectToolListEmpty,
            child: ListView.builder(
              padding: const EdgeInsets.only(top: TIOMusicParams.smallSpaceAboveList + 2),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: BlockType.values.length,
              itemBuilder: (context, index) {
                final blockType = BlockType.values[index];
                final info = blockTypeInfos[blockType]!;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: CardListTile(
                    title: info.name,
                    subtitle: info.description,
                    trailingIcon: IconButton(
                      onPressed: () => onNewToolSelected(info),
                      icon: const Icon(Icons.add),
                      color: ColorTheme.surfaceTint,
                    ),
                    leadingPicture: circleToolIcon(info.icon),
                    onTapFunction: () => onNewToolSelected(info),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
