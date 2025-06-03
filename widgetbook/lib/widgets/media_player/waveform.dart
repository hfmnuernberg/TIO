import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:tiomusic/widgets/media_player/waveform.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Waveform', type: Waveform)
Widget waveform(BuildContext context) {
  return Waveform(
    selectedBin: 9,
    bins: Float32List.fromList(List.generate(100, (index) => index % 10)),
    width: 200,
    height: 100,
    onSelect: (int bin) => debugPrint('onSelect -  bin: $bin'),
  );
}
