class MarkerNavigation {
  static const double eps = 1e-6;
  static const windowInSeconds = 0.75;

  static double next(double pos, List<double> sortedMarkers) {
    for (final m in sortedMarkers) {
      if (m > pos + eps) return m;
    }
    return 1;
  }

  static double previousWithWindow({
    required double position,
    required List<double> sortedMarkers,
    required Duration fileDuration,
  }) {
    final index = sortedMarkers.lastIndexWhere((m) => m < position - eps);

    if (index == -1) return 0;

    final candidate = sortedMarkers[index];

    final totalSecs = fileDuration.inSeconds.toDouble();
    final windowFactor = totalSecs > 0 ? (windowInSeconds / totalSecs) : 0.0;

    final distance = position - candidate;
    if (distance <= windowFactor) return index > 0 ? sortedMarkers[index - 1] : 0;

    return candidate;
  }
}
