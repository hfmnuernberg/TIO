import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:tiomusic/services/audio_system.dart';
import 'package:tiomusic/src/rust/api/modules/media_player.dart';

class AudioSystemMock extends Mock implements AudioSystem {
  AudioSystemMock() {
    mockMediaPlayerGetState();
    mockMediaPlayerSetVolume();
    mockMediaPlayerSetPitchSemitones();
    mockMediaPlayerSetSpeedFactor();
    mockMediaPlayerLoadWav();
    mockMediaPlayerSetTrim();
    mockMediaPlayerGetRms(Float32List(1));
  }

  void mockMediaPlayerGetState() => when(mediaPlayerGetState).thenAnswer(
    (_) async => MediaPlayerState(
      playing: false,
      playbackPositionFactor: 0,
      totalLengthSeconds: 0,
      looping: false,
      trimStartFactor: 0,
      trimEndFactor: 0,
    ),
  );

  void mockMediaPlayerSetVolume([bool result = true]) =>
      when(() => mediaPlayerSetVolume(volume: any(named: 'volume'))).thenAnswer((_) async => result);

  void mockMediaPlayerSetPitchSemitones([bool result = true]) => when(
    () => mediaPlayerSetPitchSemitones(pitchSemitones: any(named: 'pitchSemitones')),
  ).thenAnswer((_) async => result);

  void mockMediaPlayerSetSpeedFactor([bool result = true]) =>
      when(() => mediaPlayerSetSpeedFactor(speedFactor: any(named: 'speedFactor'))).thenAnswer((_) async => result);

  void mockMediaPlayerLoadWav([bool result = true]) =>
      when(() => mediaPlayerLoadWav(wavFilePath: any(named: 'wavFilePath'))).thenAnswer((_) async => result);

  void mockMediaPlayerSetTrim([bool result = true]) {
    when(
      () => mediaPlayerSetTrim(startFactor: any(named: 'startFactor'), endFactor: any(named: 'endFactor')),
    ).thenAnswer((_) async => result);
  }

  void mockMediaPlayerGetRms(Float32List rmsValues) {
    when(() => mediaPlayerGetRms(nBins: any(named: 'nBins'))).thenAnswer((_) async => rmsValues);
  }
}
