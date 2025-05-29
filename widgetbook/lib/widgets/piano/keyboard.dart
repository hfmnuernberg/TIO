import 'package:flutter/material.dart';
import 'package:tiomusic/widgets/piano/keyboard.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Keyboard', type: Keyboard)
Widget keyboard(BuildContext context) {
  return Keyboard(
    lowestNote: context.knobs.int.input(label: 'lowestNote', initialValue: 60),
    onPlay: (note) => debugPrint('▶️ onPlay - note: $note'),
    onRelease: (note) => debugPrint('⏸️ onRelease - note: $note'),
  );
}
