import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tiomusic/models/note_handler.dart';
import 'package:tiomusic/models/rhythm_group.dart';
import 'package:tiomusic/src/rust/api/modules/metronome_rhythm.dart';
import 'package:tiomusic/widgets/metronome/set_rhythm_parameters_simple.dart';

import '../../utils/action_utils.dart';
import '../../utils/render_utils.dart';

class OnRhythmUpdateMock extends Mock {
  void onUpdate(RhythmGroup rhythmGroup);

  void verifyCalledWith({required RhythmGroup rhythmGroup}) => verify(() => onUpdate(rhythmGroup)).called(1);

  void verifyCalledTwiceWith({required RhythmGroup rhythmGroup}) => verify(() => onUpdate(rhythmGroup)).called(2);
}

void main() {
  setUpAll(WidgetsFlutterBinding.ensureInitialized);

  group('RhythmPresetWheel', () {
    testWidgets('updates rhythm when increasing beats', (tester) async {
      final onRhythmUpdateMock = OnRhythmUpdateMock();

      await tester.renderWidget(
        SetRhythmParametersSimple(
          rhythmGroup: RhythmGroup(
            '',
            const [BeatType.Accented, BeatType.Unaccented, BeatType.Unaccented, BeatType.Unaccented],
            const [],
            NoteValues.quarter,
          ),
          onUpdate: onRhythmUpdateMock.onUpdate,
        ),
      );

      await tester.tapAndSettle(find.bySemanticsLabel('Plus button'));

      onRhythmUpdateMock.verifyCalledWith(
        rhythmGroup: RhythmGroup(
          '',
          const [BeatType.Accented, BeatType.Unaccented, BeatType.Unaccented, BeatType.Unaccented, BeatType.Unaccented],
          const [],
          NoteValues.quarter,
        ),
      );
    });

    testWidgets('updates rhythm when changing preset', (tester) async {
      final onRhythmUpdateMock = OnRhythmUpdateMock();

      await tester.renderWidget(
        SetRhythmParametersSimple(
          rhythmGroup: RhythmGroup(
            '',
            const [BeatType.Accented, BeatType.Unaccented, BeatType.Unaccented, BeatType.Unaccented],
            const [],
            NoteValues.quarter,
          ),
          onUpdate: onRhythmUpdateMock.onUpdate,
        ),
      );

      await tester.tapAndSettle(find.bySemanticsLabel('Two-eighth note'));

      onRhythmUpdateMock.verifyCalledTwiceWith(
        rhythmGroup: RhythmGroup(
          '',
          const [BeatType.Accented, BeatType.Unaccented, BeatType.Unaccented, BeatType.Unaccented],
          const [
            BeatTypePoly.Muted,
            BeatTypePoly.Unaccented,
            BeatTypePoly.Muted,
            BeatTypePoly.Unaccented,
            BeatTypePoly.Muted,
            BeatTypePoly.Unaccented,
            BeatTypePoly.Muted,
            BeatTypePoly.Unaccented,
          ],
          NoteValues.quarter,
        ),
      );
    });

    // TODO: Implement changes to make this test green
    testWidgets('updates rhythm when changing preset and decreasing beats', (tester) async {
      final onRhythmUpdateMock = OnRhythmUpdateMock();

      await tester.renderWidget(
        SetRhythmParametersSimple(
          rhythmGroup: RhythmGroup(
            '',
            const [BeatType.Accented, BeatType.Unaccented, BeatType.Unaccented, BeatType.Unaccented],
            const [],
            NoteValues.quarter,
          ),
          onUpdate: onRhythmUpdateMock.onUpdate,
        ),
      );

      await tester.tapAndSettle(find.bySemanticsLabel('Two-eighth note'));
      await tester.tapAndSettle(find.bySemanticsLabel('Minus button'));

      onRhythmUpdateMock.verifyCalledWith(
        rhythmGroup: RhythmGroup(
          '',
          const [BeatType.Accented, BeatType.Unaccented, BeatType.Unaccented],
          const [
            BeatTypePoly.Muted,
            BeatTypePoly.Unaccented,
            BeatTypePoly.Muted,
            BeatTypePoly.Unaccented,
            BeatTypePoly.Muted,
            BeatTypePoly.Unaccented,
          ],
          NoteValues.quarter,
        ),
      );
    });
  });
}
