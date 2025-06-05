mixin FilePicker {
  Future<String?> pickAudio();
  Future<String?> pickArchive();
  Future<String?> pickTextFile();

  Future<List<String>?> pickMultipleImages({required int limit});

  Future<bool> shareFile(String absoluteFilePath);
}
