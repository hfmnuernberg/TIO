import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tiomusic/models/note_handler.dart';
import 'package:tiomusic/models/rhythm_group.dart';
import 'package:tiomusic/src/rust/api/modules/metronome_rhythm.dart';
import 'package:tiomusic/widgets/metronome/simple_rhythm_group_editor.dart';

import '../../utils/action_utils.dart';
import '../../utils/render_utils.dart';

class OnRhythmUpdateMock extends Mock {
  void onUpdate(RhythmGroup rhythmGroup);

  void verifyCalledWith({required RhythmGroup rhythmGroup}) => verify(() => onUpdate(rhythmGroup)).called(1);
}

RhythmGroup rhythmGroup(beats, polyBeats) => RhythmGroup('', beats, polyBeats, NoteValues.quarter);

void main() {
  setUpAll(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await NoteHandler.createNoteBeatLengthMap();
  });

  group('SimpleRhythmGroupEditor', () {
    testWidgets('updates rhythm group when increasing beats', (tester) async {
      final onRhythmUpdateMock = OnRhythmUpdateMock();

      await tester.renderWidget(
        SimpleRhythmGroupEditor(
          rhythmGroup: rhythmGroup(const [BeatType.Accented], const [BeatTypePoly.Muted, BeatTypePoly.Unaccented]),
          onUpdate: onRhythmUpdateMock.onUpdate,
        ),
      );

      await tester.tapAndSettle(find.bySemanticsLabel('Plus button'));

      onRhythmUpdateMock.verifyCalledWith(
        rhythmGroup: rhythmGroup(
          const [BeatType.Accented, BeatType.Unaccented],
          const [BeatTypePoly.Muted, BeatTypePoly.Unaccented, BeatTypePoly.Muted, BeatTypePoly.Unaccented],
        ),
      );
    });

    testWidgets('updates rhythm group when decreasing beats', (tester) async {
      final onRhythmUpdateMock = OnRhythmUpdateMock();

      await tester.renderWidget(
        SimpleRhythmGroupEditor(
          rhythmGroup: rhythmGroup(
            const [BeatType.Accented, BeatType.Unaccented],
            const [BeatTypePoly.Muted, BeatTypePoly.Unaccented, BeatTypePoly.Muted, BeatTypePoly.Unaccented],
          ),
          onUpdate: onRhythmUpdateMock.onUpdate,
        ),
      );

      await tester.tapAndSettle(find.bySemanticsLabel('Minus button'));

      onRhythmUpdateMock.verifyCalledWith(
        rhythmGroup: rhythmGroup(const [BeatType.Accented], const [BeatTypePoly.Muted, BeatTypePoly.Unaccented]),
      );
    });

    testWidgets('updates rhythm group when changing rhythm', (tester) async {
      final onRhythmUpdateMock = OnRhythmUpdateMock();

      await tester.renderWidget(
        SimpleRhythmGroupEditor(
          rhythmGroup: rhythmGroup(const [BeatType.Accented, BeatType.Unaccented], const <BeatTypePoly>[]),
          onUpdate: onRhythmUpdateMock.onUpdate,
        ),
      );

      await tester.dragFromCenterToTargetAndSettle(find.bySemanticsLabel('Quarter'), const Offset(-70, 0));

      onRhythmUpdateMock.verifyCalledWith(
        rhythmGroup: rhythmGroup(
          const [BeatType.Accented, BeatType.Unaccented],
          const [BeatTypePoly.Muted, BeatTypePoly.Unaccented, BeatTypePoly.Muted, BeatTypePoly.Unaccented],
        ),
      );
    });
  });
}
