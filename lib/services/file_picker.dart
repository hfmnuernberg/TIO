mixin FilePicker {
  Future<String?> pickAudio();
  Future<String?> pickArchive();
  Future<String?> pickTextFile();

  Future<List<String>?> pickMultipleImages();

  Future<bool> shareFile(String absoluteFilePath);
}
