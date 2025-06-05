import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/widgets/metronome/note.dart';

class Notes extends StatelessWidget {
  final int numberOfNotes;
  final String noteKey;
  final double width;
  final double? spaceBetweenNotes;

  const Notes({
    super.key,
    required this.numberOfNotes,
    required this.noteKey,
    required this.width,
    this.spaceBetweenNotes,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child:
          numberOfNotes == 0
              ? const SizedBox(height: TIOMusicParams.beatButtonSizeMainPage + TIOMusicParams.beatButtonPadding * 2)
              : Row(
                children:
                    List.generate(numberOfNotes, (i) => noteKey)
                        .expandIndexed(
                          (i, noteKey) => [
                            if (spaceBetweenNotes != null && i > 0)
                              SizedBox(
                                width:
                                    spaceBetweenNotes! -
                                    TIOMusicParams.beatButtonSizeMainPage -
                                    TIOMusicParams.beatButtonPadding * 2,
                              ),
                            Note(noteKey: noteKey),
                          ],
                        )
                        .toList(),
              ),
    );
  }
}
