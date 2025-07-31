import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tiomusic/domain/metronome/metronome.dart';
import 'package:tiomusic/domain/metronome/metronome_beat_event.dart';
import 'package:tiomusic/models/note_handler.dart';
import 'package:tiomusic/src/rust/api/modules/metronome.dart';

import '../../mocks/beat_handler_mock.dart';
import '../../utils/entities/test_beat_happened_event.dart';
import '../../utils/test_context.dart';

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
      onBeatStart: beatHandlerMock.onBeatStartEvent,
      onBeatStop: beatHandlerMock.onBeatStopEvent,
    );
  });

  Future<void> startMetronomeAndMockMetronomePollBeatEventHappened(
    WidgetTester tester,
    BeatHappenedEvent? event,
  ) async {
    await metronome.start();
    await tester.pump();
    context.audioSystemMock.mockMetronomePollBeatEventHappened(event);
    await tester.pump(Duration(milliseconds: beatSamplingIntervalInMs + 1));
  }

  Future<void> stopMetronome(WidgetTester tester) async {
    await metronome.stop();
    await tester.pump(Duration(milliseconds: beatDurationInMs));
  }

  group('Metronome', () {
    testWidgets('does not notify about beat event when metronome was stopped', (tester) async {
      await metronome.start();
      await tester.pump();
      context.audioSystemMock.mockMetronomePollBeatEventHappened(TestBeatHappenedEvent.make());
      metronome.stop();
      await tester.pump(Duration(milliseconds: beatSamplingIntervalInMs + 1));

      beatHandlerMock.verifyOnBeatNeverCalled();

      await stopMetronome(tester);
    });

    testWidgets('does not notify about beat event when event is null', (tester) async {
      const event = null;
      await startMetronomeAndMockMetronomePollBeatEventHappened(tester, event);

      beatHandlerMock.verifyOnBeatNeverCalled();

      await stopMetronome(tester);
    });

    testWidgets('does not notify about beat event when event is randomly muted', (tester) async {
      final event = TestBeatHappenedEvent.make(isRandomMute: true);
      await startMetronomeAndMockMetronomePollBeatEventHappened(tester, event);

      beatHandlerMock.verifyOnBeatNeverCalled();

      await stopMetronome(tester);
    });

    testWidgets('notifies about beat event', (tester) async {
      final event = TestBeatHappenedEvent.make();
      await startMetronomeAndMockMetronomePollBeatEventHappened(tester, event);

      beatHandlerMock.verifyOnBeatCalled(MetronomeBeatEvent());

      await stopMetronome(tester);
    });

    testWidgets('notifies about beat event and considers milliseconds before start', (tester) async {
      final event = TestBeatHappenedEvent.make(millisecondsBeforeStart: 5);
      await startMetronomeAndMockMetronomePollBeatEventHappened(tester, event);
      beatHandlerMock.verifyOnBeatNeverCalled();

      await tester.pump(Duration(milliseconds: 5));
      beatHandlerMock.verifyOnBeatCalled(MetronomeBeatEvent());

      await stopMetronome(tester);
    });

    testWidgets('notifies about beat start event', (tester) async {
      final event = TestBeatHappenedEvent.make();
      await startMetronomeAndMockMetronomePollBeatEventHappened(tester, event);

      beatHandlerMock.verifyOnBeatStartCalled(MetronomeBeatEvent());

      await stopMetronome(tester);
    });

    testWidgets('notifies about beat stop event once it is due', (tester) async {
      final event = TestBeatHappenedEvent.make();
      await startMetronomeAndMockMetronomePollBeatEventHappened(tester, event);

      beatHandlerMock.verifyOnBeatStopNeverCalled();

      await tester.pump(Duration(milliseconds: beatDurationInMs));
      beatHandlerMock.verifyOnBeatStopCalled(MetronomeBeatEvent());

      await stopMetronome(tester);
    });

    testWidgets('passes along if event is poly beat', (tester) async {
      final event = TestBeatHappenedEvent.make(isPoly: true);
      await startMetronomeAndMockMetronomePollBeatEventHappened(tester, event);

      beatHandlerMock.verifyOnBeatCalled(MetronomeBeatEvent(isPoly: true));

      await stopMetronome(tester);
    });

    testWidgets('passes along if event is from secondary metronome', (tester) async {
      final event = TestBeatHappenedEvent.make(isSecondary: true);
      await startMetronomeAndMockMetronomePollBeatEventHappened(tester, event);

      beatHandlerMock.verifyOnBeatCalled(MetronomeBeatEvent(isSecondary: true));

      await stopMetronome(tester);
    });
  });
}
