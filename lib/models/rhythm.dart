enum Rhythm {
  quarter('quarter', true, []),
  eighths('eighth', true, [false, true]),
  eighthRestFollowedByEighth('eighth_rest_followed_by_eighth', false, [false, true]),
  triplets('triplets', true, [false, true, true]),
  sixteenths('sixteenths', true, [false, true, true, true]),
  sixteenthFollowedByDottedEighth('sixteenth_followed_by_dotted_eighth', true, [false, true, false, false]),
  dottedEighthFollowedBySixteenth('dotted_eighth_followed_by_sixteenth', true, [false, false, false, true]);

  final String assetName;
  final bool main;
  final List<bool> subs;

  const Rhythm(this.assetName, this.main, this.subs);
}
