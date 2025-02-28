import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/file_io.dart';
import 'package:tiomusic/models/project_library.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/util/util_functions.dart';

part 'image_block.g.dart';

// ignore_for_file: must_be_immutable // FIXME: fix these block issues

@JsonSerializable()
class ImageBlock extends ProjectBlock {
  // this check is only used for quick tools at the moment
  @override
  List<Object> get props => [relativePath];

  @override
  @JsonKey(defaultValue: ImageParams.kind, includeFromJson: false, includeToJson: true)
  String get kind => ImageParams.kind;

  late String _title;
  @override
  @JsonKey(defaultValue: ImageParams.displayName)
  String get title => _title;
  @override
  set title(String newTitle) {
    _title = newTitle;
    notifyListeners();
  }

  late DateTime _timeLastModified;
  @override
  @JsonKey(defaultValue: getCurrentDateTime)
  DateTime get timeLastModified => _timeLastModified;
  @override
  set timeLastModified(DateTime newTime) {
    _timeLastModified = newTime;
  }

  late String _relativePath;
  @JsonKey(defaultValue: ImageParams.defaultPath)
  String get relativePath => _relativePath;
  set relativePath(String newPath) {
    _relativePath = newPath;
    notifyListeners();
  }

  late String _id;
  @override
  @JsonKey(defaultValue: '')
  String get id => _id;
  @override
  set id(String newID) {
    _id = newID;
    notifyListeners();
  }

  late String? _islandToolID;
  @override
  @JsonKey(defaultValue: null)
  String? get islandToolID => _islandToolID;
  @override
  set islandToolID(String? newToolID) {
    _islandToolID = newToolID;
    notifyListeners();
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  ImageProvider? _image;
  @JsonKey(includeFromJson: false, includeToJson: false)
  ImageProvider? get image => _image;

  Future<void> setImage(String newRelativePath) async {
    if (newRelativePath.isEmpty) return;

    var absolutePath = await FileIO.getAbsoluteFilePath(newRelativePath);

    if (!await File(absolutePath).exists()) {
      debugPrint('Image could not be set in image block, because no file exists at path: $newRelativePath');
      return;
    }

    _image = FileImage(File(absolutePath));
    _relativePath = newRelativePath;

    notifyListeners();
  }

  @override
  List<String> getSettingsFormatted() {
    return [FileIO.getFileName(_relativePath)];
  }

  static Future<ImageBlock> create(
    String title,
    String id,
    String? islandToolID,
    String relativePath,
    DateTime timeLastModified,
  ) async {
    final imageBlock = ImageBlock(title, id, islandToolID, relativePath, timeLastModified);
    await imageBlock.setImage(relativePath);
    return imageBlock;
  }

  factory ImageBlock.withDefaults() {
    return ImageBlock(
      ImageParams.displayName,
      ProjectBlock.createNewId(),
      null,
      ImageParams.defaultPath,
      DateTime.now(),
    );
  }

  factory ImageBlock.withTitle(String title) {
    return ImageBlock(title, ProjectBlock.createNewId(), null, ImageParams.defaultPath, DateTime.now());
  }

  ImageBlock(String title, String id, String? islandToolID, String relativePath, DateTime timeLastModified) {
    _timeLastModified = timeLastModified;
    _title = title;
    _relativePath = relativePath;
    _islandToolID = islandToolID;
    _id = ProjectBlock.getIdOrCreateNewId(id);
    notifyListeners();
  }

  factory ImageBlock.fromJson(Map<String, dynamic> json) => _$ImageBlockFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ImageBlockToJson(this);

  @override
  Icon get icon => blockTypeInfos[BlockType.image]!.icon;

  Future<void> pickImage(BuildContext context, ProjectLibrary projectLibrary) async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedImage == null) return;

      if (!context.mounted) return;

      final newRelativePath = await FileIO.saveFileToAppStorage(
        context,
        File(pickedImage.path),
        FileIO.getFileNameWithoutExtension(pickedImage.path),
        _relativePath.isEmpty ? null : _relativePath,
        projectLibrary,
      );

      if (newRelativePath == null) return;

      await setImage(newRelativePath);

      notifyListeners();
    } on PlatformException catch (e) {
      debugPrint('Failed to pick image: $e');
    }
  }
}
