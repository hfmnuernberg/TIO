import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/widgets/tio_icon_button.dart';

class EditProjectBar extends StatelessWidget {
  final bool isEditing;
  final VoidCallback onAddTool;
  final VoidCallback onToggleEditing;

  const EditProjectBar({super.key, required this.isEditing, required this.onAddTool, required this.onToggleEditing});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      padding: EdgeInsets.symmetric(horizontal: 12),
      color: Colors.transparent,
      height: 78,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TioIconButton.sm(
            icon: Icon(Icons.add, color: ColorTheme.tertiary),
            tooltip: context.l10n.toolAddNew,
            onPressed: onAddTool,
          ),
          TioIconButton.sm(
            icon: Icon(isEditing ? Icons.check : Icons.edit, color: ColorTheme.tertiary),
            tooltip: isEditing ? context.l10n.projectEditToolsDone : context.l10n.projectEditTools,
            onPressed: onToggleEditing,
          ),
        ],
      ),
    );
  }
}
