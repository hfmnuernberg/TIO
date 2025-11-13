import 'package:tiomusic/src/rust/api/modules/media_player.dart';

import 'test_context.dart';

void mockPlayerState(
  TestContext context, {
  bool playing = true,
  double playbackPositionFactor = 0,
  double totalLengthSeconds = 10,
  bool looping = false,
  double trimStartFactor = 0,
  double trimEndFactor = 1,
}) {
  context.audioSystemMock.mockMediaPlayerGetState(
    MediaPlayerState(
      playing: playing,
      playbackPositionFactor: playbackPositionFactor,
      totalLengthSeconds: totalLengthSeconds,
      looping: looping,
      trimStartFactor: trimStartFactor,
      trimEndFactor: trimEndFactor,
    ),
  );
}
