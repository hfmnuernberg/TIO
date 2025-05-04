import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/services/project_repository.dart';
import 'package:tiomusic/util/log.dart';

class ProjectRepositoryLogDecorator implements ProjectRepository {
  static final _logger = createPrefixLogger('ProjectRepository');

  final ProjectRepository _repo;

  ProjectRepositoryLogDecorator(this._repo);

  @override
  bool existsLibrary() {
    final exists = _repo.existsLibrary();
    _logger.t('existsLibrary(): $exists');
    return exists;
  }

  @override
  Future<ProjectLibrary> loadLibrary() async {
    final projectLibrary = await _repo.loadLibrary();
    _logger.t('loadLibrary(): ${projectLibrary.projects.length} projects');
    return projectLibrary;
  }

  @override
  Future<void> saveLibrary(ProjectLibrary projectLibrary) async {
    _logger.t('saveLibrary(${projectLibrary.projects.length} projects)');
    return _repo.saveLibrary(projectLibrary);
  }

  @override
  Future<void> deleteLibrary() async {
    _logger.t('deleteLibrary()');
    return _repo.deleteLibrary();
  }
}
