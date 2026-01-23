import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:tiomusic/pages/media_player/markers/markers.dart';
import 'package:tiomusic/pages/media_player/markers/waveform_gesture_controls.dart';
import 'package:tiomusic/pages/media_player/markers/waveform_gesture_helper.dart';
import 'package:tiomusic/pages/media_player/markers/waveform_time_labels.dart';
import 'package:tiomusic/pages/media_player/markers/waveform_viewport_controller.dart';
import 'package:tiomusic/pages/media_player/waveform_visualizer.dart';

const double waveformHeight = 300;

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
  final Future<void> Function() onInteractionStart;
  final Future<void> Function() onInteractionEnd;
  final Duration scrubSeekThreshold;

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
    required this.onInteractionStart,
    required this.onInteractionEnd,
    this.scrubSeekThreshold = const Duration(milliseconds: 500),
  });

  @override
  State<Waveform> createState() => _WaveformState();
}

class _WaveformState extends State<Waveform> {
  final GlobalKey _waveKey = GlobalKey();
  late final WaveformViewportController _viewport;
  late final WaveformGestureHelper _gestures;
  late WaveformVisualizer _visualizer;

  double _availableWidth = 0;
  double? _previewPosition;
  bool _isInteracting = false;
  double? get _effectivePosition {
    if (widget.position == null) return null;
    return _previewPosition ?? widget.position;
  }

  double get _paintedWaveWidth {
    if (_availableWidth > 0) return _availableWidth;
    final ctx = _waveKey.currentContext;
    if (ctx == null) return 0;
    final renderObject = ctx.findRenderObject();
    return renderObject is RenderBox ? renderObject.size.width : 0;
  }

  @override
  void initState() {
    super.initState();
    _viewport = WaveformViewportController(fileDuration: widget.fileDuration);
    _gestures = WaveformGestureHelper(
      viewport: _viewport,
      scrubSeekThreshold: widget.scrubSeekThreshold,
      getPaintedWidth: () => _paintedWaveWidth,
      getTotalBins: () => widget.rmsValues.length,
      onPositionChange: widget.onPositionChange,
      onScrubPreviewPosition: widget.position == null
          ? null
          : (relative) => setState(() {
              _previewPosition = relative;
              _rebuildVisualizer();
            }),
      onZoomChanged: widget.onZoomChanged,
      onInteractionStart: () async {
        setState(() => _isInteracting = true);
        await widget.onInteractionStart();
      },
      onInteractionEnd: () async {
        await widget.onInteractionEnd();
        if (!mounted) return;
        setState(() {
          _isInteracting = false;
          _previewPosition = null;
        });
      },
      setState: setState,
      rebuildVisualizer: _rebuildVisualizer,
    );
    _rebuildVisualizer();
  }

  @override
  void didUpdateWidget(covariant Waveform oldWidget) {
    super.didUpdateWidget(oldWidget);
    final rmsChanged = oldWidget.rmsValues != widget.rmsValues;
    final rangeChanged = oldWidget.rangeStart != widget.rangeStart || oldWidget.rangeEnd != widget.rangeEnd;
    final posChanged = oldWidget.position != widget.position;
    if (rmsChanged || rangeChanged || (posChanged && !_isInteracting)) {
      if (!_isInteracting) _previewPosition = null;
      _rebuildVisualizer();
    }
  }

  void _rebuildVisualizer() {
    final pos = _effectivePosition;
    _visualizer = pos != null
        ? WaveformVisualizer(
            pos,
            widget.rangeStart,
            widget.rangeEnd,
            widget.rmsValues,
            viewStart: _viewport.viewStart,
            viewEnd: _viewport.viewEnd,
          )
        : WaveformVisualizer.setTrim(
            widget.rangeStart,
            widget.rangeEnd,
            widget.rmsValues,
            viewStart: _viewport.viewStart,
            viewEnd: _viewport.viewEnd,
          );
  }

  void _zoom(double factor) {
    setState(() {
      _viewport.zoomAroundCenter(factor: factor);
      _rebuildVisualizer();
    });
    widget.onZoomChanged(_viewport.viewStart, _viewport.viewEnd);
  }

  void _scroll(bool forward) {
    setState(() {
      _viewport.scrollBySpan(forward: forward);
      _rebuildVisualizer();
    });
    widget.onZoomChanged(_viewport.viewStart, _viewport.viewEnd);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Transform.translate(
                offset: const Offset(0, 8),
                child: WaveformGestureControls(
                  fileDuration: widget.fileDuration,
                  viewStart: _viewport.viewStart,
                  viewEnd: _viewport.viewEnd,
                  viewport: _viewport,
                  onZoomIn: () => _zoom(0.5),
                  onZoomOut: () => _zoom(2),
                  onScrollLeft: () => _scroll(false),
                  onScrollRight: () => _scroll(true),
                ),
              ),
              SizedBox(
                height: waveformHeight,
                child: Listener(
                  onPointerDown: _gestures.handlePointerDown,
                  onPointerUp: _gestures.handlePointerUp,
                  child: GestureDetector(
                    onTapUp: _gestures.handleTap,
                    onScaleStart: _gestures.handleScaleStart,
                    onScaleUpdate: _gestures.handleScaleUpdate,
                    onScaleEnd: _gestures.handleScaleEnd,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        _availableWidth = constraints.maxWidth;
                        final width = _availableWidth;
                        return Stack(
                          children: [
                            CustomPaint(key: _waveKey, painter: _visualizer, size: Size(width, waveformHeight)),
                            if (widget.markerPositions.isNotEmpty)
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
              ),
            ],
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -8),
          child: WaveformTimeLabels(
            fileDuration: widget.fileDuration,
            rangeStart: widget.rangeStart,
            rangeEnd: widget.rangeEnd,
            position: _effectivePosition,
          ),
        ),
      ],
    );
  }
}
