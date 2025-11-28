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
  final GlobalKey waveKey = GlobalKey();
  late WaveformVisualizer waveformVisualizer;
  late WaveformViewportController viewport;

  double availableWidth = 0;

  double get paintedWaveWidth {
    if (availableWidth > 0) return availableWidth;
    final buildContext = waveKey.currentContext;
    if (buildContext == null) return 0;
    final renderObject = buildContext.findRenderObject();
    if (renderObject is RenderBox) return renderObject.size.width;
    return 0;
  }

  @override
  void initState() {
    super.initState();
    viewport = WaveformViewportController(fileDuration: widget.fileDuration);
    rebuildVisualizer();
  }

  @override
  void didUpdateWidget(covariant Waveform oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.rmsValues != widget.rmsValues ||
        oldWidget.position != widget.position ||
        oldWidget.rangeStart != widget.rangeStart ||
        oldWidget.rangeEnd != widget.rangeEnd) {
      rebuildVisualizer();
    }
  }

  void rebuildVisualizer() {
    waveformVisualizer = WaveformVisualizer(
      widget.position,
      widget.rangeStart,
      widget.rangeEnd,
      widget.rmsValues,
      viewStart: viewport.viewStart,
      viewEnd: viewport.viewEnd,
    );
  }

  void handleTap(TapUpDetails details) {
    final double width = paintedWaveWidth;
    final int totalBins = widget.rmsValues.length;
    final snappedRelative = viewport.calculateSnappedRelativePosition(
      tapX: details.localPosition.dx,
      paintedWidth: width,
      totalBins: totalBins,
    );
    widget.onPositionChange(snappedRelative);
  }

  void panBy(double dxPixels) {
    final double width = paintedWaveWidth;
    if (width <= 0) return;

    setState(() {
      viewport.panByPixels(dxPixels: dxPixels, paintedWidth: width);
      rebuildVisualizer();
    });
  }

  void handleScaleUpdate(ScaleUpdateDetails details) {
    if (details.pointerCount < 2) return;

    setState(() {
      viewport.updateScale(details.scale);
      rebuildVisualizer();
    });
  }

  void handleScaleEnd(ScaleEndDetails details) => widget.onZoomChanged(viewport.viewStart, viewport.viewEnd);

  void handleHorizontalDragUpdate(DragUpdateDetails details) {
    final double? dx = details.primaryDelta;
    if (dx == null) return;
    panBy(dx);
  }

  void handleScaleStart(ScaleStartDetails details) {
    if (details.pointerCount < 2) return;

    final double width = paintedWaveWidth;
    final int totalBins = widget.rmsValues.length;
    viewport.beginScale(focalX: details.localFocalPoint.dx, paintedWidth: width, totalBins: totalBins);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          WaveformWindowLabels(
            fileDuration: widget.fileDuration,
            viewStart: viewport.viewStart,
            viewEnd: viewport.viewEnd,
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: waveformHeight,
            child: GestureDetector(
              onTapUp: handleTap,
              onHorizontalDragUpdate: handleHorizontalDragUpdate,
              onScaleStart: handleScaleStart,
              onScaleUpdate: handleScaleUpdate,
              onScaleEnd: handleScaleEnd,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double width = constraints.maxWidth;
                  availableWidth = width;

                  return Stack(
                    children: [
                      CustomPaint(key: waveKey, painter: waveformVisualizer, size: Size(width, waveformHeight)),
                      Markers(
                        rmsValues: widget.rmsValues,
                        paintedWidth: width,
                        waveFormHeight: waveformHeight,
                        markerPositions: widget.markerPositions,
                        selectedMarkerPosition: widget.selectedMarkerPosition,
                        viewStart: viewport.viewStart,
                        viewEnd: viewport.viewEnd,
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
