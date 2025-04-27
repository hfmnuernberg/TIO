String shortenPath(String? path, {int segmentsToLog = 3}) {
  if (path == null) return 'null';
  final parts = path.split('/');
  if (parts.length <= segmentsToLog + 1) return path;
  final shortened = parts.sublist(parts.length - segmentsToLog + 1).join('/');
  return '.../$shortened';
}
