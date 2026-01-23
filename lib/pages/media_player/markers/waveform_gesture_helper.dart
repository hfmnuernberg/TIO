import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:tiomusic/pages/media_player/markers/waveform_viewport_controller.dart';

class WaveformGestureHelper {
  final WaveformViewportController viewport;
  final Duration scrubSeekThreshold;
  final double Function() getPaintedWidth;
  final int Function() getTotalBins;
  final void Function(double relative) onPositionChange;
  final void Function(double relative)? onScrubPreviewPosition;
  final void Function(double viewStart, double viewEnd) onZoomChanged;
  final Future<void> Function() onInteractionStart;
  final Future<void> Function() onInteractionEnd;
  final void Function(void Function()) setState;
  final VoidCallback rebuildVisualizer;

  bool? isZooming;
  int activePointers = 0;
  bool multiTouchInProgress = false;
  DateTime? _lastSeekSentAt;
  double? _pendingScrubRelative;

  WaveformGestureHelper({
    required this.viewport,
    required this.scrubSeekThreshold,
    required this.getPaintedWidth,
    required this.getTotalBins,
    required this.onPositionChange,
    this.onScrubPreviewPosition,
    required this.onZoomChanged,
    required this.onInteractionStart,
    required this.onInteractionEnd,
    required this.setState,
    required this.rebuildVisualizer,
  });

  double get _paintedWidth => getPaintedWidth();
  int get _totalBins => getTotalBins();

  void handlePointerDown(PointerDownEvent event) async {
    if (event.kind != PointerDeviceKind.touch) return;

    await onInteractionStart();

    activePointers++;
    if (activePointers >= 2) multiTouchInProgress = true;
  }

  void handlePointerUp(PointerUpEvent event) async {
    if (event.kind != PointerDeviceKind.touch) return;

    activePointers--;
    if (activePointers <= 0) {
      activePointers = 0;
      multiTouchInProgress = false;
      await onInteractionEnd();
    }
  }

  void handleTap(TapUpDetails details) {
    if (multiTouchInProgress) return;

    final double width = _paintedWidth;
    final int totalBins = _totalBins;
    if (width <= 0 || totalBins <= 0) return;

    final snappedRelative = viewport.calculateSnappedRelativePosition(
      tapX: details.localPosition.dx,
      paintedWidth: width,
      totalBins: totalBins,
    );
    _emitScrubPreview(snappedRelative);
    _lastSeekSentAt = DateTime.now();
    _pendingScrubRelative = null;
    onPositionChange(snappedRelative);
  }

  void handleScaleStart(ScaleStartDetails details) async {
    isZooming = null;

    final double width = _paintedWidth;
    final int totalBins = _totalBins;
    if (width <= 0 || totalBins <= 0) return;

    if (details.pointerCount == 1 && !multiTouchInProgress) {
      final double snappedRelative = viewport.calculateSnappedRelativePosition(
        tapX: details.localFocalPoint.dx,
        paintedWidth: width,
        totalBins: totalBins,
      );
      _emitScrubPreview(snappedRelative);
      _scheduleScrubSeek(snappedRelative);
    } else if (details.pointerCount >= 2) {
      viewport.beginScale(focalX: details.localFocalPoint.dx, paintedWidth: width, totalBins: totalBins);
    }
  }

  void handleScaleUpdate(ScaleUpdateDetails details) {
    final double width = _paintedWidth;
    final int totalBins = _totalBins;
    if (width <= 0 || totalBins <= 0) return;

    if (details.pointerCount == 1 && !multiTouchInProgress) {
      final double snappedRelative = viewport.calculateSnappedRelativePosition(
        tapX: details.localFocalPoint.dx,
        paintedWidth: width,
        totalBins: totalBins,
      );
      _emitScrubPreview(snappedRelative);
      _scheduleScrubSeek(snappedRelative);
      return;
    }

    if (details.pointerCount >= 2) {
      setState(() {
        const double strongZoomThreshold = 0.07; // 7% change => definitely zoom
        const double weakZoomThreshold = 0.015; // 1.5% change, easier small pinch zoom
        const double panDecisionThresholdPx = 1; // keep pan threshold very sensitive
        const double maxScaleForPan = 0.06; // tolerate up to 6% scale drift for pan

        final double scaleDelta = (details.scale - 1.0).abs();
        final double dx = details.focalPointDelta.dx.abs();

        if (isZooming == null) {
          if (scaleDelta > strongZoomThreshold) {
            // Very clear pinch/spread -> zoom.
            isZooming = true;
          } else if (dx > panDecisionThresholdPx && scaleDelta < maxScaleForPan) {
            // Fingers mostly moving together horizontally with only tiny scale drift -> pan.
            isZooming = false;
          } else if (scaleDelta > weakZoomThreshold && dx <= panDecisionThresholdPx) {
            // A bit of scale, but almost no horizontal move -> treat as zoom.
            isZooming = true;
          } else {
            // Not enough evidence yet, wait for more movement.
            return;
          }
        }

        if (isZooming ?? false) {
          if (scaleDelta > 0) viewport.updateScale(scale: details.scale);
        } else {
          if (details.focalPointDelta.dx != 0) {
            viewport.panByPixels(dxPixels: details.focalPointDelta.dx, paintedWidth: width);
          }
        }

        rebuildVisualizer();
      });
    }
  }

  void handleScaleEnd(ScaleEndDetails details) async {
    isZooming = null;

    if (details.pointerCount <= 1 && !multiTouchInProgress) _flushScrubSeek();

    onZoomChanged(viewport.viewStart, viewport.viewEnd);
    await onInteractionEnd();
  }

  void _emitScrubPreview(double relative) => onScrubPreviewPosition?.call(relative);

  void _scheduleScrubSeek(double relative) {
    _pendingScrubRelative = relative;

    if (scrubSeekThreshold == Duration.zero) {
      _lastSeekSentAt = DateTime.now();
      final pending = _pendingScrubRelative;
      _pendingScrubRelative = null;
      if (pending != null) onPositionChange(pending);
      return;
    }

    final now = DateTime.now();
    final last = _lastSeekSentAt;
    final shouldSendNow = last == null || now.difference(last) >= scrubSeekThreshold;

    if (shouldSendNow) {
      _lastSeekSentAt = now;
      final pending = _pendingScrubRelative;
      _pendingScrubRelative = null;
      if (pending != null) onPositionChange(pending);
    }
  }

  void _flushScrubSeek() {
    final pending = _pendingScrubRelative;
    _pendingScrubRelative = null;
    if (pending != null) {
      _lastSeekSentAt = DateTime.now();
      onPositionChange(pending);
    }
  }
}
