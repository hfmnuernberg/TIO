import 'package:flutter/material.dart';
import 'package:tiomusic/models/note_handler.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants/metronome_constants.dart';

class NoteToggle extends StatefulWidget {
  final String noteKey;
  final bool isSelected;

  final Function() onTap;

  const NoteToggle({super.key, required this.noteKey, this.isSelected = false, required this.onTap});

  @override
  State<NoteToggle> createState() => _NoteToggleState();
}

class _NoteToggleState extends State<NoteToggle> {
  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Ink(
        decoration: BoxDecoration(
          border: Border.all(
            style: widget.isSelected ? BorderStyle.solid : BorderStyle.none,
            color: ColorTheme.primary,
          ),
          borderRadius: BorderRadius.circular(MetronomeParams.rhythmSegmentSize / 2),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(MetronomeParams.rhythmSegmentSize),
          onTap: widget.onTap,
          child: Padding(padding: const EdgeInsets.all(10), child: NoteHandler.getNoteSvg(widget.noteKey)),
        ),
      ),
    );
  }
}
