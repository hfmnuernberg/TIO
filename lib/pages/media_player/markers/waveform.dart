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
  bool? isZooming;

  int activePointers = 0;
  bool multiTouchInProgress = false;

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

  void handlePointerDown(PointerDownEvent event) {
    activePointers++;
    if (activePointers >= 2) {
      multiTouchInProgress = true;
    }
  }

  void handlePointerUp(PointerUpEvent event) {
    activePointers--;
    if (activePointers <= 0) {
      activePointers = 0;
      multiTouchInProgress = false;
    }
  }

  void handleTap(TapUpDetails details) {
    if (multiTouchInProgress) return;

    final double width = paintedWaveWidth;
    final int totalBins = widget.rmsValues.length;
    final snappedRelative = viewport.calculateSnappedRelativePosition(
      tapX: details.localPosition.dx,
      paintedWidth: width,
      totalBins: totalBins,
    );
    widget.onPositionChange(snappedRelative);
  }

  void handleScaleStart(ScaleStartDetails details) {
    isZooming = null;

    final double width = paintedWaveWidth;
    final int totalBins = widget.rmsValues.length;
    if (width <= 0 || totalBins <= 0) return;

    if (details.pointerCount == 1 && !multiTouchInProgress) {
      final double snappedRelative = viewport.calculateSnappedRelativePosition(
        tapX: details.localFocalPoint.dx,
        paintedWidth: width,
        totalBins: totalBins,
      );
      widget.onPositionChange(snappedRelative);
    } else if (details.pointerCount >= 2) {
      viewport.beginScale(focalX: details.localFocalPoint.dx, paintedWidth: width, totalBins: totalBins);
    }
  }

  void handleScaleUpdate(ScaleUpdateDetails details) {
    final double width = paintedWaveWidth;
    final int totalBins = widget.rmsValues.length;
    if (width <= 0 || totalBins <= 0) return;

    if (details.pointerCount == 1 && !multiTouchInProgress) {
      final double snappedRelative = viewport.calculateSnappedRelativePosition(
        tapX: details.localFocalPoint.dx,
        paintedWidth: width,
        totalBins: totalBins,
      );
      widget.onPositionChange(snappedRelative);
    } else if (details.pointerCount >= 2) {
      setState(() {
        const double scaleDecisionThreshold = 0.1;
        const double panDecisionThresholdPx = 2;

        if (isZooming == null) {
          final bool zoomCandidate = (details.scale - 1.0).abs() > scaleDecisionThreshold;
          final bool panCandidate = details.focalPointDelta.dx.abs() > panDecisionThresholdPx;

          if (panCandidate && !zoomCandidate) {
            isZooming = false;
          } else if (zoomCandidate && !panCandidate) {
            isZooming = true;
          } else if (zoomCandidate && panCandidate) {
            isZooming = false;
          } else {
            return;
          }
        }

        if (isZooming ?? false) {
          viewport.updateScale(details.scale);
        } else {
          if (details.focalPointDelta.dx != 0) {
            viewport.panByPixels(dxPixels: details.focalPointDelta.dx, paintedWidth: width);
          }
        }

        rebuildVisualizer();
      });
    }
  }

  void handleScaleEnd(ScaleEndDetails details) {
    isZooming = null;
    widget.onZoomChanged(viewport.viewStart, viewport.viewEnd);
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
            child: Listener(
              onPointerDown: handlePointerDown,
              onPointerUp: handlePointerUp,
              child: GestureDetector(
                onTapUp: handleTap,
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
          ),
        ],
      ),
    );
  }
}
