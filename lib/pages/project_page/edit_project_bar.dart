import 'package:flutter/material.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/widgets/small_icon_button.dart';

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
          SmallIconButton(icon: Icon(Icons.add, color: ColorTheme.tertiary), onPressed: onAddTool),
          SmallIconButton(
            icon: Icon(isEditing ? Icons.check : Icons.edit, color: ColorTheme.tertiary),
            onPressed: onToggleEditing,
          ),
        ],
      ),
    );
  }
}
