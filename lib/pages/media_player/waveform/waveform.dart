import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:tiomusic/pages/media_player/waveform_visualizer.dart';
import 'package:tiomusic/pages/media_player/markers/markers.dart';

class Waveform extends StatefulWidget {
  final Float32List rmsValues;
  final double position;
  final double rangeStart;
  final double rangeEnd;
  final double height;
  final ValueChanged<double> onPositionChange;
  final void Function(double viewStart, double viewEnd) onViewWindowChange;
  final List<double> markerPositions;
  final double? selectedMarkerPosition;
  final ValueChanged<double> onMarkerTap;

  const Waveform({
    super.key,
    required this.rmsValues,
    required this.position,
    required this.rangeStart,
    required this.rangeEnd,
    required this.height,
    required this.onPositionChange,
    required this.onViewWindowChange,
    required this.markerPositions,
    required this.selectedMarkerPosition,
    required this.onMarkerTap,
  });

  @override
  State<Waveform> createState() => _WaveformState();
}

class _WaveformState extends State<Waveform> {
  final GlobalKey _waveKey = GlobalKey();
  late WaveformVisualizer _waveformVisualizer;

  double _viewStart = 0;
  double _viewEnd = 1;
  double _availableWidth = 0;

  static const double _minSpan = 1 / 10;
  static const double _maxSpan = 1;

  double _initialViewStart = 0;
  double _initialViewEnd = 1;
  double _pinchFocalPosition = 0.5;

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
    _rebuildVisualizer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifyViewWindowChanged();
    });
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
      viewStart: _viewStart,
      viewEnd: _viewEnd,
    );
  }


  void _handleTap(TapUpDetails details) {
    final snappedRelative = _calculateSnappedRelativePosition(details.localPosition.dx);
    widget.onPositionChange(snappedRelative);
  }

  double _calculateSnappedRelativePosition(double tapX) {
    final int totalBins = widget.rmsValues.length;
    if (totalBins <= 1) return 0;

    final double clampedStart = _viewStart.clamp(0.0, 1.0);
    final double clampedEnd = _viewEnd.clamp(clampedStart, 1.0);

    final int firstVisibleIndex = (clampedStart * (totalBins - 1)).round().clamp(0, totalBins - 1);
    final int lastVisibleIndex = (clampedEnd * (totalBins - 1)).round().clamp(firstVisibleIndex, totalBins - 1);

    final int visibleBins = (lastVisibleIndex - firstVisibleIndex + 1).clamp(1, totalBins);

    final double width = _paintedWaveWidth;
    if (width <= 0) return clampedStart;

    final int localIndex = WaveformVisualizer.indexForX(tapX, width, visibleBins);

    final double localFraction = visibleBins > 1 ? localIndex / (visibleBins - 1) : 0.0;

    final double span = (clampedEnd - clampedStart).clamp(_minSpan, _maxSpan);
    return clampedStart + localFraction * span;
  }

  void _panBy(double dxPixels) {
    final double width = _paintedWaveWidth;
    if (width <= 0) return;

    final double span = (_viewEnd - _viewStart).clamp(_minSpan, _maxSpan);
    if (span <= 0) return;

    final double deltaFraction = -dxPixels / width * span;

    double start = _viewStart + deltaFraction;
    double end = _viewEnd + deltaFraction;

    if (start < 0) {
      end -= start;
      start = 0;
    }
    if (end > 1) {
      start -= end - 1;
      end = 1;
    }

    setState(() {
      _viewStart = start;
      _viewEnd = end;
      _rebuildVisualizer();
    });
    _notifyViewWindowChanged();
  }

  void _notifyViewWindowChanged() => widget.onViewWindowChange(_viewStart, _viewEnd);

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (details.pointerCount < 2) return;

    final double scale = details.scale;
    final double initialSpan = _initialViewEnd - _initialViewStart;

    double newSpan = (initialSpan / scale).clamp(_minSpan, _maxSpan);

    double center = _pinchFocalPosition;
    double start = center - newSpan / 2;
    double end = center + newSpan / 2;

    if (start < 0) {
      end -= start;
      start = 0;
    }
    if (end > 1) {
      start -= end - 1;
      end = 1;
    }

    setState(() {
      _viewStart = start;
      _viewEnd = end;
      _rebuildVisualizer();
    });
    _notifyViewWindowChanged();
  }

  void _handleHorizontalDragUpdate(DragUpdateDetails details) {
    final double? dx = details.primaryDelta;
    if (dx == null) return;
    _panBy(dx);
  }

  void _handleScaleStart(ScaleStartDetails details) {
    if (details.pointerCount < 2) return;
    _initialViewStart = _viewStart;
    _initialViewEnd = _viewEnd;

    final dx = details.localFocalPoint.dx;
    _pinchFocalPosition = _calculateSnappedRelativePosition(dx);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTapUp: _handleTap,
        onHorizontalDragStart: (_) {},
        onHorizontalDragUpdate: _handleHorizontalDragUpdate,
        onScaleStart: _handleScaleStart,
        onScaleUpdate: _handleScaleUpdate,
        child: SizedBox(
          width: double.infinity,
          height: widget.height,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double width = constraints.maxWidth;
              _availableWidth = width;

              return Stack(
                children: [
                  CustomPaint(key: _waveKey, painter: _waveformVisualizer, size: Size(width, widget.height)),
                  Markers(
                    rmsValues: widget.rmsValues,
                    paintedWidth: width,
                    waveFormHeight: widget.height,
                    markerPositions: widget.markerPositions,
                    selectedMarkerPosition: widget.selectedMarkerPosition,
                    viewStart: _viewStart,
                    viewEnd: _viewEnd,
                    onTap: widget.onMarkerTap,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
