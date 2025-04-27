import 'package:tiomusic/models/blocks/image_block.dart';
import 'package:tiomusic/models/blocks/media_player_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/services/file_references.dart';
import 'package:tiomusic/services/media_repository.dart';

class FileReferencesImpl implements FileReferences {
  final MediaRepository _mediaRepo;
  final Map<String, int> _refs = {};

  FileReferencesImpl(this._mediaRepo);

  @override
  Future<void> init(ProjectLibrary projectLibrary) async {
    _refs.clear();
    final List<String> paths = await _mediaRepo.list();
    for (final path in paths) {
      final refCount = _countRefs(path, projectLibrary);
      if (refCount == 0) {
        _mediaRepo.delete(path);
      } else {
        _refs[path] = refCount;
      }
    }
  }

  @override
  int count(String path) => _refs[path] ?? 0;

  @override
  Future<void> inc(String path) async {
    if (path == '') return;
    _refs[path] = _refs.containsKey(path) ? count(path) + 1 : 1;
  }

  @override
  Future<void> dec(String path, ProjectLibrary projectLibrary) async {
    if (path == '') return;
    if (_refs.containsKey(path)) {
      _refs[path] = count(path) - 1;
      if (_refs[path]! <= 0) {
        _refs.remove(path);
        _mediaRepo.delete(path);
      }
    } else {
      final refCount = _countRefs(path, projectLibrary);
      if (refCount == 0) await _mediaRepo.delete(path);
    }
  }

  int _countRefs(String path, ProjectLibrary projectLibrary) =>
      _countImageRefs(path, projectLibrary) + _countMediaPlayerRefs(path, projectLibrary);

  int _countImageRefs(String path, ProjectLibrary projectLibrary) =>
      projectLibrary.projects
          .expand((project) => project.blocks)
          .whereType<ImageBlock>()
          .where((block) => block.relativePath == path)
          .length;

  int _countMediaPlayerRefs(String path, ProjectLibrary projectLibrary) =>
      projectLibrary.projects
          .expand((project) => project.blocks)
          .whereType<MediaPlayerBlock>()
          .where((block) => block.relativePath == path)
          .length;
}
