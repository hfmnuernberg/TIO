import 'dart:typed_data';

import 'package:tiomusic/services/decorators/log_decorator_utils.dart';
import 'package:tiomusic/services/media_repository.dart';
import 'package:tiomusic/util/log.dart';

class MediaRepositoryLogDecorator implements MediaRepository {
  static final _logger = createPrefixLogger('MediaRepository');

  final MediaRepository _repo;

  MediaRepositoryLogDecorator(this._repo);

  @override
  Future<void> init() {
    _logger.t('init()');
    return _repo.init();
  }

  @override
  Future<List<String>> list() async {
    final files = await _repo.list();
    _logger.t('list(): ${files.length} files');
    return files;
  }

  @override
  Future<String?> import(String absoluteSourceFilePath, String relativeTargetFilePath) async {
    final relativePath = await _repo.import(absoluteSourceFilePath, relativeTargetFilePath);
    _logger.t('import(${shortenPath(absoluteSourceFilePath)}, $relativeTargetFilePath): $relativePath');
    return relativePath;
  }

  @override
  Future<void> export(String relativeSourceFilePath, String absoluteTargetFilePath) async {
    _logger.t('export($relativeSourceFilePath, ${shortenPath(absoluteTargetFilePath)})');
    await _repo.export(relativeSourceFilePath, absoluteTargetFilePath);
  }

  @override
  Future<void> save(String filename, List<int> bytes) async {
    _logger.t('save($filename, ${bytes.length} bytes)');
    return _repo.save(filename, bytes);
  }

  @override
  Future<String?> saveSamplesToWaveFile(String basename, Float64List samples) async {
    final relativePath = await _repo.saveSamplesToWaveFile(basename, samples);
    _logger.t('saveSamplesToWaveFile($basename, ${samples.length} samples): $relativePath');
    return relativePath;
  }

  @override
  Future<void> delete(String relativeFilePath) async {
    _logger.t('delete($relativeFilePath)');
    return _repo.delete(relativeFilePath);
  }

  @override
  Future<void> deleteTemporaryFiles(String absoluteSourceFilePath) async {
    _logger.t('delete($absoluteSourceFilePath)');
    return _repo.deleteTemporaryFiles(absoluteSourceFilePath);
  }
}
