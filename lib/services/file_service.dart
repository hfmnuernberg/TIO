import 'dart:io';

import 'package:path_provider/path_provider.dart' as path_provider;

mixin FileService {
  Future<Directory> getApplicationDocumentsDirectory();
  Future<Directory> getTemporaryDirectory();
}

class FileServiceImpl implements FileService {
  @override
  Future<Directory> getApplicationDocumentsDirectory() => path_provider.getApplicationDocumentsDirectory();

  @override
  Future<Directory> getTemporaryDirectory() => path_provider.getTemporaryDirectory();
}
