mixin FilePicker {
  Future<String?> pickAudio();
  Future<String?> pickArchive();
  Future<List<String>?> pickImages({required int limit});
  Future<String?> pickTextFile();

  Future<bool> shareFile(String absoluteFilePath);
}
