// List item in rhythm generator setting page that shows a note value

import 'package:flutter/material.dart';
import 'package:tiomusic/models/note_handler.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';

class RhythmGeneratorSettingListItem extends StatefulWidget {
  final String noteKey;
  final Function() onTap;
  final bool hasBorder;

  const RhythmGeneratorSettingListItem({super.key, required this.noteKey, required this.onTap, this.hasBorder = false});

  @override
  State<RhythmGeneratorSettingListItem> createState() => _RhythmGeneratorSettingListItemState();
}

class _RhythmGeneratorSettingListItemState extends State<RhythmGeneratorSettingListItem> {
  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Ink(
        decoration: BoxDecoration(
          border: Border.all(style: widget.hasBorder ? BorderStyle.solid : BorderStyle.none, color: ColorTheme.primary),
          borderRadius: BorderRadius.circular(MetronomeParams.rhythmSegmentSize / 2),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(MetronomeParams.rhythmSegmentSize),
          onTap: widget.onTap,
          child: Padding(padding: const EdgeInsets.all(10.0), child: NoteHandler.getNoteSvg(widget.noteKey)),
        ),
      ),
    );
  }
}
