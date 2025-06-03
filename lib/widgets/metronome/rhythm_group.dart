import 'package:flutter/material.dart';

class RhythmGroup extends StatelessWidget {
  final int index;
  final RhythmGroup rhythmGroup;
  final bool canReorder;
  final bool isReordering;

  final Function(int index) onEdit;

  const RhythmGroup({
    super.key,
    required this.index,
    required this.rhythmGroup,
    required this.canReorder,
    required this.isReordering,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: isReordering ? const Color.fromARGB(57, 47, 47, 47) : Colors.transparent),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child:
        ReorderableDelayedDragStartListener(
          index: index,
          enabled: canReorder,
          child: GestureDetector(
            onTap: () => onEdit(index),
            child: rhythmSegmentList[index],
          ),
        ),
      ),
    );
  }
}
