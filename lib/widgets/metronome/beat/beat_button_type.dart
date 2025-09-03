import 'package:tiomusic/src/rust/api/modules/metronome_rhythm.dart';

enum BeatButtonType {
  accented(BeatType.Accented, BeatTypePoly.Accented),
  unaccented(BeatType.Unaccented, BeatTypePoly.Unaccented),
  muted(BeatType.Muted, BeatTypePoly.Muted);

  final BeatType mainBeatType;
  final BeatTypePoly polyBeatType;

  const BeatButtonType(this.mainBeatType, this.polyBeatType);

  factory BeatButtonType.fromMainBeatType(BeatType mainBeatType) =>
      BeatButtonType.values.firstWhere((type) => type.mainBeatType == mainBeatType);
  factory BeatButtonType.fromPolyBeatType(BeatTypePoly polyBeatType) =>
      BeatButtonType.values.firstWhere((type) => type.polyBeatType == polyBeatType);

  static List<BeatButtonType> fromMainBeatTypes(List<BeatType> mainBeatTypes) =>
      mainBeatTypes.map(BeatButtonType.fromMainBeatType).toList();
  static List<BeatButtonType> fromPolyBeatTypes(List<BeatTypePoly> polyBeatTypes) =>
      polyBeatTypes.map(BeatButtonType.fromPolyBeatType).toList();
}
