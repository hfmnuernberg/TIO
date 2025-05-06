int _getNextPolyBeatCount(int beatCount, int polyBeatCount) {
  var next = polyBeatCount + 1;
  while (beatCount > polyBeatCount ? beatCount % next != 0 : next % beatCount != 0) {
    next++;
  }
  return next;
}

int _getPrevPolyBeatCount(int beatCount, int polyBeatCount) {
  var prev = polyBeatCount - 1;
  if (prev <= 0) return 0;
  while (beatCount >= polyBeatCount ? beatCount % prev != 0 : prev % beatCount != 0) {
    prev--;
  }
  return prev;
}

int getIncrementStepForPolyBeat(int beatCount, int polyBeatCount) {
  return _getNextPolyBeatCount(beatCount, polyBeatCount) - polyBeatCount;
}

int getDecrementStepForPolyBeat(int beatCount, int polyBeatCount) {
  return polyBeatCount - _getPrevPolyBeatCount(beatCount, polyBeatCount);
}
