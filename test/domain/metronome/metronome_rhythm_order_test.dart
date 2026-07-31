import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiomusic/l10n/en.dart';
import 'package:tiomusic/models/blocks/metronome_block.dart';
import 'package:tiomusic/models/note_handler.dart';
import 'package:tiomusic/models/rhythm_group.dart';

import '../../utils/entities/test_rhythm_group.dart';

void main() {
  late MetronomeBlock block;
  late List<RhythmGroup> groups;

  setUpAll(WidgetsFlutterBinding.ensureInitialized);

  setUp(() async {
    await NoteHandler.createNoteBeatLengthMap();
    block = MetronomeBlock.withDefaults(English());
    groups = [TestRhythmGroup.make(keyID: 'a'), TestRhythmGroup.make(keyID: 'b'), TestRhythmGroup.make(keyID: 'c')];
  });

  List<String> keyIdsOf(List<RhythmGroup> rhythmGroups) => rhythmGroups.map((group) => group.keyID).toList();

  group('MetronomeBlock - rhythm group order', () {
    test('keeps order when group is moved onto itself', () {
      block.changeRhythmOrder(1, 1, groups);

      expect(keyIdsOf(groups), equals(['a', 'b', 'c']));
    });

    test('moves group down when moved to a later position', () {
      block.changeRhythmOrder(0, 1, groups);

      expect(keyIdsOf(groups), equals(['b', 'a', 'c']));
    });

    test('moves group up when moved to an earlier position', () {
      block.changeRhythmOrder(2, 0, groups);

      expect(keyIdsOf(groups), equals(['c', 'a', 'b']));
    });

    test('moves first group to the end', () {
      block.changeRhythmOrder(0, 2, groups);

      expect(keyIdsOf(groups), equals(['b', 'c', 'a']));
    });
  });
}
