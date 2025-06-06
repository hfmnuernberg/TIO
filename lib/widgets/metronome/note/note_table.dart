import 'package:flutter/cupertino.dart';
import 'package:tiomusic/models/note_handler.dart';
import 'package:tiomusic/widgets/metronome/note/note_button.dart';
import 'package:tiomusic/util/color_constants.dart';

class NoteTable extends StatelessWidget {
  final String selected;
  final void Function(String) onSelect;

  const NoteTable({super.key, required this.selected, required this.onSelect});

  Widget _noteButton(String noteKey) =>
      PaddedNoteToggle(noteKey: noteKey, isSelected: selected == noteKey, onTap: () => onSelect(noteKey));

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Table(
        border: const TableBorder(horizontalInside: BorderSide(color: ColorTheme.primary80)),
        children: <TableRow>[
          TableRow(
            children: [
              _noteButton(NoteValues.whole),
              const SizedBox(),
              const SizedBox(),
              const SizedBox(),
              const SizedBox(),
            ],
          ),
          TableRow(
            children: [
              _noteButton(NoteValues.half),
              _noteButton(NoteValues.halfDotted),
              _noteButton(NoteValues.tuplet3Half),
              const SizedBox(),
              const SizedBox(),
            ],
          ),
          TableRow(
            children: [
              _noteButton(NoteValues.quarter),
              _noteButton(NoteValues.quarterDotted),
              _noteButton(NoteValues.tuplet3Quarter),
              const SizedBox(),
              const SizedBox(),
            ],
          ),
          TableRow(
            children: [
              _noteButton(NoteValues.eighth),
              _noteButton(NoteValues.eighthDotted),
              _noteButton(NoteValues.tuplet3Eighth),
              const SizedBox(),
              const SizedBox(),
            ],
          ),
          TableRow(
            children: [
              _noteButton(NoteValues.sixteenth),
              _noteButton(NoteValues.sixteenthDotted),
              _noteButton(NoteValues.tuplet5Sixteenth),
              _noteButton(NoteValues.tuplet6Sixteenth),
              _noteButton(NoteValues.tuplet7Sixteenth),
            ],
          ),
          TableRow(
            children: [
              _noteButton(NoteValues.thirtySecond),
              _noteButton(NoteValues.thirtySecondDotted),
              const SizedBox(),
              const SizedBox(),
              const SizedBox(),
            ],
          ),
        ],
      ),
    );
  }
}

class PaddedNoteToggle extends StatelessWidget {
  final String noteKey;
  final bool isSelected;

  final void Function() onTap;

  const PaddedNoteToggle({super.key, required this.noteKey, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: NoteToggle(noteKey: noteKey, isSelected: isSelected, onTap: onTap),
    );
  }
}
