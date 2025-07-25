import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/widgets/piano/black_key.dart';
import 'package:tiomusic/widgets/piano/key_note.dart';
import 'package:tiomusic/widgets/piano/keyboard_utils.dart';
import 'package:tiomusic/widgets/piano/white_key.dart';

class Keyboard extends StatefulWidget {
  final int lowestNote;
  final bool isHolding;

  final List<KeyNote> _naturals;
  final List<KeyNote> _sharps;
  final List<KeyNote?> _sharpsWithSpacing;

  final Function(int note) onPlay;
  final Function(int note) onRelease;

  Keyboard({
    super.key,
    required this.lowestNote,
    required this.isHolding,
    required this.onPlay,
    required this.onRelease,
  }) : _naturals = createNaturals(lowestNote),
       _sharps = createSharps(lowestNote),
       _sharpsWithSpacing = createSharpsWithSpacing(lowestNote);

  @override
  State<Keyboard> createState() => _KeyboardState();
}

class _KeyboardState extends State<Keyboard> {
  Size? keyboardSize;
  final Map<int, Rect> keyBoundaries = {};
  final Map<int, int> pointersWithLastNote = {};

  @override
  void didUpdateWidget(covariant Keyboard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isHolding && !widget.isHolding) handleReleaseAll();

    if (keyboardSize == null) return;
    if (widget.lowestNote == oldWidget.lowestNote) return;

    final keyWidth = keyboardSize!.width / PianoParams.numberOfWhiteKeys;
    final keyHeight = keyboardSize!.height;
    updateKeyBoundaries(keyWidth, keyHeight);
  }

  void handlePointerDown(PointerEvent event) => handlePlay(event.pointer, findPlayedKey(event.localPosition)?.note);

  void handlePointerMove(PointerEvent event) => handlePlay(event.pointer, findPlayedKey(event.localPosition)?.note);

  void handlePointerUp(PointerEvent event) => handleRelease(event.pointer, findPlayedKey(event.localPosition)?.note);

  void handlePointerCancel(PointerEvent event) =>
      handleRelease(event.pointer, findPlayedKey(event.localPosition)?.note);

  void handlePlay(int pointer, int? note) {
    final lastNote = pointersWithLastNote[pointer];
    final noOfPointersPlayingLastNote = pointersWithLastNote.values.where((note) => note == lastNote).length;
    if (lastNote != null && lastNote != note && noOfPointersPlayingLastNote <= 1) widget.onRelease(lastNote);

    if (note == null) return;

    final isPlayedByOtherPointer = pointersWithLastNote.values.contains(note);
    pointersWithLastNote[pointer] = note;

    if (lastNote != note && !isPlayedByOtherPointer) widget.onPlay(note);

    setState(() {});
  }

  void handleRelease(int pointer, int? note) {
    if (widget.isHolding) return;
    pointersWithLastNote.remove(pointer);
    setState(() {});
    if (note != null) widget.onRelease(note);
  }

  void handleReleaseAll() {
    pointersWithLastNote.values.forEach(widget.onRelease);
    pointersWithLastNote.clear();
    setState(() {});
  }

  bool isPlayed(int note) => pointersWithLastNote.values.contains(note);

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
                onPointerDown: handlePointerDown,
                onPointerMove: handlePointerMove,
                onPointerUp: handlePointerUp,
                onPointerCancel: handlePointerCancel,
                child: Stack(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children:
                          widget._naturals
                              .map(
                                (key) => WhiteKey(
                                  isPlayed: isPlayed(key.note),
                                  width: keyWidth,
                                  height: keyHeight,
                                  borderWidth: 4,
                                  semanticsLabel: key.name,
                                  label: key.note % PianoParams.numberOfWhiteKeys == 0 ? key.name : null,
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
                                    isPlayed: isPlayed(key.note),
                                    width: keyWidth,
                                    height: keyHeight / 2,
                                    borderWidth: 4,
                                    semanticsLabel: key.name,
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
