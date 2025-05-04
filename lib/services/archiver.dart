import 'package:tiomusic/models/project.dart';

mixin Archiver {
  Future<void> init();

  Future<String> archiveProject(Project project);

  Future<Project> extractProject(String archivePath);

  Future<void> deleteArchive(String archivePath);
}
