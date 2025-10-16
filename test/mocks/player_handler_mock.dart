import 'package:mocktail/mocktail.dart';

class PlayerHandlerMock extends Mock {
  void onIsPlayingChange(bool playing);
  void onPlaybackPositionChange(double position);

  void verifyOnPlayingChangeCalledWith(bool playing) => verify(() => onIsPlayingChange(playing)).called(1);
  void verifyOnPlayingChangeNeverCalled() => verifyNever(() => onIsPlayingChange(any()));

  void verifyOnPlaybackPositionChangeCalledWith(double position) =>
      verify(() => onPlaybackPositionChange(position)).called(1);
  void verifyOnPlaybackPositionChangeNeverCalled() => verifyNever(() => onPlaybackPositionChange(any()));
}
