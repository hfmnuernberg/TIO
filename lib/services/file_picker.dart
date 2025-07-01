mixin FilePicker {
  Future<List<String?>?> pickAudioFromFileSystem();
  Future<List<String?>?> pickAudioFromMediaLibrary();
  Future<String?> pickArchive();
  Future<List<String>> pickImages({required int limit});
  Future<String?> pickTextFile();

  Future<bool> shareFile(String absoluteFilePath);
}
