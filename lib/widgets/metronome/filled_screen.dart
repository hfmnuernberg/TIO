import 'package:flutter/material.dart';

class FilledScreen extends CustomPainter {
  FilledScreen({required this.color});
  Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
    Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
