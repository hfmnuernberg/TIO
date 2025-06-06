mixin FileSystem {
  Future<void> init();

  String get appFolderPath;
  String get tmpFolderPath;

  String toAbsoluteFilePath(String relativeFilePath);
  String toRelativeFilePath(String absoluteFilePath);
  String toFilename(String filePath);
  String toBasename(String filePath);
  String? toExtension(String filePath);

  bool existsFile(String absoluteFilePath);
  Future<bool> existsFileAfterGracePeriod(String absoluteFilePath);

  Future<List<String>> listFiles(String absoluteFolderPath);

  Future<String> loadFileAsString(String absoluteFilePath);
  Future<List<int>> loadFileAsBytes(String absoluteFilePath);

  Future<void> saveFileAsString(String absoluteFilePath, String data);
  Future<void> saveFileAsBytes(String absoluteFilePath, List<int> data);

  Future<void> copyFile(String absoluteSourceFilePath, String absoluteDestinationFilePath);

  Future<void> deleteFile(String absoluteFilePath);

  Future<void> deleteIfTmpFile(String absoluteSourceFilePath);

  Future<void> createFolder(String absoluteFolderPath);
}
