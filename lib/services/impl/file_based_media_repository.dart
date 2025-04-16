import 'dart:async';
import 'dart:typed_data';

import 'package:tiomusic/services/file_system.dart';
import 'package:tiomusic/services/media_repository.dart';
import 'package:tiomusic/src/rust/api/api.dart';
import 'package:tiomusic/util/log.dart';
import 'package:wav/wav_file.dart';
import 'package:wav/wav_format.dart';

const _mediaFolderName = 'media';

class FileBasedMediaRepository implements MediaRepository {
  static final _logger = createPrefixLogger('MediaRepository');

  final FileSystem _fs;

  const FileBasedMediaRepository(this._fs);

  String get _mediaFolderPath => '${_fs.appFolderPath}/$_mediaFolderName';

  @override
  Future<void> init() => _fs.createFolder(_mediaFolderPath);

  @override
  Future<List<String>> list() async => (await _fs.listFiles(_mediaFolderPath)).map(_fs.toRelativeFilePath).toList();

  @override
  Future<String?> import(String absoluteSourceFilePath, String basename) async {
    final extension = (_fs.toExtension(absoluteSourceFilePath) ?? '').toLowerCase();
    final filename = _getNextAvailableFilename(basename, extension);
    final relativePath = '$_mediaFolderName/$filename';
    final absolutePath = '$_mediaFolderPath/$filename';

    _logger.t("Importing '$absoluteSourceFilePath' to '$relativePath'.");

    await _fs.saveFileAsBytes(absolutePath, await _fs.loadFileAsBytes(absoluteSourceFilePath));

    return relativePath;
  }

  @override
  Future<String?> saveSamplesToWaveFile({
    required Float64List samples,
    required String basename,
    String? relativePathToPreviousFile, // TODO: use this
  }) async {
    final filename = _getNextAvailableFilename(basename, 'wav');
    final relativePath = '$_mediaFolderName/$filename';
    final absolutePath = '$_mediaFolderPath/$filename';

    _logger.t("Saving samples to '$relativePath'.");

    final wavFile = Wav([samples], await getSampleRate(), WavFormat.float32);
    await wavFile.writeFile(absolutePath);

    return _fs.existsFile(absolutePath) ? relativePath : null;
  }

  @override
  Future<void> delete(String relativePath) async {
    _logger.t("Deleting '$relativePath'.");
    final absolutePath = '${_fs.appFolderPath}/$relativePath';
    if (_fs.existsFile(absolutePath)) await _fs.deleteFile(absolutePath);
  }

  String _toFilename(String basename, String extension, [int counter = 0]) =>
      '$basename${counter == 0 ? '' : '_$counter'}.$extension';

  String _toAbsoluteFilePath(String filename) => _fs.toAbsoluteFilePath('$_mediaFolderPath/$filename');

  String _getNextAvailableFilename(String basename, String extension, [int counter = 0]) {
    final filename = _toFilename(basename, extension, counter);
    if (!_fs.existsFile(_toAbsoluteFilePath(filename))) return filename;
    return _getNextAvailableFilename(basename, extension, counter + 1);
  }
}
