String formatMediaDuration(Duration duration) {
  final ms = _clampToZero(duration.inMilliseconds);
  if (ms >= Duration.millisecondsPerHour) return _formatWithHours(ms);
  if (ms >= Duration.millisecondsPerMinute) return _formatWithMinutes(ms);
  return _formatSeconds(ms);
}

int _clampToZero(int value) => value < 0 ? 0 : value;

String _formatWithHours(int ms) {
  final hours = ms ~/ Duration.millisecondsPerHour;
  final minutes = (ms % Duration.millisecondsPerHour) ~/ Duration.millisecondsPerMinute;
  final seconds = (ms % Duration.millisecondsPerMinute) ~/ Duration.millisecondsPerSecond;
  return '$hours:${_pad2(minutes)}:${_pad2(seconds)}.${_pad3(ms % 1000)}';
}

String _formatWithMinutes(int ms) {
  final minutes = ms ~/ Duration.millisecondsPerMinute;
  final seconds = (ms % Duration.millisecondsPerMinute) ~/ Duration.millisecondsPerSecond;
  return '$minutes:${_pad2(seconds)}.${_pad3(ms % 1000)}';
}

String _formatSeconds(int ms) => '${ms ~/ Duration.millisecondsPerSecond}.${_pad3(ms % 1000)}';

String _pad2(int value) => value.toString().padLeft(2, '0');

String _pad3(int value) => value.toString().padLeft(3, '0');
