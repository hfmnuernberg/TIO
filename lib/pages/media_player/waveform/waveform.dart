import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:tiomusic/pages/media_player/waveform_visualizer.dart';
import 'package:tiomusic/util/constants.dart';

class Waveform extends StatefulWidget {
  final Float32List rmsValues;
  final double playbackPosition;
  final double rangeStart;
  final double rangeEnd;
  final double height;
  final EdgeInsetsGeometry padding;
  final ValueChanged<double> onPositionChange;
  final ValueChanged<double>? onPaintedWidthChange;
  final void Function(double viewStart, double viewEnd)? onViewWindowChange;

  const Waveform({
    super.key,
    required this.rmsValues,
    required this.playbackPosition,
    required this.rangeStart,
    required this.rangeEnd,
    required this.height,
    required this.onPositionChange,
    this.onPaintedWidthChange,
    this.onViewWindowChange,
    this.padding = const EdgeInsets.fromLTRB(TIOMusicParams.edgeInset, 0, TIOMusicParams.edgeInset, 0),
  });

  @override
  State<Waveform> createState() => _WaveformState();
}

class _WaveformState extends State<Waveform> {
  final GlobalKey _waveKey = GlobalKey();
  late WaveformVisualizer _waveformVisualizer;

  double _viewStart = 0;
  double _viewEnd = 1;

  static const double _minSpan = 1 / 10;
  static const double _maxSpan = 1;

  double _initialViewStart = 0;
  double _initialViewEnd = 1;
  double _pinchFocalPosition = 0.5;

  double get _paintedWaveWidth {
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
      _notifyPaintedWidth();
      _notifyViewWindowChanged();
    });
  }

  @override
  void didUpdateWidget(covariant Waveform oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.rmsValues != widget.rmsValues ||
        oldWidget.playbackPosition != widget.playbackPosition ||
        oldWidget.rangeStart != widget.rangeStart ||
        oldWidget.rangeEnd != widget.rangeEnd) {
      _rebuildVisualizer();
      WidgetsBinding.instance.addPostFrameCallback((_) => _notifyPaintedWidth());
    }
  }

  void _rebuildVisualizer() {
    _waveformVisualizer = WaveformVisualizer(
      widget.playbackPosition,
      widget.rangeStart,
      widget.rangeEnd,
      widget.rmsValues,
      viewStart: _viewStart,
      viewEnd: _viewEnd,
    );
  }

  void _notifyPaintedWidth() {
    if (widget.onPaintedWidthChange == null) return;
    final width = _paintedWaveWidth;
    if (width > 0) widget.onPaintedWidthChange!(width);
  }

  void _handleTap(Offset localPosition) {
    final snappedRelative = _calculateSnappedRelativePosition(localPosition.dx);
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

  void _notifyViewWindowChanged() {
    if (widget.onViewWindowChange == null) return;
    widget.onViewWindowChange!(_viewStart, _viewEnd);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: GestureDetector(
        onTapUp: (details) => _handleTap(details.localPosition),
        onHorizontalDragStart: (_) {},
        onHorizontalDragUpdate: (details) {
          final double? dx = details.primaryDelta;
          if (dx == null) return;
          _panBy(dx);
        },
        onScaleStart: (details) {
          if (details.pointerCount < 2) return;
          _initialViewStart = _viewStart;
          _initialViewEnd = _viewEnd;

          final dx = details.localFocalPoint.dx;
          _pinchFocalPosition = _calculateSnappedRelativePosition(dx);
        },
        onScaleUpdate: (details) {
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
        },
        child: SizedBox(
          width: double.infinity,
          height: widget.height,
          child: CustomPaint(
            key: _waveKey,
            painter: _waveformVisualizer,
          ),
        ),
      ),
    );
  }
}
