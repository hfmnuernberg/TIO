import 'dart:typed_data';

import 'package:tiomusic/domain/audio/player.dart';

const int maxZoomRmsBins = 150000;

Future<Float32List?> recalculateRmsForZoom({
  required Player player,
  required int targetVisibleBins,
  required double viewStart,
  required double viewEnd,
  required int currentBinCount,
}) async {
  final double span = (viewEnd - viewStart).clamp(0.0001, 1.0);
  if (targetVisibleBins <= 0) return null;

  int newTotalBins = (targetVisibleBins / span).round();

  if (newTotalBins < targetVisibleBins) newTotalBins = targetVisibleBins;
  if (newTotalBins > maxZoomRmsBins) newTotalBins = maxZoomRmsBins;

  if (newTotalBins == currentBinCount) return null;

  return player.getRmsValues(newTotalBins);
}
