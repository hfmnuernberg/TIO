import 'package:mocktail/mocktail.dart';

class PlayerHandlerMock extends Mock {
  void onIsPlayingChange(bool isPlaying);
  void onPlaybackPositionChange(double position);
  void onSeek(double position);

  void verifyOnIsPlayingChangeCalledWith(bool isPlaying) => verify(() => onIsPlayingChange(isPlaying)).called(1);
  void verifyOnIsPlayingChangeNeverCalled() => verifyNever(() => onIsPlayingChange(any()));

  void verifyOnPlaybackPositionChangeCalledWith(double position) =>
      verify(() => onPlaybackPositionChange(position)).called(1);
  void verifyOnPlaybackPositionChangeNeverCalled() => verifyNever(() => onPlaybackPositionChange(any()));

  void verifyOnSeekCalledWith(double position) => verify(() => onSeek(position)).called(1);
  void verifyOnSeekNeverCalled() => verifyNever(() => onSeek(any()));
}
