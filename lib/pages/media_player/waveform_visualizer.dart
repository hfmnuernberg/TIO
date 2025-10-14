import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:tiomusic/util/color_constants.dart';
import 'package:tiomusic/util/constants.dart';

class WaveformVisualizer extends CustomPainter {
  final int _numOfBins;
  final Float32List _rmsValues;

  double? _playbackPosition;
  double? _rangeStartPos;
  double? _rangeEndPos;
  bool _singleView = false;

  WaveformVisualizer(this._playbackPosition, this._rangeStartPos, this._rangeEndPos, this._rmsValues, this._numOfBins);

  WaveformVisualizer.singleView(this._playbackPosition, this._rmsValues, this._numOfBins, this._singleView);

  WaveformVisualizer.setTrim(this._rangeStartPos, this._rangeEndPos, this._rmsValues, this._numOfBins);

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

    double stepSize = MediaPlayerParams.binWidth / 2.0;

    if (_rmsValues.isEmpty || size.width <= 0 || size.height <= 0) {
      return;
    }
    final double totalContentWidth = _rmsValues.length * MediaPlayerParams.binWidth - 30;
    final double scaleX = totalContentWidth > 0 ? (size.width / totalContentWidth) : 1.0;

    canvas.save();
    canvas.clipRect(Offset.zero & size);

    if (_playbackPosition != null) {
      double playbackPositionMapped = _playbackPosition! * _numOfBins;

      for (int i = 0; i < _rmsValues.length; i++) {
        var brush = blueBrush;

        if (_singleView) {
          if (i >= playbackPositionMapped - 1.0 && i <= playbackPositionMapped) {
            brush = redBrush;
          }
        } else {
          double rangeStartMapped = _rangeStartPos! * _numOfBins;
          double rangeEndMapped = _rangeEndPos! * _numOfBins;

          if (i < rangeStartMapped || i > rangeEndMapped) {
            brush = lightBlueBrush;
          } else if (i <= playbackPositionMapped) {
            brush = redBrush;
          } else {
            brush = blueBrush;
          }
        }

        _drawWaveLine(canvas, size, stepSize * scaleX, midAxisHeight, i, brush);
        stepSize = stepSize + MediaPlayerParams.binWidth;
      }
    } else if (_rangeStartPos != null && _rangeEndPos != null) {
      double startPositionMapped = _rangeStartPos! * _numOfBins;
      double endPositionMapped = _rangeEndPos! * _numOfBins;

      for (int i = 0; i < _rmsValues.length; i++) {
        var brush = i >= startPositionMapped && i <= endPositionMapped ? redBrush : blueBrush;

        _drawWaveLine(canvas, size, stepSize * scaleX, midAxisHeight, i, brush);
        stepSize = stepSize + MediaPlayerParams.binWidth;
      }
    }

    canvas.restore();
  }

  void _drawWaveLine(Canvas canvas, Size size, double stepSize, var midAxisHeight, int i, Paint brush) {
    canvas.drawLine(
      Offset(stepSize, midAxisHeight),
      Offset(stepSize, midAxisHeight - (_rmsValues[i] * (size.height / 2.2))),
      brush,
    );

    canvas.drawLine(
      Offset(stepSize, midAxisHeight),
      Offset(stepSize, midAxisHeight + (_rmsValues[i] * (size.height / 2.2))),
      brush,
    );
  }

  @override
  bool shouldRepaint(WaveformVisualizer oldDelegate) {
    if (_playbackPosition != oldDelegate._playbackPosition ||
        _rmsValues != oldDelegate._rmsValues ||
        _rangeStartPos != oldDelegate._rangeStartPos ||
        _rangeEndPos != oldDelegate._rangeEndPos) {
      return true;
    }
    return false;
  }
}
