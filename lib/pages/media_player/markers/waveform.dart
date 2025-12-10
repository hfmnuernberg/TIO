import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:tiomusic/pages/media_player/markers/markers.dart';
import 'package:tiomusic/pages/media_player/markers/waveform_gesture_helper.dart';
import 'package:tiomusic/pages/media_player/markers/waveform_viewport_controller.dart';
import 'package:tiomusic/pages/media_player/markers/waveform_gesture_controls.dart';
import 'package:tiomusic/pages/media_player/markers/waveform_window_labels.dart';
import 'package:tiomusic/pages/media_player/waveform_visualizer.dart';

const double waveformHeight = 200;

class Waveform extends StatefulWidget {
  final Float32List rmsValues;
  final double? position;
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
  late WaveformGestureHelper gestures;

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
    gestures = WaveformGestureHelper(
      viewport: viewport,
      getPaintedWidth: () => paintedWaveWidth,
      getTotalBins: () => widget.rmsValues.length,
      onPositionChange: widget.onPositionChange,
      onZoomChanged: widget.onZoomChanged,
      setState: setState,
      rebuildVisualizer: rebuildVisualizer,
    );
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
    if (widget.position != null) {
      waveformVisualizer = WaveformVisualizer(
        widget.position!,
        widget.rangeStart,
        widget.rangeEnd,
        widget.rmsValues,
        viewStart: viewport.viewStart,
        viewEnd: viewport.viewEnd,
      );
    } else {
      waveformVisualizer = WaveformVisualizer.setTrim(
        widget.rangeStart,
        widget.rangeEnd,
        widget.rmsValues,
        viewStart: viewport.viewStart,
        viewEnd: viewport.viewEnd,
      );
    }
  }

  void handleZoomByFactor({required double factor}) {
    setState(() {
      viewport.zoomAroundCenter(factor: factor);
      rebuildVisualizer();
    });
    widget.onZoomChanged(viewport.viewStart, viewport.viewEnd);
  }

  void handleScrollBySpan({required bool forward}) {
    setState(() {
      viewport.scrollBySpan(forward: forward);
      rebuildVisualizer();
    });
    widget.onZoomChanged(viewport.viewStart, viewport.viewEnd);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              WaveformWindowLabels(
                fileDuration: widget.fileDuration,
                viewStart: viewport.viewStart,
                viewEnd: viewport.viewEnd,
              ),
              SizedBox(
                height: waveformHeight,
                child: Listener(
                  onPointerDown: gestures.handlePointerDown,
                  onPointerUp: gestures.handlePointerUp,
                  child: GestureDetector(
                    onTapUp: gestures.handleTap,
                    onScaleStart: gestures.handleScaleStart,
                    onScaleUpdate: gestures.handleScaleUpdate,
                    onScaleEnd: gestures.handleScaleEnd,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final double width = constraints.maxWidth;
                        availableWidth = width;

                        return Stack(
                          children: [
                            CustomPaint(
                              key: waveKey,
                              painter: waveformVisualizer,
                              size: Size(width, waveformHeight),
                            ),
                            if (widget.markerPositions.isNotEmpty)
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
        ),
        Transform.translate(
          offset: const Offset(0, -12),
          child: WaveformGestureControls(
            fileDuration: widget.fileDuration,
            position: widget.position ?? 0.0,
            viewport: viewport,
            onZoomIn: () => handleZoomByFactor(factor: 0.5),
            onZoomOut: () => handleZoomByFactor(factor: 2),
            onScrollLeft: () => handleScrollBySpan(forward: false),
            onScrollRight: () => handleScrollBySpan(forward: true),
          ),
        ),
      ],
    );
  }
}
