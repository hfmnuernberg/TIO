import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tiomusic/services/audio_system.dart';

mixin MediaPlayerCacheMock on Mock implements AudioSystem {
  void verifyMediaPlayerLoadWavCalledWithCacheDir(String cacheDir) => verify(
    () => mediaPlayerLoadWav(
      id: any(named: 'id'),
      wavFilePath: any(named: 'wavFilePath'),
      cacheDir: cacheDir,
    ),
  ).called(1);

  void mockMediaPlayerInvalidateWavCache() => when(
    () => mediaPlayerInvalidateWavCache(
      wavFilePath: any(named: 'wavFilePath'),
      cacheDir: any(named: 'cacheDir'),
    ),
  ).thenAnswer((_) async {});

  void verifyMediaPlayerInvalidateWavCacheCalledWith(Pattern wavFilePath) => verify(
    () => mediaPlayerInvalidateWavCache(
      wavFilePath: any(named: 'wavFilePath', that: matches(wavFilePath)),
      cacheDir: any(named: 'cacheDir'),
    ),
  ).called(1);

  void verifyMediaPlayerInvalidateWavCacheNeverCalled() => verifyNever(
    () => mediaPlayerInvalidateWavCache(
      wavFilePath: any(named: 'wavFilePath'),
      cacheDir: any(named: 'cacheDir'),
    ),
  );
}
