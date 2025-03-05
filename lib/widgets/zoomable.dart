import 'package:flutter/material.dart';

class Zoomable extends StatefulWidget {
  final double? childWidgetHeight;
  final Widget child;

  const Zoomable({super.key, required this.childWidgetHeight, required this.child});

  @override
  ZoomableState createState() => ZoomableState();
}

class ZoomableState extends State<Zoomable> {
  final TransformationController _transformationController = TransformationController();
  bool _showHint = true;
  Size? _viewportSize;
  bool _updating = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) setState(() => _showHint = false);
    });

    _transformationController.addListener(_onTransform);
  }

  void _adjustVerticalTranslation() {
    if (_viewportSize == null) return;

    Matrix4 matrix = _transformationController.value;
    double scale = matrix.getMaxScaleOnAxis();

    // final double widgetHeightCentered = (widget.childWidgetHeight! - (widget.childWidgetHeight! * scale)) / 2;
    final double widgetHeightCentered = (widget.childWidgetHeight! - (widget.childWidgetHeight! * scale)) / 1000;
    final double widgetWidth = matrix.getTranslation().x;

    if ((matrix.getTranslation().y - widgetHeightCentered).abs() > 0.001) {
      matrix.setTranslationRaw(widgetWidth, widgetHeightCentered, 0);
      _transformationController.value = matrix;
    }
  }

  void _onTransform() {
    if (_viewportSize == null || _updating) return;
    _updating = true;
    _adjustVerticalTranslation();
    _updating = false;
  }

  void _onUserInteraction() {
    if (_showHint) {
      setState(() => _showHint = false);
    }
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransform);
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _viewportSize = Size(constraints.maxWidth, constraints.maxHeight);
        return SizedBox(
          height: widget.childWidgetHeight,
          child: GestureDetector(
            onScaleStart: (_) => _onUserInteraction(),
            onTap: _onUserInteraction,
            child: Stack(
              children: [
                InteractiveViewer(
                  transformationController: _transformationController,
                  minScale: 1,
                  maxScale: 4,
                  boundaryMargin: const EdgeInsets.only(left: 150),
                  alignment: Alignment.center,
                  onInteractionEnd: (_) => _onTransform(),
                  child: widget.child,
                ),
                if (_showHint)
                  Center(
                    child: AnimatedOpacity(
                      opacity: _showHint ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.zoom_in, color: Colors.white),
                            SizedBox(width: 8),
                            Text('Pinch to Zoom', style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
