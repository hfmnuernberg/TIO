import 'dart:typed_data';

mixin MediaRepository {
  Future<void> init();

  Future<List<String>> list();

  Future<String?> import(String absoluteSourceFilePath, String relativeTargetFilePath);

  Future<void> export(String relativeSourceFilePath, String absoluteTargetFilePath);

  Future<void> save(String filename, List<int> bytes);

  Future<String?> saveSamplesToWaveFile(String basename, Float64List samples);

  Future<void> delete(String relativeFilePath);

  Future<void> deleteTemporaryFiles(String absoluteSourceFilePath);
}
