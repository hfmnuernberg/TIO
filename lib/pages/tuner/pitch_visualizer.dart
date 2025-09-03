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

  PitchOffset.withValue(offsetMidi) {
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
