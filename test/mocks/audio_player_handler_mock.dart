import 'package:mocktail/mocktail.dart';

class AudioPlayerHandlerMock extends Mock {
  void onIsPlayingChange(bool playing);
  void onPlaybackPositionChange(double position);

  void verifyOnPlayingChangeCalled(bool playing) => verify(() => onIsPlayingChange(playing)).called(1);
  void verifyOnPlayingChangeNeverCalled() => verifyNever(() => onIsPlayingChange(any()));

  void verifyOnPlaybackPositionChangeCalled(double position) =>
      verify(() => onPlaybackPositionChange(position)).called(1);
  void verifyOnPlaybackPositionChangeNeverCalled() => verifyNever(() => onPlaybackPositionChange(any()));
}
