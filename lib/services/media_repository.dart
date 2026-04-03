mixin MediaRepository {
  Future<void> init();

  Future<List<String>> list();

  Future<String?> import(String absoluteSourceFilePath, String relativeTargetFilePath);

  Future<void> export(String relativeSourceFilePath, String absoluteTargetFilePath);

  Future<void> save(String filename, List<int> bytes);

  Future<void> delete(String relativeFilePath);
}
