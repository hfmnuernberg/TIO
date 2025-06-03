import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tiomusic/pages/metronome/rhythm/rhythm_segment.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/widgets/metronome/editable_rhythm_segment.dart';

class RhythmRow extends StatefulWidget {
  final List<RhythmSegment> rhythmSegmentList;
  final String label;
  final bool canDeleteLastSegment;
  final Widget addSecondaryAction;

  final Function() onAdd;
  final Function(int index) onDelete;
  final Function(int index) onEdit;
  final Function(int oldIndex, int newIndex) onReorder;

  const RhythmRow({
    super.key,
    required this.rhythmSegmentList,
    required this.label,
    required this.canDeleteLastSegment,
    required this.onAdd,
    required this.onDelete,
    required this.onEdit,
    required this.onReorder,
    required this.addSecondaryAction,
  });

  @override
  State<RhythmRow> createState() => _RhythmRowState();
}

class _RhythmRowState extends State<RhythmRow> with RouteAware {
  bool isReordering = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: MetronomeParams.heightRhythmGroups,
          child: Padding(
            padding: const EdgeInsets.all(TIOMusicParams.edgeInset),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                ReorderableListView.builder(
                  proxyDecorator: (child, index, animation) => AnimatedBuilder(
                    animation: animation,
                    builder: (context, child) {
                      final double animValue = Curves.easeInOut.transform(animation.value);
                      final double elevation = lerpDouble(0, 6, animValue)!;
                      return Material(elevation: elevation, color: Colors.transparent, shadowColor: Colors.transparent, child: child);
                    },
                    child: child,
                  ),
                  buildDefaultDragHandles: false,
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemCount: widget.rhythmSegmentList.length,
                  itemBuilder: (context, index) {
                    return Dismissible(
                      key: Key(index.toString()),
                      direction: widget.canDeleteLastSegment || widget.rhythmSegmentList.length > 1
                          ? DismissDirection.up
                          : DismissDirection.none,
                      onDismissed: (_) => widget.onDelete(index),
                      background: const Icon(Icons.delete_outlined, color: ColorTheme.primary),
                      child: EditableRhythmSegment(
                        index: index,
                        rhythmSegment: widget.rhythmSegmentList[index],
                        canReorder: widget.rhythmSegmentList.length > 1,
                        isReordering: isReordering,
                        onEdit: (index) => widget.onEdit(index),
                      ),
                    );
                  },
                  onReorderStart: (_) => setState(() => isReordering = true),
                  onReorderEnd: (_) => setState(() => isReordering = false),
                  onReorder: widget.onReorder,
                ),
                const SizedBox(width: 4),
                CircleAvatar(
                  radius: TIOMusicParams.rhythmPlusButtonSize,
                  backgroundColor: Colors.white,
                  child: Center(
                    child: IconButton(
                      iconSize: TIOMusicParams.rhythmPlusButtonSize,
                      onPressed: () => widget.onAdd(),
                      icon: const Icon(Icons.add, color: ColorTheme.surfaceTint),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(left: TIOMusicParams.edgeInset, right: TIOMusicParams.edgeInset),
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: ColorTheme.surface, width: 2),
                bottom: BorderSide(color: ColorTheme.surface, width: 2),
              ),
            ),
            height: TIOMusicParams.rhythmPlusButtonSize * 2.5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.label,
                  style: const TextStyle(color: ColorTheme.primary),
                ),
                widget.addSecondaryAction,
              ],
            ),
          ),
        ),
      ],
    );
  }
}
