import 'package:flutter/material.dart';

class Zoomable extends StatefulWidget {
  final Widget child;
  const Zoomable({super.key, required this.child});

  @override
  ZoomableState createState() => ZoomableState();
}

class ZoomableState extends State<Zoomable> {
  final TransformationController _transformationController = TransformationController();
  bool _showHint = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) setState(() => _showHint = false);
    });

    _transformationController.addListener(_onTransform);
  }

  void _onTransform() {
    Matrix4 matrix = _transformationController.value;
    double scale = matrix.getMaxScaleOnAxis();
    if (scale > 1.0) {
      double horizontalTranslation = matrix.getTranslation().x;
      matrix.setTranslationRaw(horizontalTranslation, 0, 0);
      _transformationController.value = matrix;
    }
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
    return GestureDetector(
      onScaleStart: (_) => _onUserInteraction(),
      onTap: _onUserInteraction,
      child: Stack(
        children: [
          InteractiveViewer(
            transformationController: _transformationController,
            minScale: 1,
            maxScale: 4,
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
    );
  }
}
