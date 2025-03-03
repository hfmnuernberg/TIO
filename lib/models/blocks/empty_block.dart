import 'package:tiomusic/models/project_block.dart';

// ignore_for_file: must_be_immutable // FIXME: fix these block issues

// This empty block is needed to avoid a weird bug when opening the same block type as the previous one in an island

class EmptyBlock extends ProjectBlock {
  @override
  List<Object> get props => [];

  @override
  String get kind => 'empty';

  late String _title;
  @override
  String get title => _title;
  @override
  set title(String newTitle) {
    _title = newTitle;
    notifyListeners();
  }

  late DateTime _timeLastModified;
  @override
  DateTime get timeLastModified => _timeLastModified;
  @override
  set timeLastModified(DateTime newTime) {
    _timeLastModified = newTime;
  }

  late String _id;
  @override
  String get id => _id;
  @override
  set id(String newID) {
    _id = newID;
    notifyListeners();
  }

  late String? _islandToolID;
  @override
  String? get islandToolID => _islandToolID;
  @override
  set islandToolID(String? newToolID) {
    _islandToolID = newToolID;
    notifyListeners();
  }

  EmptyBlock() {
    _timeLastModified = DateTime.now();
    _title = 'Empty';
    _id = 'empty';
    _islandToolID = '';
  }

  @override
  get icon => {};

  @override
  Map<String, dynamic> toJson() => {};
}
