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
  Future<List<String>> list() => _fs.listFiles(_mediaFolderPath);

  @override
  Future<String?> import(String absoluteSourceFilePath, String basename) async {
    // TODO
    // check if file exists / can be accessed
    // if (!_fs.existsFile(absoluteSourceFilePath)) {
    //   // try again after delay, maybe file needs time to download
    //   await Future.delayed(const Duration(milliseconds: 500));
    //
    //   if (!_fs.existsFile(absoluteSourceFilePath)) {
    //     if (context.mounted) {
    //       await showFileNotAccessibleDialog(context, fileName: fileToSave.path);
    //     }
    //     return null;
    //   }
    // }

    // this delay seems to prevent the following error when the "fileToSave" is not found immediately:
    // flutter: media player load wav failed: unsupported feature: core (probe): no suitable format reader found
    // await Future.delayed(const Duration(milliseconds: 100));

    final extension = (_fs.toExtension(absoluteSourceFilePath) ?? '').toLowerCase();

    // TODO
    // check if we accept this file format
    // if (acceptedFormats != null) {
    //   if (!acceptedFormats.contains(extension)) {
    //     if (context.mounted) {
    //       await showFormatNotSupportedDialog(context, extension);
    //     }
    //     return null;
    //   }
    // }

    final filename = _getNextAvailableFilename(basename, extension);
    final relativePath = '$_mediaFolderName/$filename';
    final absolutePath = '$_mediaFolderPath/$filename';

    // TODO
    // FileReferences.increaseFileReference(relativePath);
    // if (relativePathOfPreviousFile != null) {
    //   FileReferences.decreaseFileReference(relativePathOfPreviousFile, projectLibrary);
    // }

    await _fs.saveFileAsBytes(absolutePath, await _fs.loadFileAsBytes(absoluteSourceFilePath));

    return relativePath;
  }

  @override
  Future<String?> saveSamplesToWaveFile({
    required Float64List samples,
    required String basename,
    String? relativePathToPreviousFile,
  }) async {
    final filename = _getNextAvailableFilename(basename, 'wav');
    final relativePath = '$_mediaFolderName/$filename';
    final absolutePath = '$_mediaFolderPath/$filename';

    final wavFile = Wav([samples], await getSampleRate(), WavFormat.float32);
    await wavFile.writeFile(absolutePath);

    return _fs.existsFile(absolutePath) ? relativePath : null;
  }

  @override
  Future<void> delete(String relativePath) async {
    final absolutePath = '$_mediaFolderPath/$relativePath';
    if (_fs.existsFile(absolutePath)) await _fs.deleteFile(absolutePath);
  }

  String _toFilename(String basename, String extension, [int counter = 0]) =>
      '$basename${counter == 0 ? '' : '_$counter'}.$extension';

  String _toAbsoluteFilePath(String filename) =>
      _fs.toAbsoluteFilePath('$_mediaFolderPath/$filename');

  String _getNextAvailableFilename(String basename, String extension, [int counter = 0]) {
    final filename = _toFilename(basename, extension, counter);
    if (!_fs.existsFile(_toAbsoluteFilePath(filename))) return filename;
    return _getNextAvailableFilename(basename, extension, counter + 1);
  }
}
