import 'package:flutter/services.dart';

class MediaLibraryPickResult {
  final List<String> paths;
  final int skippedCount;

  const MediaLibraryPickResult({required this.paths, required this.skippedCount});
}

class IosMediaLibraryPicker {
  static const _channel = MethodChannel('tio/media_library_picker');

  Future<MediaLibraryPickResult?> pickAudio({required bool allowMultiple}) async {
    final result = await _channel.invokeMethod<Map>('pickAudio', {'allowMultiple': allowMultiple});

    if (result == null) return null;

    final paths = (result['paths'] as List?)?.cast<String>() ?? [];
    final skippedCount = result['skippedCount'] as int? ?? 0;

    return MediaLibraryPickResult(paths: paths, skippedCount: skippedCount);
  }
}
