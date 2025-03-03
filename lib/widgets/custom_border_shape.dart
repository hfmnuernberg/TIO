import 'package:flutter/material.dart';

enum PointingDirection { up, down, left, right }

enum PointerPosition { center, left, right }

class MessageBorder extends ShapeBorder {
  final bool usePadding;
  final PointingDirection? pointingDirection;
  double get _padding => 16;
  final double pointerOffset; // for the offset to use, set pointerPosition to center
  final PointerPosition pointerPosition;

  const MessageBorder({
    this.usePadding = true,
    this.pointingDirection,
    this.pointerOffset = 0,
    this.pointerPosition = PointerPosition.center,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.only(bottom: usePadding ? _padding : 0);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path();
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    rect = Rect.fromPoints(rect.topLeft, rect.bottomRight - Offset(0, _padding));

    switch (pointingDirection) {
      case PointingDirection.up:
        return _pointUp(rect);
      case PointingDirection.down:
        return _pointDown(rect);
      case PointingDirection.left:
        return _pointLeft(rect);
      case PointingDirection.right:
        return _pointRight(rect);
      default:
        return Path()
          ..addRect(rect)
          ..close();
    }
  }

  Path _pointDown(Rect rect) {
    var moveToX = rect.bottomCenter.dx - _padding / 2 + pointerOffset;
    var moveToY = rect.bottomCenter.dy;

    if (pointerPosition == PointerPosition.left) {
      moveToX = rect.bottomLeft.dx + _padding / 3;
      moveToY = rect.bottomLeft.dy;
    } else if (pointerPosition == PointerPosition.right) {
      moveToX = rect.bottomRight.dx - _padding - _padding / 3;
      moveToY = rect.bottomRight.dy;
    }

    return Path()
      ..addRect(rect)
      ..moveTo(moveToX, moveToY)
      ..relativeLineTo(_padding / 2, _padding)
      ..relativeLineTo(_padding / 2, -_padding)
      ..close();
  }

  Path _pointUp(Rect rect) {
    var moveToX = rect.topCenter.dx - _padding / 2 + pointerOffset;
    var moveToY = rect.topCenter.dy;

    if (pointerPosition == PointerPosition.left) {
      moveToX = rect.topLeft.dx + _padding / 3;
      moveToY = rect.topLeft.dy;
    } else if (pointerPosition == PointerPosition.right) {
      moveToX = rect.topRight.dx - _padding - _padding / 3;
      moveToY = rect.topRight.dy;
    }

    return Path()
      ..addRect(rect)
      ..moveTo(moveToX, moveToY)
      ..relativeLineTo(_padding / 2, -_padding)
      ..relativeLineTo(_padding / 2, _padding)
      ..close();
  }

  Path _pointLeft(Rect rect) {
    var moveToX = rect.centerLeft.dx;
    var moveToY = rect.centerLeft.dy - _padding / 2 + pointerOffset;

    if (pointerPosition == PointerPosition.left) {
      moveToX = rect.bottomLeft.dx;
      moveToY = rect.bottomLeft.dy - _padding - _padding / 3;
    } else if (pointerPosition == PointerPosition.right) {
      moveToX = rect.topLeft.dx;
      moveToY = rect.topLeft.dy + _padding / 3;
    }

    return Path()
      ..addRect(rect)
      ..moveTo(moveToX, moveToY)
      ..relativeLineTo(-_padding, _padding / 2)
      ..relativeLineTo(_padding, _padding / 2)
      ..close();
  }

  Path _pointRight(Rect rect) {
    var moveToX = rect.centerRight.dx;
    var moveToY = rect.centerRight.dy - _padding / 2 + pointerOffset;

    if (pointerPosition == PointerPosition.left) {
      moveToX = rect.topRight.dx;
      moveToY = rect.topRight.dy + _padding / 3;
    } else if (pointerPosition == PointerPosition.right) {
      moveToX = rect.bottomRight.dx;
      moveToY = rect.bottomRight.dy - _padding - _padding / 3;
    }

    return Path()
      ..addRect(rect)
      ..moveTo(moveToX, moveToY)
      ..relativeLineTo(_padding, _padding / 2)
      ..relativeLineTo(-_padding, _padding / 2)
      ..close();
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;
}
