import 'package:flutter/material.dart';
import 'package:tiomusic/models/note_handler.dart';
import 'package:tiomusic/util/constants.dart';

class Note extends StatelessWidget {
  final String noteKey;

  const Note({super.key, required this.noteKey});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(TIOMusicParams.beatButtonPadding),
      child: CircleAvatar(
        radius: TIOMusicParams.beatButtonSizeBig / 4,
        backgroundColor: Colors.transparent,
        child: NoteHandler.getNoteSvg(noteKey),
      ),
    );
  }
}
