import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/services/project_library_repository.dart';
import 'package:tiomusic/util/log.dart';

class ProjectLibraryRepositoryLogDecorator implements ProjectLibraryRepository {
  static final _logger = createPrefixLogger('ProjectLibraryRepository');

  final ProjectLibraryRepository _repo;

  ProjectLibraryRepositoryLogDecorator(this._repo);

  @override
  Future<void> delete() async {
    _logger.t('delete()');
    return _repo.delete();
  }

  @override
  bool exists() {
    final exists = _repo.exists();
    _logger.t('exists(): $exists');
    return exists;
  }

  @override
  Future<ProjectLibrary> load() async {
    final projectLibrary = await _repo.load();
    _logger.t('load(): ${projectLibrary.projects.length} projects');
    return projectLibrary;
  }

  @override
  Future<void> save(ProjectLibrary projectLibrary) async {
    _logger.t('save(${projectLibrary.projects.length} projects)');
    return _repo.save(projectLibrary);
  }

  @override
  Future<void> export() async {
    _logger.t('export()');
    return _repo.export();
  }

  @override
  Future<void> import() async {
    _logger.t('import()');
    return _repo.import();
  }
}
