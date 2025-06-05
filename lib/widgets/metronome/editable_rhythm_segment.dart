import 'package:flutter/material.dart';
import 'package:tiomusic/models/rhythm_group.dart';
import 'package:tiomusic/widgets/metronome/rhythm_segment.dart';

class EditableRhythmSegment extends StatelessWidget {
  final int index;
  final RhythmGroup rhythmGroup;
  final int? highlightedMainBeatIndex;
  final int? highlightedPolyBeatIndex;

  final bool canReorder;
  final bool isReordering;

  final Function() onEdit;

  const EditableRhythmSegment({
    super.key,
    required this.index,
    required this.rhythmGroup,
    required this.highlightedMainBeatIndex,
    required this.highlightedPolyBeatIndex,
    required this.canReorder,
    required this.isReordering,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: isReordering ? const Color.fromARGB(57, 47, 47, 47) : Colors.transparent,
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: ReorderableDelayedDragStartListener(
          index: index,
          enabled: canReorder,
          child: GestureDetector(
            onTap: onEdit,
            child: RhythmSegment(
              highlightedMainBeatIndex: highlightedMainBeatIndex,
              highlightedPolyBeatIndex: highlightedPolyBeatIndex,
              rhythmGroup: rhythmGroup,
              onEdit: onEdit,
            ),
          ),
        ),
      ),
    );
  }
}
