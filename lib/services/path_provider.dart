import 'dart:io';

mixin PathProvider {
  Future<Directory> getApplicationDocumentsDirectory();

  Future<Directory> getTemporaryDirectory();
}
