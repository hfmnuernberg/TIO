mixin FilePicker {
  Future<String?> pickAudio();
  Future<String?> pickArchive();
  Future<String?> pickImage();
  Future<String?> pickTextFile();

  Future<bool> shareFile(String absoluteFilePath);
}
