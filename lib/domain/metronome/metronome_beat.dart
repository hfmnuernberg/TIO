class MetronomeBeat {
  final int? segmentIndex;
  final int? mainBeatIndex;
  final int? polyBeatIndex;

  const MetronomeBeat({this.segmentIndex, this.mainBeatIndex, this.polyBeatIndex});

  @override
  int get hashCode => segmentIndex.hashCode ^ mainBeatIndex.hashCode ^ polyBeatIndex.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MetronomeBeat &&
          runtimeType == other.runtimeType &&
          segmentIndex == other.segmentIndex &&
          mainBeatIndex == other.mainBeatIndex &&
          polyBeatIndex == other.polyBeatIndex;

  @override
  String toString() =>
      'MetronomeBeat(segmentIndex: $segmentIndex, mainBeatIndex: $mainBeatIndex, polyBeatIndex: $polyBeatIndex)';
}
