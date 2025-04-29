import 'package:tiomusic/models/project.dart';
import 'package:tiomusic/services/archiver.dart';
import 'package:tiomusic/services/decorators/log_decorator_utils.dart';
import 'package:tiomusic/util/log.dart';

class ArchiverLogDecorator implements Archiver {
  static final _logger = createPrefixLogger('Archiver');

  final Archiver _archiver;

  ArchiverLogDecorator(this._archiver);

  @override
  Future<void> init() {
    _logger.t('init()');
    return _archiver.init();
  }

  @override
  Future<String> archiveProject(Project project) async {
    final archivePath = await _archiver.archiveProject(project);
    _logger.t('archiveProject(${project.title}): ${shortenPath(archivePath)}');
    return archivePath;
  }

  @override
  Future<Project> extractProject(String archivePath) async {
    final project = await _archiver.extractProject(archivePath);
    _logger.t('extractProject(${shortenPath(archivePath)}): ${project.title}');
    return project;
  }

  @override
  Future<void> deleteArchive(String archivePath) async {
    _logger.t('deleteArchive(${shortenPath(archivePath)})');
    await _archiver.deleteArchive(archivePath);
  }
}
