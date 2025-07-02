mixin FilePicker {
  Future<List<String?>?> pickAudioFromFileSystem({required bool isMultiUploadEnabled});
  Future<List<String?>?> pickAudioFromMediaLibrary({required bool isMultiUploadEnabled});
  Future<String?> pickArchive();
  Future<List<String>> pickImages({required int limit});
  Future<String?> pickTextFile();

  Future<bool> shareFile(String absoluteFilePath);
}
