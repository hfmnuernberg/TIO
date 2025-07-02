mixin FilePicker {
  Future<List<String?>?> pickAudioFromFileSystem({required bool isMultipleAllowed});
  Future<List<String?>?> pickAudioFromMediaLibrary({required bool isMultipleAllowed});
  Future<String?> pickArchive();
  Future<List<String>> pickImages({required int limit});
  Future<String?> pickTextFile();

  Future<bool> shareFile(String absoluteFilePath);
}
