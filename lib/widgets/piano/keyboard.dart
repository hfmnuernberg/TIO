import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/util/util_midi.dart';
import 'package:tiomusic/widgets/piano/black_key.dart';
import 'package:tiomusic/widgets/piano/note.dart';
import 'package:tiomusic/widgets/piano/white_key.dart';
import 'package:tonic/tonic.dart';

class Keyboard extends StatefulWidget {
  final int lowestNote;
  final Set<int> playedNotes;

  final List<Note> _notes;
  late final List<Note> _naturals;
  late final List<Note> _sharps;
  late final List<Note?> _sharpsWithSpacing;

  final Function(int note) onPlay;
  final Function(int note) onRelease;

  Keyboard({
    super.key,
    required this.lowestNote,
    required this.playedNotes,
    required this.onPlay,
    required this.onRelease,
  }) : _notes = createNotes(lowestNote, playedNotes) {
    _naturals = _notes.where((note) => note.isNatural).toList();
    _sharps = _notes.whereNot((note) => note.isNatural).toList();
    _sharpsWithSpacing = createSharpsWithSpacing(lowestNote, playedNotes);
  }

  static List<Note> createNaturals(int lowestNote, Set<int> playedNotes) =>
      createNotes(lowestNote, playedNotes).where((note) => note.isNatural).toList();

  static List<Note> createSharps(int lowestNote, Set<int> playedNotes) =>
      createSharpsWithSpacing(lowestNote, playedNotes).nonNulls.toList();

  static List<Note?> createSharpsWithSpacing(int lowestNote, Set<int> playedNotes) {
    final notes = createNotes(lowestNote, playedNotes);
    final sharpsWithSpacing = <Note?>[];
    for (final (index, note) in notes.indexed) {
      if (index >= notes.length - 1) break;
      if (!note.isNatural) continue;
      if (notes[index + 1].isNatural) {
        sharpsWithSpacing.add(null);
      } else {
        sharpsWithSpacing.add(notes[index + 1]);
      }
    }
    return sharpsWithSpacing;
  }

  static List<Note> createNotes(int lowestNote, Set<int> playedNotes) {
    final notes = <Note>[];
    int currentNote = lowestNote;
    int naturalNotesRemaining = PianoParams.numberOfWhiteKeys;
    while (naturalNotesRemaining > 0) {
      final isNatural = midiToName(currentNote).length == 1;
      if (isNatural) naturalNotesRemaining--;
      notes.add(
        Note(
          note: currentNote,
          name: Pitch.fromMidiNumber(currentNote).toString(),
          isNatural: isNatural,
          isPlayed: playedNotes.contains(currentNote),
        ),
      );
      currentNote++;
    }
    return notes;
  }

  @override
  State<Keyboard> createState() => _KeyboardState();
}

class _KeyboardState extends State<Keyboard> {
  Size? keyboardSize;
  final Map<int, Rect> keyBoundaries = {};

  @override
  void didUpdateWidget(covariant Keyboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (keyboardSize == null) return;
    if (widget.lowestNote == oldWidget.lowestNote) return;

    final keyWidth = keyboardSize!.width / PianoParams.numberOfWhiteKeys;
    final keyHeight = keyboardSize!.height;
    updateKeyBoundaries(keyWidth, keyHeight);
  }

  void handlePlay(int note) => widget.onPlay(note);

  void handleRelease(int note) => widget.onRelease(note);

  void handlePointerUp(PointerEvent event) {
    if (!isWithinKeyboard(event.localPosition)) {
      releaseAllPlayedNotes();
      return;
    }

    final note = findPlayedNote(event.localPosition);
    if (note == null) return;
    if (widget.playedNotes.contains(note.note)) handleRelease(note.note);
  }

  void handlePointerMove(PointerEvent event) {
    if (!isWithinKeyboard(event.localPosition)) {
      releaseAllPlayedNotes();
      return;
    }

    final note = findPlayedNote(event.localPosition);
    if (note == null) return;
    if (!widget.playedNotes.contains(note.note)) {
      releaseAllPlayedNotes();
      handlePlay(note.note);
    }
  }

  void releaseAllPlayedNotes() {
    widget.playedNotes.toList().forEach(handleRelease);
  }

  bool isWithinKeyboard(Offset position) {
    if (keyboardSize == null) return false;
    return Rect.fromLTWH(0, 0, keyboardSize!.width, keyboardSize!.height).contains(position);
  }

  Note? findPlayedNote(Offset position) => findPlayedSharp(position) ?? findPlayedNatural(position);

  Note? findPlayedNatural(Offset position) => findPlayedNoteInNotes(widget._naturals, position);

  Note? findPlayedSharp(Offset position) => findPlayedNoteInNotes(widget._sharps, position);

  Note? findPlayedNoteInNotes(List<Note> notes, Offset position) => notes.firstWhereOrNull(
    (note) => keyBoundaries.containsKey(note.note) && keyBoundaries[note.note]!.contains(position),
  );

  void updateKeyBoundaries(double keyWidth, double keyHeight) {
    for (final (index, note) in widget._naturals.indexed) {
      keyBoundaries[note.note] = Rect.fromLTWH(index * keyWidth, 0, keyWidth, keyHeight);
    }

    for (final (index, note) in widget._sharpsWithSpacing.indexed) {
      if (note == null) continue;
      keyBoundaries[note.note] = Rect.fromLTWH(index * keyWidth + keyWidth / 2, 0, keyWidth, keyHeight / 2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final newKeyboardSize = Size(constraints.maxWidth, constraints.maxHeight);

              final keyWidth = newKeyboardSize.width / PianoParams.numberOfWhiteKeys;
              final keyHeight = newKeyboardSize.height;

              if (newKeyboardSize != keyboardSize) {
                keyboardSize = newKeyboardSize;
                updateKeyBoundaries(keyWidth, keyHeight);
              }

              return Listener(
                onPointerMove: handlePointerMove,
                onPointerUp: handlePointerUp,
                child: Stack(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children:
                          widget._naturals
                              .map(
                                (note) => WhiteKey(
                                  isPlayed: note.isPlayed,
                                  width: keyWidth,
                                  height: keyHeight,
                                  borderWidth: 4,
                                  semanticsLabel: note.name,
                                  label: note.note % PianoParams.numberOfWhiteKeys == 0 ? note.name : null,
                                  onPlay: () => handlePlay(note.note),
                                  onRelease: () => handleRelease(note.note),
                                ),
                              )
                              .toList(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(width: keyWidth / 2),
                        ...widget._sharpsWithSpacing.map(
                          (note) =>
                              note == null
                                  ? SizedBox(width: keyWidth)
                                  : BlackKey(
                                    isPlayed: note.isPlayed,
                                    width: keyWidth,
                                    height: keyHeight / 2,
                                    borderWidth: 4,
                                    semanticsLabel: note.name,
                                    onPlay: () => handlePlay(note.note),
                                    onRelease: () => handleRelease(note.note),
                                  ),
                        ),
                        SizedBox(width: keyWidth / 2),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
