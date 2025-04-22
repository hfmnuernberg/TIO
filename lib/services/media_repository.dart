import 'dart:typed_data';

mixin MediaRepository {
  Future<void> init();

  Future<List<String>> list();

  Future<String?> import(String absoluteSourceFilePath, String relativeTargetFilePath);

  Future<String?> saveSamplesToWaveFile(String basename, Float64List samples);

  Future<void> delete(String relativeFilePath);
}
