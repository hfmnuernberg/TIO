import 'dart:io';
import 'package:tiomusic/models/blocks/image_block.dart';
import 'package:tiomusic/models/blocks/media_player_block.dart';
import 'package:tiomusic/models/file_io.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/project_library.dart';

abstract class FileReferences {
  // This dictionary is used to keep track of the files saved in the app storage
  // Every file has a reference of how many blocks are using it
  // If a file is no longer used in any block, it is deleted

  // Key = relative path of the file
  // Value = int num of blocks, that use the file
  static final Map<String, int> _fileReferences = {};

  static void increaseFileReference(String relativePath) {
    if (_fileReferences.containsKey(relativePath)) {
      _fileReferences[relativePath] = _fileReferences[relativePath]! + 1;
    } else {
      _fileReferences[relativePath] = 1;
    }
  }

  // decreases file reference counter and deletes file if reference counter is 0
  static void decreaseFileReference(
      String relativePath, ProjectLibrary projectLibrary) {
    if (_fileReferences.containsKey(relativePath)) {
      _fileReferences[relativePath] = _fileReferences[relativePath]! - 1;
      if (_fileReferences[relativePath]! < 1) {
        _fileReferences.remove(relativePath);
        FileIO.deleteFile(relativePath);
      }
    } else {
      // if the file is not in the dictionary, check if this file does not exist in any tool
      for (var block in _getMediaFileBlocks(projectLibrary)) {
        if ((block is MediaPlayerBlock && block.relativePath == relativePath) ||
            (block is ImageBlock && block.relativePath == relativePath)) {
          increaseFileReference(relativePath);
        }
      }
      if (!_fileReferences.containsKey(relativePath)) {
        FileIO.deleteFile(relativePath);
      }
    }
  }

  static Future init(ProjectLibrary projectLibrary) async {
    _fileReferences.clear();
    final List<FileSystemEntity> files = await FileIO.getAllMediaFiles();

    for (var file in files) {
      var relativeFilePath = await FileIO.getRelativeFilePath(file.path);
      for (var block in _getMediaFileBlocks(projectLibrary)) {
        if ((block is MediaPlayerBlock &&
                block.relativePath == relativeFilePath) ||
            (block is ImageBlock && block.relativePath == relativeFilePath)) {
          increaseFileReference(relativeFilePath);
        }
      }
      // delete the file, if it is not referenced anywhere
      if (!_fileReferences.containsKey(relativeFilePath)) {
        FileIO.deleteFile(relativeFilePath);
      }
    }
  }

  static List<ProjectBlock> _getMediaFileBlocks(ProjectLibrary projectLibrary) {
    var mediaFileBlocks = List<ProjectBlock>.empty(growable: true);
    for (var project in projectLibrary.projects) {
      for (var block in project.blocks) {
        if (block is MediaPlayerBlock) {
          mediaFileBlocks.add(block);
        } else if (block is ImageBlock) {
          mediaFileBlocks.add(block);
        }
      }
    }
    return mediaFileBlocks;
  }
}
