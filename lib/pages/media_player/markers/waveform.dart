import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:tiomusic/pages/media_player/waveform_visualizer.dart';
import 'package:tiomusic/pages/media_player/markers/markers.dart';
import 'package:tiomusic/pages/media_player/markers/waveform_window_labels.dart';
import 'package:tiomusic/pages/media_player/markers/waveform_viewport_controller.dart';

const double waveformHeight = 200;

class Waveform extends StatefulWidget {
  final Float32List rmsValues;
  final double position;
  final double rangeStart;
  final double rangeEnd;
  final Duration fileDuration;
  final List<double> markerPositions;
  final double? selectedMarkerPosition;
  final ValueChanged<double> onPositionChange;
  final void Function(double viewStart, double viewEnd) onZoomChanged;

  const Waveform({
    super.key,
    required this.rmsValues,
    required this.position,
    required this.rangeStart,
    required this.rangeEnd,
    required this.fileDuration,
    required this.markerPositions,
    required this.selectedMarkerPosition,
    required this.onPositionChange,
    required this.onZoomChanged,
  });

  @override
  State<Waveform> createState() => _WaveformState();
}

class _WaveformState extends State<Waveform> {
  final GlobalKey _waveKey = GlobalKey();
  late WaveformVisualizer _waveformVisualizer;
  late WaveformViewportController _viewport;

  double _availableWidth = 0;

  double get _paintedWaveWidth {
    if (_availableWidth > 0) return _availableWidth;
    final buildContext = _waveKey.currentContext;
    if (buildContext == null) return 0;
    final renderObject = buildContext.findRenderObject();
    if (renderObject is RenderBox) return renderObject.size.width;
    return 0;
  }

  @override
  void initState() {
    super.initState();
    _viewport = WaveformViewportController(fileDuration: widget.fileDuration);
    _rebuildVisualizer();
  }

  @override
  void didUpdateWidget(covariant Waveform oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.rmsValues != widget.rmsValues ||
        oldWidget.position != widget.position ||
        oldWidget.rangeStart != widget.rangeStart ||
        oldWidget.rangeEnd != widget.rangeEnd) {
      _rebuildVisualizer();
    }
  }

  void _rebuildVisualizer() {
    _waveformVisualizer = WaveformVisualizer(
      widget.position,
      widget.rangeStart,
      widget.rangeEnd,
      widget.rmsValues,
      viewStart: _viewport.viewStart,
      viewEnd: _viewport.viewEnd,
    );
  }

  void _handleTap(TapUpDetails details) {
    final double width = _paintedWaveWidth;
    final int totalBins = widget.rmsValues.length;
    final snappedRelative = _viewport.calculateSnappedRelativePosition(
      tapX: details.localPosition.dx,
      paintedWidth: width,
      totalBins: totalBins,
    );
    widget.onPositionChange(snappedRelative);
  }

  void _panBy(double dxPixels) {
    final double width = _paintedWaveWidth;
    if (width <= 0) return;

    setState(() {
      _viewport.panByPixels(dxPixels: dxPixels, paintedWidth: width);
      _rebuildVisualizer();
    });
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (details.pointerCount < 2) return;

    setState(() {
      _viewport.updateScale(details.scale);
      _rebuildVisualizer();
    });
  }

  void _handleScaleEnd(ScaleEndDetails details) => widget.onZoomChanged(_viewport.viewStart, _viewport.viewEnd);

  void _handleHorizontalDragUpdate(DragUpdateDetails details) {
    final double? dx = details.primaryDelta;
    if (dx == null) return;
    _panBy(dx);
  }

  void _handleScaleStart(ScaleStartDetails details) {
    if (details.pointerCount < 2) return;

    final double width = _paintedWaveWidth;
    final int totalBins = widget.rmsValues.length;
    _viewport.beginScale(focalX: details.localFocalPoint.dx, paintedWidth: width, totalBins: totalBins);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          WaveformWindowLabels(
            fileDuration: widget.fileDuration,
            viewStart: _viewport.viewStart,
            viewEnd: _viewport.viewEnd,
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: waveformHeight,
            child: GestureDetector(
              onTapUp: _handleTap,
              onHorizontalDragStart: (_) {},
              onHorizontalDragUpdate: _handleHorizontalDragUpdate,
              onScaleStart: _handleScaleStart,
              onScaleUpdate: _handleScaleUpdate,
              onScaleEnd: _handleScaleEnd,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double width = constraints.maxWidth;
                  _availableWidth = width;

                  return Stack(
                    children: [
                      CustomPaint(key: _waveKey, painter: _waveformVisualizer, size: Size(width, waveformHeight)),
                      Markers(
                        rmsValues: widget.rmsValues,
                        paintedWidth: width,
                        waveFormHeight: waveformHeight,
                        markerPositions: widget.markerPositions,
                        selectedMarkerPosition: widget.selectedMarkerPosition,
                        viewStart: _viewport.viewStart,
                        viewEnd: _viewport.viewEnd,
                        onTap: widget.onPositionChange,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
