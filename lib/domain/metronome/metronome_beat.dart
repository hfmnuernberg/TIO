class MetronomeBeat {
  final int? segmentIndex;
  final int? mainBeatIndex;
  final int? polyBeatIndex;

  const MetronomeBeat({this.segmentIndex, this.mainBeatIndex, this.polyBeatIndex});

  @override
  String toString() =>
      'MetronomeBeat(segmentIndex: $segmentIndex, mainBeatIndex: $mainBeatIndex, polyBeatIndex: $polyBeatIndex)';
}
