import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:tiomusic/services/audio_system.dart';
import 'package:tiomusic/src/rust/api/modules/metronome_rhythm.dart';

import 'generator_mock.dart';
import 'media_player_mock.dart';
import 'metronome_mock.dart';
import 'piano_mock.dart';
import 'tuner_mock.dart';

class AudioSystemMock extends Mock
    with GeneratorMock, MediaPlayerMock, MetronomeMock, PianoMock, TunerMock
    implements AudioSystem {
  AudioSystemMock() {
    registerFallbackValue(BeatSound.Accented);

    mockInitAudio();
    mockGetSampleRate();
    mockDebugTestFunction();

    mockTunerGetFrequency();
    mockTunerStart();
    mockTunerStop();

    mockGeneratorStart();
    mockGeneratorStop();
    mockGeneratorNoteOn();
    mockGeneratorNoteOff();

    mockMediaPlayerLoadWav();
    mockMediaPlayerRenderMidiToWav();
    mockMediaPlayerStart();
    mockMediaPlayerStop();
    mockMediaPlayerStartRecording();
    mockMediaPlayerStopRecording();
    mockMediaPlayerGetRecordingSamples(Float64List(1));
    mockMediaPlayerSetPitchSemitones();
    mockMediaPlayerSetSpeedFactor();
    mockMediaPlayerSetTrim();
    mockMediaPlayerGetRms(Float32List(1));
    mockComputeRmsFromFile(Float32List(1));
    mockMediaPlayerSetRepeat();
    mockMediaPlayerGetState();
    mockMediaPlayerSetPlaybackPosFactor();
    mockMediaPlayerSetVolume();
    mockMediaPlayerLoadSecondaryProcessed();
    mockMediaPlayerUnloadSecondaryAudio();

    mockMetronomeStart();
    mockMetronomeStop();
    mockMetronomeSetBpm();
    mockMetronomeLoadFile();
    mockMetronomeSetRhythm();
    mockMetronomePollBeatEventHappened();
    mockMetronomeSetMuted();
    mockMetronomeSetBeatMuteChance();
    mockMetronomeSetVolume();

    mockPianoSetup();
    mockPianoStart();
    mockPianoStop();
    mockPianoNoteOn();
    mockPianoNoteOff();
    mockPianoSetConcertPitch();
    mockPianoSetVolume();
  }

  void mockInitAudio() => when(initAudio).thenAnswer((_) async {});

  void mockGetSampleRate([int result = 44100]) => when(getSampleRate).thenAnswer((_) async => result);
  void verifyGetSampleRateCalled() => verify(getSampleRate).called(1);

  void mockDebugTestFunction([bool result = true]) => when(debugTestFunction).thenAnswer((_) async => result);
}
