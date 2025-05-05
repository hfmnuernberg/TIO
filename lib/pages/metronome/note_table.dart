import 'package:flutter/cupertino.dart';
import 'package:tiomusic/models/note_handler.dart';
import 'package:tiomusic/pages/metronome/rhythm_generator_setting_list_item.dart';
import 'package:tiomusic/util/color_constants.dart';

class NoteTable extends StatelessWidget {
  final String selectedNoteKey;
  final void Function(String) onSelectNote;

  const NoteTable({super.key, required this.selectedNoteKey, required this.onSelectNote});

  Widget _buildNoteButton(String noteKey) {
    final isSelected = selectedNoteKey == noteKey;
    return Padding(
      padding: const EdgeInsets.all(8),
      child: RhythmGeneratorSettingListItem(
        noteKey: noteKey,
        hasBorder: isSelected,
        onTap: () => onSelectNote(noteKey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Table(
        border: const TableBorder(horizontalInside: BorderSide(color: ColorTheme.primary80)),
        children: <TableRow>[
          TableRow(
            children: [
              _buildNoteButton(NoteValues.whole),
              const SizedBox(),
              const SizedBox(),
              const SizedBox(),
              const SizedBox(),
            ],
          ),
          TableRow(
            children: [
              _buildNoteButton(NoteValues.half),
              _buildNoteButton(NoteValues.halfDotted),
              _buildNoteButton(NoteValues.tuplet3Half),
              const SizedBox(),
              const SizedBox(),
            ],
          ),
          TableRow(
            children: [
              _buildNoteButton(NoteValues.quarter),
              _buildNoteButton(NoteValues.quarterDotted),
              _buildNoteButton(NoteValues.tuplet3Quarter),
              const SizedBox(),
              const SizedBox(),
            ],
          ),
          TableRow(
            children: [
              _buildNoteButton(NoteValues.eighth),
              _buildNoteButton(NoteValues.eighthDotted),
              _buildNoteButton(NoteValues.tuplet3Eighth),
              const SizedBox(),
              const SizedBox(),
            ],
          ),
          TableRow(
            children: [
              _buildNoteButton(NoteValues.sixteenth),
              _buildNoteButton(NoteValues.sixteenthDotted),
              _buildNoteButton(NoteValues.tuplet5Sixteenth),
              _buildNoteButton(NoteValues.tuplet6Sixteenth),
              _buildNoteButton(NoteValues.tuplet7Sixteenth),
            ],
          ),
          TableRow(
            children: [
              _buildNoteButton(NoteValues.thirtySecond),
              _buildNoteButton(NoteValues.thirtySecondDotted),
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
