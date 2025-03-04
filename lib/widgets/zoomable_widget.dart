import 'package:flutter/cupertino.dart';

class ZoomableWidget extends StatefulWidget {
  final Widget child;
  const ZoomableWidget({super.key, required this.child});

  @override
  ZoomableWidgetState createState() => ZoomableWidgetState();
}

class ZoomableWidgetState extends State<ZoomableWidget> {
  double _scale = 1.0;
  double _previousScale = 1.0;
  Offset _offset = Offset.zero;
  Offset _previousOffset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: (ScaleStartDetails details) {
        _previousScale = _scale;
        _previousOffset = details.focalPoint - _offset;
      },
      onScaleUpdate: (ScaleUpdateDetails details) {
        setState(() {
          _scale = _previousScale * details.scale;
          _offset = details.focalPoint - _previousOffset;
        });
      },
      onScaleEnd: (ScaleEndDetails details) {
        _previousScale = 1.0;
      },
      child: Transform(
        transform: Matrix4.identity()
          ..translate(_offset.dx, _offset.dy)
          ..scale(_scale),
        alignment: Alignment.center,
        child: widget.child,
      ),
    );
  }
}
