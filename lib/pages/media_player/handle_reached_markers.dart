typedef MarkerPeepCallback = void Function(double marker);

const epsilon = 0.005;

class MarkerHandler {
  final Set<double> _triggered = {};

  MarkerHandler();

  void checkMarkers({
    required double previousPosition,
    required double currentPosition,
    required List<double> markers,
    required MarkerPeepCallback onPeep,
  }) {
    for (final marker in markers.toSet()) {
      if (_triggered.contains(marker)) continue;

      final bool crossed =
          (previousPosition == currentPosition && currentPosition >= marker) ||
          (previousPosition < marker && currentPosition >= marker) ||
          (previousPosition > marker && currentPosition <= marker);

      final bool closeEnough = (currentPosition - marker).abs() <= epsilon;

      if (crossed || closeEnough) {
        _triggered.add(marker);
        onPeep(marker);
      }
    }
  }

  void reset() => _triggered.clear();
}
