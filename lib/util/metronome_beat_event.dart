class MetronomeBeatEvent {
  final bool isPoly;
  final bool isSecondary;

  MetronomeBeatEvent({this.isPoly = false, this.isSecondary = false});

  @override
  String toString() => 'Beat(isPoly: $isPoly, isSecondary: $isSecondary)';
}
