import 'dart:async';
import 'dart:typed_data';

import 'package:tiomusic/services/file_system.dart';
import 'package:tiomusic/services/media_repository.dart';
import 'package:tiomusic/src/rust/api/api.dart';
import 'package:wav/wav_file.dart';
import 'package:wav/wav_format.dart';

const _mediaFolderName = 'media';

class FileBasedMediaRepository implements MediaRepository {
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
    final filename = _getNextAvailableFilename(_sanitize(basename), extension);
    final relativePath = '$_mediaFolderName/$filename';
    final absolutePath = '$_mediaFolderPath/$filename';

    await _fs.copyFile(absoluteSourceFilePath, absolutePath);

    await _fs.deleteIfTmpFile(absoluteSourceFilePath);

    return relativePath;
  }

  @override
  Future<void> export(String relativeSourceFilePath, String absoluteTargetFilePath) async =>
      _fs.copyFile('${_fs.appFolderPath}/$relativeSourceFilePath', absoluteTargetFilePath);

  @override
  Future<void> save(String filename, List<int> bytes) async =>
      _fs.saveFileAsBytes('$_mediaFolderPath/${_sanitize(filename)}', bytes);

  @override
  Future<String?> saveSamplesToWaveFile(String basename, Float64List samples) async {
    final filename = _getNextAvailableFilename(_sanitize(basename), 'wav');
    final relativePath = '$_mediaFolderName/$filename';
    final absolutePath = '$_mediaFolderPath/$filename';

    final wavFile = Wav([samples], await getSampleRate(), WavFormat.float32);
    await wavFile.writeFile(absolutePath);

    return _fs.existsFile(absolutePath) ? relativePath : null;
  }

  @override
  Future<void> delete(String relativePath) async {
    final absolutePath = '${_fs.appFolderPath}/$relativePath';
    if (_fs.existsFile(absolutePath)) await _fs.deleteFile(absolutePath);
  }

  String _sanitize(String filename) => filename.replaceAll('/', '-');

  String _toFilename(String basename, String extension, [int counter = 0]) =>
      '$basename${counter == 0 ? '' : '_$counter'}.$extension';

  String _toAbsoluteFilePath(String filename) => _fs.toAbsoluteFilePath('$_mediaFolderPath/$filename');

  String _getNextAvailableFilename(String basename, String extension, [int counter = 0]) {
    final filename = _toFilename(basename, extension, counter);
    if (!_fs.existsFile(_toAbsoluteFilePath(filename))) return filename;
    return _getNextAvailableFilename(basename, extension, counter + 1);
  }
}
