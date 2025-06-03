import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:tiomusic/pages/media_player/waveform_visualizer.dart';

class Waveform extends StatelessWidget {
  final int selectedBin;
  final Float32List bins;

  final double width;
  final double height;

  final Function(int bin) onSelect;

  const Waveform({
    super.key,
    this.selectedBin = 0,
    required this.bins,
    this.width = 100,
    this.height = 200,
    required this.onSelect,
  });

  void _handleTapDown(TapDownDetails details) async => onSelect(_posToBin(details.localPosition.dx));

  void _handleHorizontalDragUpdate(DragUpdateDetails details) async => onSelect(_posToBin(details.localPosition.dx));

  int _posToBin(double position) => (position / width * bins.length).clamp(0, bins.length - 1).toInt();

  double _binToPos(int bin) => (bin / bins.length).clamp(0.0, 1.0) * width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onHorizontalDragUpdate: _handleHorizontalDragUpdate,
      child: CustomPaint(
        painter: WaveformVisualizer(_binToPos(selectedBin), 0, 1, bins, bins.length),
        size: Size(width, height),
      ),
    );
  }
}
