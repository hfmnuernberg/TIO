// A collection of custom shapes

import 'package:flutter/material.dart';

class LeftButtonShape extends OutlinedBorder {
  const LeftButtonShape();

  @override
  EdgeInsetsGeometry get dimensions {
    return const EdgeInsets.only();
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return getOuterPath(rect, textDirection: textDirection);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..moveTo(rect.right, rect.top)
      ..moveTo(rect.right, rect.bottom)
      ..lineTo(rect.right - rect.width / 2.0, rect.bottom)
      ..arcToPoint(Offset(rect.right - rect.width / 2.0, rect.top), radius: Radius.circular(rect.width / 4.0))
      ..lineTo(rect.right, rect.top)
      ..close();
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  OutlinedBorder scale(double t) {
    return const LeftButtonShape();
  }

  @override
  OutlinedBorder copyWith({BorderSide? side}) {
    return const LeftButtonShape();
  }
}

class RightButtonShape extends OutlinedBorder {
  const RightButtonShape();

  @override
  EdgeInsetsGeometry get dimensions {
    return const EdgeInsets.only();
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return getOuterPath(rect, textDirection: textDirection);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..moveTo(rect.left, rect.top)
      ..lineTo(rect.left + rect.width / 2.0, rect.top)
      ..arcToPoint(Offset(rect.left + rect.width / 2.0, rect.bottom), radius: Radius.circular(rect.width / 4.0))
      ..lineTo(rect.left, rect.bottom)
      ..lineTo(rect.left, rect.top)
      ..close();
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  OutlinedBorder scale(double t) {
    return const RightButtonShape();
  }

  @override
  OutlinedBorder copyWith({BorderSide? side}) {
    return const RightButtonShape();
  }
}
