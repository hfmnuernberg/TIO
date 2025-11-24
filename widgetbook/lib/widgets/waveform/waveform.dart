import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:tiomusic/pages/media_player/waveform_visualizer.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

class Wrapper extends StatelessWidget {
  final Widget child;

  const Wrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorTheme.secondaryContainer,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 480), child: child),
    );
  }
}

class WaveformPreview extends StatelessWidget {
  const WaveformPreview({super.key});

  Float32List _buildSampleRmsValues() {
    const int length = 45;
    final values = Float32List(length);

    for (int i = 0; i < length; i++) {
      final t = i / (length - 1);
      final baseWave = 0.5 * (1 + math.sin(2 * math.pi * 3 * t));
      final modulation = 0.5 * (1 + math.sin(2 * math.pi * 0.5 * t));
      final v = 0.2 + 0.8 * baseWave * modulation;
      values[i] = v.clamp(0.0, 1.0);
    }

    return values;
  }

  @override
  Widget build(BuildContext context) {
    final rmsValues = _buildSampleRmsValues();

    return SizedBox(
      height: 200,
      child: CustomPaint(painter: WaveformVisualizer(0.3, 0, 1, rmsValues), size: const Size(double.infinity, 200)),
    );
  }
}

@widgetbook.UseCase(name: 'WaveformVisualizer', type: WaveformPreview)
Widget waveformVisualizerUseCase(BuildContext context) {
  return const Wrapper(child: WaveformPreview());
}
