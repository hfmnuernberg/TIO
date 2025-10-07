class MetronomeBeatEvent {
  final bool isPoly;
  final bool isSecondary;
  final bool isFast;

  MetronomeBeatEvent({this.isPoly = false, this.isSecondary = false, this.isFast = false});

  @override
  int get hashCode => isPoly.hashCode ^ isSecondary.hashCode ^ isFast.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MetronomeBeatEvent &&
          runtimeType == other.runtimeType &&
          isPoly == other.isPoly &&
          isSecondary == other.isSecondary &&
          isFast == other.isFast;

  @override
  String toString() => 'Beat(isPoly: $isPoly, isSecondary: $isSecondary, isFast: $isFast)';
}
