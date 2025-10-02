import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tiomusic/domain/piano/piano.dart';
import 'package:tiomusic/models/sound_font.dart';

import '../../utils/test_context.dart';

void main() {
  late TestContext context;
  late Piano piano;

  setUp(() async {
    resetMocktailState();
    context = TestContext();
    piano = Piano(context.audioSystem, context.audioSession, context.inMemoryFileSystem);
  });

  group('Piano - Settings', () {
    testWidgets('sets volume in audio system', (tester) async {
      await piano.setVolume(1.2);
      context.audioSystemMock.verifyPianoSetVolumeCalledWith(1.2);
    });

    testWidgets('sets concert pitch in audio system and updates getter', (tester) async {
      await piano.setConcertPitch(442);

      context.audioSystemMock.verifyPianoSetConcertPitchCalledWith(442);
      expect(piano.concertPitch, 442);
    });

    testWidgets('plays notes via audio system', (tester) async {
      piano.playNote(42);
      context.audioSystemMock.verifyPianoNoteOnCalledWith(42);
    });

    testWidgets('releases notes via audio system', (tester) async {
      piano.releaseNote(42);
      context.audioSystemMock.verifyPianoNoteOffCalledWith(42);
    });

    testWidgets('changing sound font updates the selected sound font', (tester) async {
      expect(piano.soundFont, SoundFont.piano1);

      await piano.setSoundFont(SoundFont.piano2);
      expect(piano.soundFont, SoundFont.piano2);
    });

    testWidgets('changing sound font on started piano restarts the piano', (tester) async {
      await piano.start();
      expect(piano.isPlaying, isTrue);
      context.audioSystemMock.verifyPianoStartCalled();

      await piano.setSoundFont(SoundFont.piano2);

      context.audioSystemMock.verifyPianoStopCalled();
      context.audioSystemMock.verifyPianoStartCalled();

      await piano.stop();
    });

    testWidgets('changing sound font on stopped piano does not restart the piano', (tester) async {
      await piano.setSoundFont(SoundFont.piano2);

      context.audioSystemMock.verifyPianoStopNeverCalled();
      context.audioSystemMock.verifyPianoStartNeverCalled();
    });
  });
}
