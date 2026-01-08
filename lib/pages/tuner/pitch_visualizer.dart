import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tiomusic/util/color_constants.dart';

class PitchOffset {
  late double offsetFactor; // from 0.0 to 1.0; 0.5 would be perfect pitch
  late bool isValue;

  PitchOffset.withoutValue() {
    isValue = false;
    offsetFactor = 0.5;
  }

  PitchOffset.withValue(double offsetMidi) {
    isValue = true;
    offsetFactor = clampDouble(offsetMidi + 0.5, 0, 1);
  }
}

class PitchVisualizer extends CustomPainter {
  final _historyLength = 100;
  late List<PitchOffset> _history = List.filled(_historyLength, PitchOffset.withoutValue(), growable: true);

  bool _dirty = true;
  bool _gettingInput = false;

  final _maxJumpFactor = 0.2;
  final _offsetTolerance = 0.15;

  final _redCircleSize = 40.0;

  PitchVisualizer(List<PitchOffset> history, bool gettingInput) {
    _history = List.from(history.reversed);
    _gettingInput = gettingInput;
  }

  @override
  void paint(Canvas canvas, Size size) {
    _dirty = false;
    final spaceBetweenVerticalLines = size.width * _offsetTolerance;

    var paintCircle = Paint()
      ..color = ColorTheme.tertiary60
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke;

    var paintLine = Paint()
      ..color = Colors.white
      ..strokeWidth = 4;

    var paintVerticalLine = Paint()
      ..color = ColorTheme.primaryFixedDim
      ..strokeWidth = 2;

    var paintRect = Paint()..color = ColorTheme.primaryFixedDim;

    var topCorner = Offset(size.width / 2, 0);
    var bottomCorner = Offset(size.width / 2, size.height);
    var leftTopCorner = Offset(size.width / 2 - spaceBetweenVerticalLines, 0);
    var rightTopCorner = Offset(size.width / 2 + spaceBetweenVerticalLines, 0);
    var leftBottomCorner = Offset(size.width / 2 - spaceBetweenVerticalLines, size.height);
    var rightBottomCorner = Offset(size.width / 2 + spaceBetweenVerticalLines, size.height);

    if (_history.first.offsetFactor * size.width > leftTopCorner.dx &&
        _history.first.offsetFactor * size.width < rightTopCorner.dx) {
      canvas.drawRect(Rect.fromPoints(leftTopCorner, rightBottomCorner), paintRect);
    }

    canvas.drawLine(topCorner, bottomCorner, paintVerticalLine);
    canvas.drawLine(leftTopCorner, leftBottomCorner, paintVerticalLine);
    canvas.drawLine(rightTopCorner, rightBottomCorner, paintVerticalLine);

    for (int i = 0; i < _history.length - 1; i++) {
      if (!_history[i].isValue || !_history[i + 1].isValue) continue;

      double valFrom = _history[i].offsetFactor;
      double valTo = _history[i + 1].offsetFactor;

      if ((valFrom - valTo).abs() > _maxJumpFactor) continue; // disconnect large jumps

      double yFrom = size.height * i.toDouble() / _history.length.toDouble();
      double yTo = size.height * (i.toDouble() + 1.0) / _history.length.toDouble();

      canvas.drawLine(Offset(size.width * valFrom, yFrom), Offset(size.width * valTo, yTo), paintLine);
    }

    if (_gettingInput) {
      canvas.drawCircle(Offset(size.width * _history.first.offsetFactor, size.height / 2), _redCircleSize, paintCircle);
    }
  }

  @override
  bool shouldRepaint(PitchVisualizer oldDelegate) {
    return oldDelegate._dirty;
  }
}

class PitchIslandViewVisualizer extends CustomPainter {
  late double _pitchFactor;
  late String _midiName;
  late bool _show = false;

  final double radiusSideCircles = 10;

  bool dirty = true;

  PitchIslandViewVisualizer(double factor, String midiName, bool show) {
    _pitchFactor = factor;
    _midiName = midiName;
    _show = show;
  }

  @override
  void paint(Canvas canvas, Size size) {
    dirty = false;

    var paintCircle = Paint()
      ..color = ColorTheme.primary
      ..strokeWidth = 2;

    var paintLine = Paint()
      ..color = ColorTheme.primaryFixedDim
      ..strokeWidth = 2;

    var paintEmptyCircle = Paint()
      ..color = ColorTheme.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    var xPositionFactor = ((size.width - (radiusSideCircles * 2)) * _pitchFactor) + radiusSideCircles;
    var factorPosition = Offset(xPositionFactor, size.height / 2);

    // the line
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), paintLine);

    // circles on the sides
    canvas.drawCircle(Offset(radiusSideCircles, size.height / 2), radiusSideCircles, paintLine);
    canvas.drawCircle(Offset(size.width - radiusSideCircles, size.height / 2), radiusSideCircles, paintLine);

    // empty circle in the middle
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 20, paintEmptyCircle);

    if (_show) {
      // circle showing the deviation
      canvas.drawCircle(factorPosition, 16, paintCircle);

      const textStyle = TextStyle(color: Colors.white, fontSize: 14);
      final textSpan = TextSpan(text: _midiName, style: textStyle);
      final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr, textAlign: TextAlign.center);
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(xPositionFactor - (textPainter.width / 2), size.height / 2 - (textPainter.height / 2)),
      );
    }
  }

  @override
  bool shouldRepaint(PitchIslandViewVisualizer oldDelegate) {
    return oldDelegate.dirty;
  }
}
