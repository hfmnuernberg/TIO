import 'dart:io';

import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:tiomusic/services/path_provider.dart';

class PathProviderDelegate implements PathProvider {
  @override
  Future<Directory> getApplicationDocumentsDirectory() => path_provider.getApplicationDocumentsDirectory();

  @override
  Future<Directory> getTemporaryDirectory() => path_provider.getTemporaryDirectory();
}
