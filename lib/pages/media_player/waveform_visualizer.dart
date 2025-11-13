import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';

class WaveformVisualizer extends CustomPainter {
  final Float32List _rmsValues;

  double? _playbackPosition;
  final double? _rangeStartPos;
  final double? _rangeEndPos;
  final bool _singleView = false;

  WaveformVisualizer(this._playbackPosition, this._rangeStartPos, this._rangeEndPos, this._rmsValues);

  WaveformVisualizer.setTrim(this._rangeStartPos, this._rangeEndPos, this._rmsValues);

  @override
  void paint(Canvas canvas, Size size) {
    var midAxisHeight = size.height / 2;

    var blueBrush = Paint()
      ..color = ColorTheme.primary80
      ..strokeWidth = MediaPlayerParams.binWidth / 2.0;

    var redBrush = Paint()
      ..color = ColorTheme.tertiary60
      ..strokeWidth = MediaPlayerParams.binWidth / 2.0;

    var lightBlueBrush = Paint()
      ..color = ColorTheme.primary95
      ..strokeWidth = MediaPlayerParams.binWidth / 2.0;

    if (_rmsValues.isEmpty || size.width <= 0 || size.height <= 0) return;

    final int numberOfBins = _rmsValues.length;
    final double contentUnits = (numberOfBins > 1 ? (numberOfBins - 1) : 1) * MediaPlayerParams.binWidth;

    final double halfStroke = _halfStroke();
    final double drawableWidth = (size.width - 2 * halfStroke).clamp(0.0, size.width);
    final double scaleX = drawableWidth / contentUnits;

    canvas.save();
    canvas.clipRect(Offset.zero & size);

    if (_playbackPosition != null) {
      double playbackPositionMapped = _playbackPosition! * numberOfBins;

      for (int i = 0; i < _rmsValues.length; i++) {
        var brush = blueBrush;

        if (_singleView) {
          if (i >= playbackPositionMapped - 1.0 && i <= playbackPositionMapped) {
            brush = redBrush;
          }
        } else {
          double rangeStartMapped = _rangeStartPos! * numberOfBins;
          double rangeEndMapped = _rangeEndPos! * numberOfBins;

          if (i < rangeStartMapped || i > rangeEndMapped) {
            brush = lightBlueBrush;
          } else if (i <= playbackPositionMapped) {
            brush = redBrush;
          } else {
            brush = blueBrush;
          }
        }

        final double x = halfStroke + (i * MediaPlayerParams.binWidth) * scaleX;
        _drawWaveLine(canvas, size, x, midAxisHeight, i, brush);
      }
    } else if (_rangeStartPos != null && _rangeEndPos != null) {
      double startPositionMapped = _rangeStartPos * numberOfBins;
      double endPositionMapped = _rangeEndPos * numberOfBins;

      for (int i = 0; i < _rmsValues.length; i++) {
        var brush = i >= startPositionMapped && i <= endPositionMapped ? redBrush : blueBrush;

        final double x = halfStroke + (i * MediaPlayerParams.binWidth) * scaleX;
        _drawWaveLine(canvas, size, x, midAxisHeight, i, brush);
      }
    }

    canvas.restore();
  }

  void _drawWaveLine(Canvas canvas, Size size, double x, var midAxisHeight, int i, Paint brush) {
    canvas.drawLine(Offset(x, midAxisHeight), Offset(x, midAxisHeight - (_rmsValues[i] * (size.height / 2.2))), brush);

    canvas.drawLine(Offset(x, midAxisHeight), Offset(x, midAxisHeight + (_rmsValues[i] * (size.height / 2.2))), brush);
  }

  static double _halfStroke() => MediaPlayerParams.binWidth / 4.0;
  static double _contentUnits(int n) => (n > 1 ? (n - 1) : 1) * MediaPlayerParams.binWidth;
  static double computeScaleX(double availableWidth, int n) {
    final double drawableWidth = (availableWidth - 2 * _halfStroke()).clamp(0.0, availableWidth);
    final double units = _contentUnits(n);
    return units > 0 ? (drawableWidth / units) : 1.0;
  }

  static double xForIndex(int i, double availableWidth, int n) {
    final double scaleX = computeScaleX(availableWidth, n);
    return _halfStroke() + (i * MediaPlayerParams.binWidth) * scaleX;
  }

  static int indexForX(double x, double availableWidth, int n) {
    if (n <= 1) return 0;
    final double scaleX = computeScaleX(availableWidth, n);
    final double raw = (x - _halfStroke()) / (MediaPlayerParams.binWidth * scaleX);
    final double clamped = raw.clamp(0.0, (n - 1).toDouble());
    return clamped.round();
  }

  static int calculateBinCountForWidth(double availableWidth) {
    final double drawableWidth = (availableWidth - 2 * _halfStroke()).clamp(0.0, availableWidth);
    if (drawableWidth <= 0) return 1;
    return drawableWidth ~/ MediaPlayerParams.binWidth + 1;
  }

  @override
  bool shouldRepaint(WaveformVisualizer oldDelegate) {
    return true;
  }
}
