import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/util/util_midi.dart';
import 'package:tiomusic/widgets/piano/black_key.dart';
import 'package:tiomusic/widgets/piano/key_note.dart';
import 'package:tiomusic/widgets/piano/white_key.dart';
import 'package:tonic/tonic.dart';

class Keyboard extends StatefulWidget {
  final int lowestNote;

  final List<KeyNote> _notes;
  late final List<KeyNote> _naturals;
  late final List<KeyNote> _sharps;
  late final List<KeyNote?> _sharpsWithSpacing;

  final Function(int note) onPlay;
  final Function(int note) onRelease;

  Keyboard({super.key, required this.lowestNote, required this.onPlay, required this.onRelease})
    : _notes = createNotes(lowestNote) {
    _naturals = _notes.where((note) => note.isNatural).toList();
    _sharps = _notes.whereNot((note) => note.isNatural).toList();
    _sharpsWithSpacing = createSharpsWithSpacing(lowestNote);
  }

  static List<KeyNote> createNaturals(int lowestNote) =>
      createNotes(lowestNote).where((note) => note.isNatural).toList();

  static List<KeyNote> createSharps(int lowestNote) => createSharpsWithSpacing(lowestNote).nonNulls.toList();

  static List<KeyNote?> createSharpsWithSpacing(int lowestNote) {
    final notes = createNotes(lowestNote);
    final sharpsWithSpacing = <KeyNote?>[];
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

  static List<KeyNote> createNotes(int lowestNote) {
    final notes = <KeyNote>[];
    int currentNote = lowestNote;
    int naturalNotesRemaining = PianoParams.numberOfWhiteKeys;
    while (naturalNotesRemaining > 0) {
      final isNatural = midiToName(currentNote).length == 1;
      if (isNatural) naturalNotesRemaining--;
      notes.add(KeyNote(note: currentNote, name: Pitch.fromMidiNumber(currentNote).toString(), isNatural: isNatural));
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
  Set<int> playedNotes = {};
  int? lastPlayedNote;

  @override
  void didUpdateWidget(covariant Keyboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (keyboardSize == null) return;
    if (widget.lowestNote == oldWidget.lowestNote) return;

    final keyWidth = keyboardSize!.width / PianoParams.numberOfWhiteKeys;
    final keyHeight = keyboardSize!.height;
    updateKeyBoundaries(keyWidth, keyHeight);
  }

  void handlePlay(int note) {
    widget.onPlay(note);
    playedNotes.add(note);
    lastPlayedNote = note;
    setState(() {});
  }

  void handleRelease(int note) {
    widget.onRelease(note);
    playedNotes.remove(note);
    if (lastPlayedNote == note) lastPlayedNote = null;
    setState(() {});
  }

  void handlePointerUp(PointerEvent event) {
    lastPlayedNote = null;
    setState(() {});
  }

  void handlePointerMove(PointerEvent event) {
    if (!isWithinKeyboard(event.localPosition)) return handlePointerUp(event);

    final key = findPlayedKey(event.localPosition);
    if (key == null) return handlePointerUp(event);

    if (playedNotes.contains(key.note) && lastPlayedNote == key.note) playedNotes.remove(key.note);
    if (playedNotes.contains(key.note) || lastPlayedNote == key.note) return;

    widget.onPlay(key.note);
    lastPlayedNote = key.note;
    setState(() {});
  }

  bool isWithinKeyboard(Offset position) {
    if (keyboardSize == null) return false;
    return Rect.fromLTWH(0, 0, keyboardSize!.width, keyboardSize!.height).contains(position);
  }

  KeyNote? findPlayedKey(Offset position) => findPlayedSharp(position) ?? findPlayedNatural(position);

  KeyNote? findPlayedNatural(Offset position) => findPlayedNoteInNotes(widget._naturals, position);

  KeyNote? findPlayedSharp(Offset position) => findPlayedNoteInNotes(widget._sharps, position);

  KeyNote? findPlayedNoteInNotes(List<KeyNote> keys, Offset position) => keys.firstWhereOrNull(
    (key) => keyBoundaries.containsKey(key.note) && keyBoundaries[key.note]!.contains(position),
  );

  void updateKeyBoundaries(double keyWidth, double keyHeight) {
    for (final (index, key) in widget._naturals.indexed) {
      keyBoundaries[key.note] = Rect.fromLTWH(index * keyWidth, 0, keyWidth, keyHeight);
    }

    for (final (index, key) in widget._sharpsWithSpacing.indexed) {
      if (key == null) continue;
      keyBoundaries[key.note] = Rect.fromLTWH(index * keyWidth + keyWidth / 2, 0, keyWidth, keyHeight / 2);
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
                                (key) => WhiteKey(
                                  isPlayed: lastPlayedNote == key.note,
                                  width: keyWidth,
                                  height: keyHeight,
                                  borderWidth: 4,
                                  semanticsLabel: key.name,
                                  label: key.note % PianoParams.numberOfWhiteKeys == 0 ? key.name : null,
                                  onPlay: () => handlePlay(key.note),
                                  onRelease: () => handleRelease(key.note),
                                ),
                              )
                              .toList(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(width: keyWidth / 2),
                        ...widget._sharpsWithSpacing.map(
                          (key) =>
                              key == null
                                  ? SizedBox(width: keyWidth)
                                  : BlackKey(
                                    isPlayed: lastPlayedNote == key.note,
                                    width: keyWidth,
                                    height: keyHeight / 2,
                                    borderWidth: 4,
                                    semanticsLabel: key.name,
                                    onPlay: () => handlePlay(key.note),
                                    onRelease: () => handleRelease(key.note),
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
