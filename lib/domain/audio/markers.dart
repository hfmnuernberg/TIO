import 'dart:collection';

import 'package:tiomusic/services/audio_system.dart';

typedef MarkerPeepCallback = void Function(double marker);

const double markerSoundFrequency = 2000;
const int markerSoundDurationInMilliseconds = 80;

class Markers {
  final Set<double> _triggered = {};

  final AudioSystem _as;
  int binCount = 1;
  double startAndEndEpsilon = 0;

  List<double> _positions = const [];
  UnmodifiableListView<double> get positions => UnmodifiableListView(_positions);
  set positions(List<double> value) {
    _positions = List.of(value);
  }

  Markers(this._as);

  Future<void> start() async {
    if (_positions.isEmpty) return;

    await _as.generatorStop();
    await _as.generatorStart();
  }

  Future<void> stop() async {
    await _as.generatorStop();
  }

  void reset() => _triggered.clear();

  Future<void> onPlaybackPositionChange({required double previousPosition, required double currentPosition}) async {
    if (previousPosition > currentPosition) {
      reset();
      return;
    }

    for (final position in positions.toSet()) {
      if (_triggered.contains(position)) continue;

      final bool crossed =
          (previousPosition == currentPosition && currentPosition >= position) ||
          (previousPosition < position && currentPosition >= position) ||
          (previousPosition > position && currentPosition <= position);

      final double halfBinTolerance = binCount <= 1 ? 1.0 : (0.5 / (binCount - 1));
      final bool closeEnoughAfter = (currentPosition >= position) && ((currentPosition - position) <= halfBinTolerance);

      final bool closeEnoughToLastMarker =
          (startAndEndEpsilon > 0.0) &&
          (position >= 1.0 - startAndEndEpsilon) &&
          (currentPosition >= 1.0 - startAndEndEpsilon);

      final bool closeEnoughToFirstMarker =
          (startAndEndEpsilon > 0.0) &&
          (position <= startAndEndEpsilon) &&
          (previousPosition <= startAndEndEpsilon) &&
          (currentPosition >= position);

      if (crossed || closeEnoughAfter || closeEnoughToLastMarker || closeEnoughToFirstMarker) {
        _triggered.add(position);
        await _playSound();
      }
    }
  }

  Future<void> _playSound() async {
    await _as.generatorNoteOn(newFreq: markerSoundFrequency);
    Future.delayed(Duration(milliseconds: markerSoundDurationInMilliseconds), _as.generatorNoteOff);
  }
}
