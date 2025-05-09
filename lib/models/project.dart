import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tiomusic/models/blocks/image_block.dart';
import 'package:tiomusic/models/blocks/media_player_block.dart';
import 'package:tiomusic/models/blocks/metronome_block.dart';
import 'package:tiomusic/models/blocks/piano_block.dart';
import 'package:tiomusic/models/blocks/text_block.dart';
import 'package:tiomusic/models/blocks/tuner_block.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:uuid/uuid.dart';

part 'project.g.dart';

@JsonSerializable(explicitToJson: true)
class Project extends ChangeNotifier {
  @JsonKey(includeFromJson: false, includeToJson: false)
  late String _id;
  @JsonKey(includeFromJson: false, includeToJson: false)
  String get id => _id;

  @JsonKey(includeFromJson: true, includeToJson: true, defaultValue: 'Default Title', name: 'title')
  late String _title;
  @JsonKey(includeFromJson: false, includeToJson: false)
  String get title => _title;
  set title(String newTitle) {
    _title = newTitle;
    notifyListeners();
  }

  @JsonKey(includeFromJson: true, includeToJson: true, defaultValue: [])
  late List<ProjectBlock> _blocks;
  @JsonKey(includeFromJson: false, includeToJson: false)
  UnmodifiableListView<ProjectBlock> get blocks => UnmodifiableListView(_blocks);
  set blocks(List<ProjectBlock> newOrder) {
    _blocks = newOrder;
    notifyListeners();
  }

  @JsonKey(includeFromJson: true, includeToJson: true, defaultValue: TIOMusicParams.noImagePath)
  late String _thumbnailPath;
  @JsonKey(includeFromJson: false, includeToJson: false)
  String get thumbnailPath => _thumbnailPath;
  set thumbnailPath(String newThumbnailPath) {
    _thumbnailPath = newThumbnailPath;
    notifyListeners();
  }

  void setDefaultThumbnail() {
    _thumbnailPath = TIOMusicParams.noImagePath;
    notifyListeners();
  }

  @JsonKey(includeFromJson: true, includeToJson: true, name: 'timeLastModified')
  late DateTime _timeLastModified;
  @JsonKey(includeFromJson: false, includeToJson: false)
  DateTime get timeLastModified => _timeLastModified;
  set timeLastModified(DateTime timeLastModified) {
    _timeLastModified = timeLastModified;
    notifyListeners();
  }

  @JsonKey(
    includeFromJson: true,
    includeToJson: true,
    defaultValue: {
      ImageParams.kind: 0,
      MediaPlayerParams.kind: 0,
      MetronomeParams.kind: 0,
      PianoParams.kind: 0,
      TextParams.kind: 0,
      TunerParams.kind: 0,
    },
    name: 'toolCounter',
  )
  late Map<String, int> _toolCounter;
  @JsonKey(includeFromJson: false, includeToJson: false)
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

  Project(this._title, this._blocks, this._thumbnailPath, this._timeLastModified, this._toolCounter)
    : _id = const Uuid().v4();

  Project.defaultThumbnail(String title) {
    _id = const Uuid().v4();
    _title = title;
    _blocks = List.empty(growable: true);
    _timeLastModified = DateTime.now();
    _toolCounter = {
      ImageParams.kind: 0,
      MediaPlayerParams.kind: 0,
      MetronomeParams.kind: 0,
      PianoParams.kind: 0,
      TextParams.kind: 0,
      TunerParams.kind: 0,
    };
    setDefaultThumbnail();
  }

  factory Project.fromJson(Map<String, dynamic> json) => _$ProjectFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectToJson(this);

  void removeBlock(ProjectBlock block, ProjectLibrary projectLibrary) {
    _blocks.remove(block);
    notifyListeners();
  }

  void addBlock(ProjectBlock newBlock) {
    _blocks.insert(0, newBlock);
    notifyListeners();
  }

  void clearBlocks(ProjectLibrary projectLibrary) {
    _blocks.clear();
    notifyListeners();
  }

  ProjectBlock copyTool(ProjectBlock block, String newTitle) {
    Map<String, dynamic> jsonMap = block.toJson();
    ProjectBlock newBlock;

    switch (block.kind) {
      case TunerParams.kind:
        newBlock = TunerBlock.fromJson(jsonMap);
      case MetronomeParams.kind:
        newBlock = MetronomeBlock.from(block as MetronomeBlock);
      case MediaPlayerParams.kind:
        newBlock = MediaPlayerBlock.fromJson(jsonMap);
      case ImageParams.kind:
        newBlock = ImageBlock.fromJson(jsonMap);
      case PianoParams.kind:
        newBlock = PianoBlock.fromJson(jsonMap);
      case TextParams.kind:
        newBlock = TextBlock.fromJson(jsonMap);
      default:
        throw 'Error: Failed to copy tool. Unknown block type ${block.kind}!';
    }

    // new ID, otherwise the copied tool would have the same as the original tool
    newBlock.id = ProjectBlock.createNewId();
    newBlock.title = newTitle;
    addBlock(newBlock);

    return newBlock;
  }
}
