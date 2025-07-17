import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tiomusic/domain/metronome/metronome.dart';
import 'package:tiomusic/domain/metronome/metronome_beat_event.dart';
import 'package:tiomusic/models/note_handler.dart';
import 'package:tiomusic/models/rhythm_group.dart';
import 'package:tiomusic/src/rust/api/modules/metronome.dart';
import 'package:tiomusic/src/rust/api/modules/metronome_rhythm.dart';

import '../../utils/test_context.dart';

class BeatHandlerMock extends Mock {
  void onBeatEvent(MetronomeBeatEvent beat);

  void verifyOnBeatCalled(MetronomeBeatEvent beat) => verify(() => onBeatEvent(beat)).called(1);
}

void main() {
  late TestContext context;
  late BeatHandlerMock beatHandlerMock;
  late Metronome metronome;

  setUp(() async {
    resetMocktailState();
    await NoteHandler.createNoteBeatLengthMap();
    context = TestContext();
    beatHandlerMock = BeatHandlerMock();
    metronome = Metronome(
      context.audioSystem,
      context.audioSession,
      context.inMemoryFileSystem,
      context.wakelock,
      onBeatEvent: beatHandlerMock.onBeatEvent,
    );
  });

  group('Metronome', () {
    testWidgets('starts and stops', (tester) async {
      expect(metronome.isOn, isFalse);

      await metronome.start();
      expect(metronome.isOn, isTrue);

      await metronome.stop();
      expect(metronome.isOn, isFalse);
    });

    testWidgets('starts metronome in audio system when started', (tester) async {
      await metronome.start();

      context.audioSystemMock.verifyMetronomeStartCalled();

      await metronome.stop();
    });

    testWidgets('starts only once', (tester) async {
      await metronome.start();
      await metronome.start();
      context.audioSystemMock.verifyMetronomeStartCalled();

      await metronome.stop();
    });

    testWidgets('prepares playback in audio session when started', (tester) async {
      await metronome.start();

      context.audioSessionMock.verifyPreparePlaybackCalled();

      await metronome.stop();
    });

    testWidgets('forces screen to stay on when started', (tester) async {
      await metronome.start();

      context.wakelockMock.verifyEnableCalled();

      await metronome.stop();
    });

    testWidgets('stops metronome in audio system when stopped', (tester) async {
      await metronome.start();

      await metronome.stop();

      context.audioSystemMock.verifyMetronomeStopCalled();
    });

    testWidgets('stops only once', (tester) async {
      await metronome.start();

      await metronome.stop();
      await metronome.stop();

      context.audioSystemMock.verifyMetronomeStartCalled();
    });

    testWidgets('allows screen to turn off when stopped', (tester) async {
      await metronome.start();

      await metronome.stop();

      context.wakelockMock.verifyDisableCalled();
    });

    testWidgets('restarts', (tester) async {
      await metronome.start();
      context.audioSystemMock.verifyMetronomeStartCalled();

      await metronome.restart();

      expect(metronome.isOn, isTrue);
      context.audioSystemMock.verifyMetronomeStopCalled();
      context.audioSystemMock.verifyMetronomeStartCalled();

      await metronome.stop();
    });

    testWidgets('can be muted and unmuted', (tester) async {
      expect(metronome.isMute, isFalse);

      await metronome.mute();
      expect(metronome.isMute, isTrue);

      await metronome.unmute();
      expect(metronome.isMute, isFalse);
    });

    testWidgets('sets volume in audio system', (tester) async {
      await metronome.setVolume(1.2);

      context.audioSystemMock.verifyMetronomeSetVolumeCalledWith(1.2);
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
      await metronome.setRhythm([]);

      context.audioSystemMock.verifyMetronomeSetRhythmCalledWith([]);
    });

    testWidgets('sets one rhythm in audio system', (tester) async {
      await metronome.setRhythm([]);

      context.audioSystemMock.verifyMetronomeSetRhythmCalledWith([]);
    });

    testWidgets('sets no secondary rhythms in audio system', (tester) async {
      await metronome.setRhythm([RhythmGroup('id', const [], const [], 'e4')], []);

      context.audioSystemMock.verifyMetronomeSetRhythmCalledWith([
        MetroBar(id: 0, beats: [], polyBeats: [], beatLen: 0),
      ], []);
    }, skip: true);

    testWidgets('notifies about beat event', (tester) async {
      await metronome.start();
      await tester.pump();
      context.audioSystemMock.mockMetronomePollBeatEventHappened(
        BeatHappenedEvent(
          millisecondsBeforeStart: 0,
          barIndex: 0,
          beatIndex: 0,
          isPoly: false,
          isRandomMute: false,
          isSecondary: false,
        ),
      );

      await tester.pump(Duration(milliseconds: 11));

      beatHandlerMock.verifyOnBeatCalled(MetronomeBeatEvent());

      await metronome.stop();
      await tester.pump(Duration(milliseconds: 100));
    });

    // TODO: onBeatEvent
    // TODO: onBeatStart
    // TODO: onBeatStop
    // TODO: current beat
    // TODO: current secondary beat
    // TODO: set rhythm
    // TODO: load sounds
    // TODO: edge cases
    // TODO: error cases
  });
}
