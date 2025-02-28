import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tiomusic/models/blocks/image_block.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tiomusic/models/blocks/media_player_block.dart';
import 'package:tiomusic/models/blocks/metronome_block.dart';
import 'package:tiomusic/models/blocks/piano_block.dart';
import 'package:tiomusic/models/blocks/text_block.dart';
import 'package:tiomusic/models/blocks/tuner_block.dart';
import 'package:tiomusic/models/file_io.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/util/util_functions.dart';

part 'project.g.dart';

@JsonSerializable(explicitToJson: true)
class Project extends ChangeNotifier {
  late String _title;
  @JsonKey(defaultValue: 'Default Title')
  String get title => _title;
  set title(String newTitle) {
    _title = newTitle;
    notifyListeners();
  }

  late String _thumbnailPath;
  @JsonKey(defaultValue: TIOMusicParams.noImagePath)
  String get thumbnailPath => _thumbnailPath;
  set thumbnailPath(String newThumbnailPath) {
    _thumbnailPath = newThumbnailPath;
    notifyListeners();
  }

  late Map<String, int> _toolCounter;
  @JsonKey(
    defaultValue: {
      ImageParams.kind: 0,
      MediaPlayerParams.kind: 0,
      MetronomeParams.kind: 0,
      PianoParams.kind: 0,
      TextParams.kind: 0,
      TunerParams.kind: 0,
    },
  )
  Map<String, int> get toolCounter => _toolCounter;
  void increaseCounter(String toolType) {
    _toolCounter.update(
      toolType,
      (value) {
        return value + 1;
      },
      ifAbsent: () {
        return 1;
      },
    );
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  ImageProvider? _thumbnail;
  @JsonKey(includeFromJson: false, includeToJson: false)
  ImageProvider? get thumbnail => _thumbnail;

  void setThumbnail(String newRelativePath) async {
    _thumbnailPath = newRelativePath;
    var absolutePath = await FileIO.getAbsoluteFilePath(newRelativePath);
    if (File(absolutePath).existsSync()) {
      _thumbnail = FileImage(File(absolutePath));
    } else {
      _thumbnail = const AssetImage(TIOMusicParams.tiomusicIconPath);
    }
    notifyListeners();
  }

  @JsonKey(includeFromJson: true, includeToJson: true, defaultValue: [])
  late List<ProjectBlock> _blocks;
  UnmodifiableListView<ProjectBlock> get blocks => UnmodifiableListView(_blocks);

  late DateTime timeLastModified;

  Project(String title, this._blocks, String thumbnailPath, this.timeLastModified, Map<String, int> toolCounter) {
    _title = title;
    _toolCounter = toolCounter;
    _thumbnailPath = thumbnailPath;
    setThumbnail(_thumbnailPath);
  }

  Project.defaultPicture(String title) {
    timeLastModified = DateTime.now();
    _title = title;
    _toolCounter = {
      ImageParams.kind: 0,
      MediaPlayerParams.kind: 0,
      MetronomeParams.kind: 0,
      PianoParams.kind: 0,
      TextParams.kind: 0,
      TunerParams.kind: 0,
    };
    _blocks = List.empty(growable: true);
    _thumbnailPath = TIOMusicParams.noImagePath;
    setThumbnail(_thumbnailPath);
  }

  factory Project.fromJson(Map<String, dynamic> json) => _$ProjectFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectToJson(this);

  void removeBlock(ProjectBlock block, ProjectLibrary projectLibrary) {
    updateFileReferenceForFileOfBlock(block, IncreaseOrDecrease.decrease, projectLibrary);
    _blocks.remove(block);
    notifyListeners();
  }

  void addBlock(ProjectBlock newBlock) {
    _blocks.insert(0, newBlock);
    notifyListeners();
  }

  void clearBlocks(ProjectLibrary projectLibrary) {
    for (ProjectBlock block in _blocks) {
      updateFileReferenceForFileOfBlock(block, IncreaseOrDecrease.decrease, projectLibrary);
    }
    _blocks.clear();
    notifyListeners();
  }

  // returning the new projectBlock
  ProjectBlock copyTool(ProjectBlock block, String newTitle) {
    Map<String, dynamic> jsonMap = block.toJson();
    ProjectBlock newBlock;

    switch (block.kind) {
      case TunerParams.kind:
        newBlock = TunerBlock.fromJson(jsonMap);
        break;
      case MetronomeParams.kind:
        newBlock = MetronomeBlock.from(block as MetronomeBlock);
        break;
      case MediaPlayerParams.kind:
        newBlock = MediaPlayerBlock.fromJson(jsonMap);
        break;
      case ImageParams.kind:
        newBlock = ImageBlock.fromJson(jsonMap);
        break;
      case PianoParams.kind:
        newBlock = PianoBlock.fromJson(jsonMap);
        break;
      case TextParams.kind:
        newBlock = TextBlock.fromJson(jsonMap);
        break;
      default:
        throw ('Error: Failed to copy tool. Unknown block type ${block.kind}!');
    }

    // new ID, otherwise the copied tool would have the same as the original tool
    newBlock.id = ProjectBlock.createNewId();
    newBlock.title = newTitle;
    addBlock(newBlock);

    return newBlock;
  }
}
