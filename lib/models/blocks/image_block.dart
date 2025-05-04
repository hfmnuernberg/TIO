import 'package:json_annotation/json_annotation.dart';
import 'package:path/path.dart';
import 'package:tiomusic/l10n/app_localization.dart';
import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/util/util_functions.dart';

part 'image_block.g.dart';

// ignore_for_file: must_be_immutable // FIXME: fix these block issues
// ignore_for_file: deprecated_member_use_from_same_package // FIXME: fix these block issues

@JsonSerializable()
class ImageBlock extends ProjectBlock {
  // this check is only used for quick tools at the moment
  @override
  List<Object> get props => [_id, relativePath];

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

  @override
  List<String> getSettingsFormatted(AppLocalizations l10n) => [basename(_relativePath)];

  factory ImageBlock.withDefaults(AppLocalizations l10n) {
    return ImageBlock(l10n.image, ProjectBlock.createNewId(), null, ImageParams.defaultPath, DateTime.now());
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
  get icon => ImageParams.icon;
}
