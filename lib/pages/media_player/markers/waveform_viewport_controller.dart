import 'package:tiomusic/pages/media_player/waveform_visualizer.dart';

class WaveformViewportController {
  final Duration fileDuration;
  double viewStart;
  double viewEnd;

  final double _maxSpan = 1;
  double _initialViewStart;
  double _initialViewEnd;
  double _pinchFocalPosition;

  WaveformViewportController({required this.fileDuration, this.viewStart = 0.0, this.viewEnd = 1.0})
    : _initialViewStart = viewStart,
      _initialViewEnd = viewEnd,
      _pinchFocalPosition = 0.5;

  double get _minSpan {
    final seconds = fileDuration.inMilliseconds / 1000.0;
    if (seconds <= 1.0) return 1;
    return (1.0 / seconds).clamp(0.0, 1.0);
  }

  double calculateSnappedRelativePosition({
    required double tapX,
    required double paintedWidth,
    required int totalBins,
  }) {
    if (totalBins <= 1) return 0;
    if (paintedWidth <= 0) return viewStart.clamp(0.0, 1.0);

    final double clampedStart = viewStart.clamp(0.0, 1.0);
    final double clampedEnd = viewEnd.clamp(clampedStart, 1.0);

    final int firstVisibleIndex = (clampedStart * (totalBins - 1)).round().clamp(0, totalBins - 1);
    final int lastVisibleIndex = (clampedEnd * (totalBins - 1)).round().clamp(firstVisibleIndex, totalBins - 1);
    final int visibleBins = (lastVisibleIndex - firstVisibleIndex + 1).clamp(1, totalBins);

    final int localIndex = WaveformVisualizer.indexForX(tapX, paintedWidth, visibleBins);

    final int globalIndex = (firstVisibleIndex + localIndex).clamp(0, totalBins - 1);

    return totalBins > 1 ? globalIndex / (totalBins - 1) : 0.0;
  }

  void panByPixels({required double dxPixels, required double paintedWidth}) {
    if (paintedWidth <= 0) return;

    final double span = (viewEnd - viewStart).clamp(_minSpan, _maxSpan);
    if (span <= 0) return;

    final double deltaFraction = -dxPixels / paintedWidth * span;

    double start = viewStart + deltaFraction;
    double end = viewEnd + deltaFraction;

    if (start < 0) {
      end -= start;
      start = 0;
    }
    if (end > 1) {
      start -= end - 1;
      end = 1;
    }

    viewStart = start;
    viewEnd = end;
  }

  void beginScale({required double focalX, required double paintedWidth, required int totalBins}) {
    _initialViewStart = viewStart;
    _initialViewEnd = viewEnd;

    _pinchFocalPosition = calculateSnappedRelativePosition(
      tapX: focalX,
      paintedWidth: paintedWidth,
      totalBins: totalBins,
    );
  }

  void updateScale(double scale) {
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

    viewStart = start;
    viewEnd = end;
  }

  void zoomAroundCenter(double factor) {
    final double span = (viewEnd - viewStart).clamp(_minSpan, _maxSpan);
    if (span <= 0) return;

    final double center = (viewStart + viewEnd) / 2;
    double newSpan = (span * factor).clamp(_minSpan, _maxSpan);

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

    viewStart = start;
    viewEnd = end;
  }

  void scrollBySpan(double direction) {
    if (direction == 0) return;

    final double span = (viewEnd - viewStart).clamp(_minSpan, _maxSpan);
    if (span <= 0) return;

    double start = viewStart + direction * span;
    double end = viewEnd + direction * span;

    if (start < 0) {
      end -= start;
      start = 0;
    }
    if (end > 1) {
      start -= end - 1;
      end = 1;
    }

    viewStart = start;
    viewEnd = end;
  }
}
