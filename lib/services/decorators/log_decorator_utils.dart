String shortenPath(String path, {int segmentsToLog = 3}) {
  final parts = path.split('/');
  if (parts.length <= segmentsToLog + 1) return path;
  final shortened = parts.sublist(parts.length - segmentsToLog + 1).join('/');
  return '.../$shortened';
}
