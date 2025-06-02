import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tiomusic/models/note_handler.dart';
import 'package:tiomusic/src/rust/api/modules/metronome_rhythm.dart';
import 'package:tiomusic/widgets/metronome/set_rhythm_parameters_simple.dart';

import '../../utils/action_utils.dart';
import '../../utils/render_utils.dart';

class OnRhythmUpdateMock extends Mock {
  void onRhythmUpdate(List<BeatType> beats, List<BeatTypePoly> polyBeats, String noteKey);

  void verifyCalledWith({
    required List<BeatType> beats,
    required List<BeatTypePoly> polyBeats,
    required String noteKey,
  }) => verify(() => onRhythmUpdate(beats, polyBeats, noteKey)).called(1);

  void verifyCalledTwiceWith({
    required List<BeatType> beats,
    required List<BeatTypePoly> polyBeats,
    required String noteKey,
  }) => verify(() => onRhythmUpdate(beats, polyBeats, noteKey)).called(2);
}

void main() {
  setUpAll(WidgetsFlutterBinding.ensureInitialized);

  group('RhythmPresetWheel', () {
    testWidgets('updates rhythm when increasing beats', (tester) async {
      final onRhythmUpdateMock = OnRhythmUpdateMock();

      await tester.renderWidget(
        SetRhythmParametersSimple(
          beats: const [BeatType.Accented, BeatType.Unaccented, BeatType.Unaccented, BeatType.Unaccented],
          polyBeats: const [],
          noteKey: NoteValues.quarter,
          onUpdateRhythm: onRhythmUpdateMock.onRhythmUpdate,
        ),
      );

      await tester.tapAndSettle(find.bySemanticsLabel('Plus button'));

      onRhythmUpdateMock.verifyCalledWith(
        beats: const [
          BeatType.Accented,
          BeatType.Unaccented,
          BeatType.Unaccented,
          BeatType.Unaccented,
          BeatType.Unaccented,
        ],
        polyBeats: const [],
        noteKey: NoteValues.quarter,
      );
    });

    testWidgets('updates rhythm when changing preset', (tester) async {
      final onRhythmUpdateMock = OnRhythmUpdateMock();

      await tester.renderWidget(
        SetRhythmParametersSimple(
          beats: const [BeatType.Accented, BeatType.Unaccented, BeatType.Unaccented, BeatType.Unaccented],
          polyBeats: const [],
          noteKey: NoteValues.quarter,
          onUpdateRhythm: onRhythmUpdateMock.onRhythmUpdate,
        ),
      );

      await tester.tapAndSettle(find.bySemanticsLabel('Two-eighth note'));

      onRhythmUpdateMock.verifyCalledTwiceWith(
        beats: const [BeatType.Accented, BeatType.Unaccented, BeatType.Unaccented, BeatType.Unaccented],
        polyBeats: const [
          BeatTypePoly.Muted,
          BeatTypePoly.Unaccented,
          BeatTypePoly.Muted,
          BeatTypePoly.Unaccented,
          BeatTypePoly.Muted,
          BeatTypePoly.Unaccented,
          BeatTypePoly.Muted,
          BeatTypePoly.Unaccented,
        ],
        noteKey: NoteValues.quarter,
      );
    });

    // TODO: Implement changes to make this test green
    testWidgets('updates rhythm when changing preset and decreasing beats', (tester) async {
      final onRhythmUpdateMock = OnRhythmUpdateMock();

      await tester.renderWidget(
        SetRhythmParametersSimple(
          beats: const [BeatType.Accented, BeatType.Unaccented, BeatType.Unaccented, BeatType.Unaccented],
          polyBeats: const [],
          noteKey: NoteValues.quarter,
          onUpdateRhythm: onRhythmUpdateMock.onRhythmUpdate,
        ),
      );

      await tester.tapAndSettle(find.bySemanticsLabel('Two-eighth note'));
      await tester.tapAndSettle(find.bySemanticsLabel('Minus button'));

      onRhythmUpdateMock.verifyCalledWith(
        beats: const [BeatType.Accented, BeatType.Unaccented, BeatType.Unaccented],
        polyBeats: const [
          BeatTypePoly.Muted,
          BeatTypePoly.Unaccented,
          BeatTypePoly.Muted,
          BeatTypePoly.Unaccented,
          BeatTypePoly.Muted,
          BeatTypePoly.Unaccented,
        ],
        noteKey: NoteValues.quarter,
      );
    });
  });
}
