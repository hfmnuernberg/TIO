class MetronomeBeatEvent {
  final bool isPoly;
  final bool isSecondary;

  MetronomeBeatEvent({this.isPoly = false, this.isSecondary = false});

  @override
  int get hashCode => isPoly.hashCode ^ isSecondary.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MetronomeBeatEvent &&
          runtimeType == other.runtimeType &&
          isPoly == other.isPoly &&
          isSecondary == other.isSecondary;

  @override
  String toString() => 'Beat(isPoly: $isPoly, isSecondary: $isSecondary)';
}
