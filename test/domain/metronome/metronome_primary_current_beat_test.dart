import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tiomusic/domain/metronome/metronome.dart';
import 'package:tiomusic/models/note_handler.dart';
import 'package:tiomusic/src/rust/api/modules/metronome.dart';

import '../../utils/entities/test_beat_happened_event.dart';
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

  Future<void> startMetronomeAndMockMetronomePollBeatEventHappened(WidgetTester tester, BeatHappenedEvent event) async {
    await metronome.start();
    await tester.pump();
    context.audioSystemMock.mockMetronomePollBeatEventHappened(event);
    await tester.pump(Duration(milliseconds: beatSamplingIntervalInMs + 1));
  }

  Future<void> startMetronomeAndMockMetronomePollBeatEventHappenedOnce(
    WidgetTester tester,
    BeatHappenedEvent event,
  ) async {
    await metronome.start();
    await tester.pump();
    context.audioSystemMock.mockMetronomePollBeatEventHappenedOnce(event);
    await tester.pump(Duration(milliseconds: beatSamplingIntervalInMs + 1));
  }

  Future<void> stopMetronome(WidgetTester tester) async {
    await metronome.stop();
    await tester.pump(Duration(milliseconds: beatDurationInMs));
  }

  group('Metronome', () {
    group('Primary', () {
      group('Current Segment Index', () {
        testWidgets('sets current segment index based on bar index in beat event', (tester) async {
          final event = TestBeatHappenedEvent.make(barIndex: 1);
          await startMetronomeAndMockMetronomePollBeatEventHappened(tester, event);

          expect(metronome.currentBeat.segmentIndex, 1);

          await stopMetronome(tester);
        });

        testWidgets('maintains current segment index when beat is stopped', (tester) async {
          final event = TestBeatHappenedEvent.make(barIndex: 1);
          await startMetronomeAndMockMetronomePollBeatEventHappened(tester, event);
          await tester.pump(Duration(milliseconds: beatDurationInMs));

          expect(metronome.currentBeat.segmentIndex, 1);

          await stopMetronome(tester);
        });

        testWidgets('resets current segment index when metronome was stopped', (tester) async {
          final event = TestBeatHappenedEvent.make(barIndex: 1);
          await startMetronomeAndMockMetronomePollBeatEventHappened(tester, event);

          await metronome.stop();

          expect(metronome.currentBeat.segmentIndex, isNull);

          await tester.pump(Duration(milliseconds: beatDurationInMs));
        });
      });

      group('Current Main Beat Index', () {
        testWidgets('sets current main beat index based on beat index in beat event', (tester) async {
          final event = TestBeatHappenedEvent.make(beatIndex: 2);
          await startMetronomeAndMockMetronomePollBeatEventHappened(tester, event);

          expect(metronome.currentBeat.mainBeatIndex, 2);

          await stopMetronome(tester);
        });

        testWidgets('resets current main beat index when beat is stopped', (tester) async {
          final event = TestBeatHappenedEvent.make(beatIndex: 2);
          await startMetronomeAndMockMetronomePollBeatEventHappenedOnce(tester, event);
          await tester.pump(Duration(milliseconds: beatDurationInMs));

          expect(metronome.currentBeat.mainBeatIndex, isNull);

          await stopMetronome(tester);
        });

        testWidgets('resets current main beat index when metronome was stopped', (tester) async {
          final event = TestBeatHappenedEvent.make(beatIndex: 2);
          await startMetronomeAndMockMetronomePollBeatEventHappened(tester, event);

          await metronome.stop();

          expect(metronome.currentBeat.mainBeatIndex, isNull);

          await tester.pump(Duration(milliseconds: beatDurationInMs));
        });
      });
    });

    group('Current Poly Beat Index', () {
      testWidgets('sets current poly beat index based on beat index in beat event', (tester) async {
        final event = TestBeatHappenedEvent.make(beatIndex: 3, isPoly: true);
        await startMetronomeAndMockMetronomePollBeatEventHappened(tester, event);

        expect(metronome.currentBeat.polyBeatIndex, 3);

        await stopMetronome(tester);
      });

      testWidgets('resets current poly beat index when beat is stopped', (tester) async {
        final event = TestBeatHappenedEvent.make(beatIndex: 3, isPoly: true);
        await startMetronomeAndMockMetronomePollBeatEventHappenedOnce(tester, event);
        await tester.pump(Duration(milliseconds: beatDurationInMs));

        expect(metronome.currentBeat.polyBeatIndex, isNull);

        await stopMetronome(tester);
      });

      testWidgets('resets current poly beat index when metronome was stopped', (tester) async {
        final event = TestBeatHappenedEvent.make(beatIndex: 3, isPoly: true);
        await startMetronomeAndMockMetronomePollBeatEventHappened(tester, event);

        await metronome.stop();

        expect(metronome.currentBeat.polyBeatIndex, isNull);

        await tester.pump(Duration(milliseconds: beatDurationInMs));
      });
    });
  });
}
