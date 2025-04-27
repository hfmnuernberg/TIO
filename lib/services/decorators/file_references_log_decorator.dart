import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/services/file_references.dart';
import 'package:tiomusic/util/log.dart';

class FileReferencesLogDecorator implements FileReferences {
  static final _logger = createPrefixLogger('FileReferences');

  final FileReferences _refs;

  FileReferencesLogDecorator(this._refs);

  @override
  Future<void> init(ProjectLibrary projectLibrary) {
    _logger.t('init(${projectLibrary.projects.length} projects)');
    return _refs.init(projectLibrary);
  }

  @override
  int count(String relativeFilePath) {
    final count = _refs.count(relativeFilePath);
    _logger.t('count($relativeFilePath): $count');
    return count;
  }

  @override
  Future<void> inc(String relativeFilePath) async {
    final oldCount = _refs.count(relativeFilePath);
    await _refs.inc(relativeFilePath);
    final newCount = _refs.count(relativeFilePath);
    _logger.t('inc($relativeFilePath) [$oldCount -> $newCount]');
  }

  @override
  Future<void> dec(String relativeFilePath, ProjectLibrary projectLibrary) async {
    final oldCount = _refs.count(relativeFilePath);
    await _refs.dec(relativeFilePath, projectLibrary);
    final newCount = _refs.count(relativeFilePath);
    _logger.t('dec($relativeFilePath, ${projectLibrary.projects.length} projects) [$oldCount -> $newCount]');
  }
}
