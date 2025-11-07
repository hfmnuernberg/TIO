class MarkerNavigation {
  static const double eps = 1e-6;
  static const windowInSeconds = 0.75;

  static double next(double pos, List<double> sortedMarkers) {
    for (final m in sortedMarkers) {
      if (m > pos + eps) return m;
    }
    return sortedMarkers.first;
  }

  static double previous(double position, List<double> sortedMarkers) {
    for (final m in sortedMarkers.reversed) {
      if (m < position - eps) return m;
    }
    return sortedMarkers.last;
  }

  static double previousWithWindow({
    required double position,
    required List<double> sortedMarkers,
    required Duration fileDuration,
  }) {
    final candidate = previous(position, sortedMarkers);

    final totalSecs = fileDuration.inSeconds.toDouble();
    final windowFactor = totalSecs > 0 ? (windowInSeconds / totalSecs) : 0.0;

    final double distanceAfterCandidate =
    (position >= candidate) ? (position - candidate) : ((1.0 - candidate) + position);

    if (distanceAfterCandidate <= windowFactor) {
      final index = sortedMarkers.indexOf(candidate);
      final prevIndex = (index - 1 + sortedMarkers.length) % sortedMarkers.length;
      return sortedMarkers[prevIndex];
    }

    return candidate;
  }
}
