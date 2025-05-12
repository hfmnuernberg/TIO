import 'package:flutter/material.dart';
import 'package:tiomusic/l10n/app_localizations_extension.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/widgets/small_icon_button.dart';

class EditProjectsBar extends StatelessWidget {
  final bool isEditing;
  final VoidCallback onAddProject;
  final VoidCallback onToggleEditing;

  const EditProjectsBar({
    super.key,
    required this.isEditing,
    required this.onAddProject,
    required this.onToggleEditing,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Stack(
        children: [
          Positioned.fill(
            child: Listener(behavior: HitTestBehavior.translucent, onPointerDown: (_) {}, child: const SizedBox()),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SmallIconButton(
                  icon: Icon(Icons.add, color: ColorTheme.tertiary),
                  tooltip: context.l10n.projectsAddNew,
                  onPressed: onAddProject,
                ),
                SmallIconButton(
                  icon: Icon(isEditing ? Icons.check : Icons.edit, color: ColorTheme.tertiary),
                  tooltip: isEditing ? context.l10n.projectsEditDone : context.l10n.projectsEdit,
                  onPressed: onToggleEditing,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
