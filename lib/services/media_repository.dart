import 'dart:typed_data';

mixin MediaRepository {
  Future<void> init();

  Future<List<String>> list();

  Future<String?> import(String absoluteSourceFilePath, String relativeTargetFilePath);

  Future<String?> saveSamplesToWaveFile({
    required Float64List samples,
    required String basename,
    String? relativePathToPreviousFile,
  });

  Future<void> delete(String relativeFilePath);
}
