mixin FilePicker {
  Future<String?> pickAudioFromFileSystem();
  Future<String?> pickAudioFromMediaLibrary();
  Future<String?> pickArchive();
  Future<List<String>> pickImages({required int limit});
  Future<String?> pickTextFile();

  Future<bool> shareFile(String absoluteFilePath);
}
