import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tiomusic/domain/metronome/metronome.dart';
import 'package:tiomusic/models/note_handler.dart';
import 'package:tiomusic/src/rust/api/modules/metronome_rhythm.dart';

import '../../utils/entities/test_metro_bar.dart';
import '../../utils/entities/test_rhythm_group.dart';
import '../../utils/test_context.dart';

void main() {
  late TestContext context;
  late Metronome metronome;

  setUp(() async {
    resetMocktailState();
    await NoteHandler.createNoteBeatLengthMap();
    context = TestContext();
    metronome = Metronome(context.audioSystem, context.audioSession, context.inMemoryFileSystem, context.wakelock);
  });

  group('Metronome - Settings', () {
    testWidgets('can be muted and unmuted', (tester) async {
      expect(metronome.isMute, isFalse);

      await metronome.mute();
      expect(metronome.isMute, isTrue);

      await metronome.unmute();
      expect(metronome.isMute, isFalse);
    });

    testWidgets('sets volume in audio system', (tester) async {
      await metronome.setVolume(0.5);

      context.audioSystemMock.verifyMetronomeSetVolumeCalledWith(0.25);
    });

    testWidgets('sets BPM in audio system', (tester) async {
      await metronome.setBpm(80);

      context.audioSystemMock.verifyMetronomeSetBpmCalledWith(80);
    });

    testWidgets('sets BPM in audio system', (tester) async {
      await metronome.setChanceOfMuteBeat(50);

      context.audioSystemMock.verifyMetronomeSetBeatMuteChanceCalledWith(0.5);
    });

    testWidgets('sets no rhythms in audio system', (tester) async {
      await metronome.setRhythm([], []);

      context.audioSystemMock.verifyMetronomeSetRhythmCalledWith([], []);
    });

    testWidgets('sets one primary rhythm in audio system', (tester) async {
      await metronome.setRhythm([
        TestRhythmGroup.make(beats: [BeatType.Accented]),
      ], []);

      context.audioSystemMock.verifyMetronomeSetRhythmCalledWith([
        TestMetroBar.make(beats: [BeatType.Accented]),
      ], []);
    });

    testWidgets('sets one secondary rhythm in audio system', (tester) async {
      await metronome.setRhythm([], [
        TestRhythmGroup.make(beats: [BeatType.Accented]),
      ]);

      context.audioSystemMock.verifyMetronomeSetRhythmCalledWith([], [
        TestMetroBar.make(beats: [BeatType.Accented]),
      ]);
    });

    testWidgets('sets many rhythms in audio system', (tester) async {
      await metronome.setRhythm([
        TestRhythmGroup.make(beats: [BeatType.Accented], polyBeats: [BeatTypePoly.Unaccented]),
        TestRhythmGroup.make(beats: [BeatType.Muted], polyBeats: []),
      ], []);

      context.audioSystemMock.verifyMetronomeSetRhythmCalledWith([
        TestMetroBar.make(beats: [BeatType.Accented], polyBeats: [BeatTypePoly.Unaccented]),
        TestMetroBar.make(beats: [BeatType.Muted], polyBeats: []),
      ], []);
    });
  });
}
