import 'package:json_annotation/json_annotation.dart';
import 'package:tiomusic/l10n/app_localization.dart';

import 'package:tiomusic/models/project_block.dart';
import 'package:tiomusic/models/sound_font.dart';
import 'package:tiomusic/util/constants.dart';
import 'package:tiomusic/util/sound_font_extension.dart';
import 'package:tiomusic/util/util_functions.dart';
import 'package:tiomusic/util/util_midi.dart';

part 'piano_block.g.dart';

// ignore_for_file: must_be_immutable // FIXME: fix these block issues
// ignore_for_file: deprecated_member_use_from_same_package // FIXME: fix these block issues

@JsonSerializable()
class PianoBlock extends ProjectBlock {
  // add here all the fields that should be compared when checking if two class instances have the same values
  // for now this check is only used to compare quick tools to the default settings, so some properties are left out here
  @override
  List<Object> get props => [_id, _volume, _keyboardPosition, _soundFontIndex];

  @override
  @JsonKey(defaultValue: PianoParams.kind, includeFromJson: false, includeToJson: true)
  String get kind => PianoParams.kind;

  late String _title;
  @override
  @JsonKey(defaultValue: PianoParams.displayName)
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

  late double _volume;
  @JsonKey(defaultValue: TIOMusicParams.defaultVolume)
  double get volume => _volume;
  set volume(double newValue) {
    _volume = newValue;
    notifyListeners();
  }

  // the midi number of the lowest visible key
  late int _keyboardPosition;
  @JsonKey(defaultValue: PianoParams.defaultKeyboardPosition)
  int get keyboardPosition => _keyboardPosition;
  set keyboardPosition(int newValue) {
    _keyboardPosition = newValue;
    notifyListeners();
  }

  late int _soundFontIndex;
  @JsonKey(defaultValue: PianoParams.defaultSoundFontIndex)
  int get soundFontIndex => _soundFontIndex;
  set soundFontIndex(int newValue) {
    _soundFontIndex = newValue;
    notifyListeners();
  }

  double concertPitch = 440;

  @override
  List<String> getSettingsFormatted(AppLocalizations l10n) {
    return [
      '${l10n.pianoLowestKey}: ${midiToNameAndOctave(_keyboardPosition)}',
      SoundFont.values[_soundFontIndex].getLabel(l10n),
    ];
  }

  PianoBlock(
    String title,
    String id,
    String? islandToolID,
    double volume,
    int keyboardPosition,
    int soundFontIndex,
    DateTime timeLastModified,
  ) {
    _timeLastModified = timeLastModified;
    _title = title;
    _volume = volume;
    _keyboardPosition = keyboardPosition;
    _soundFontIndex = soundFontIndex;
    _islandToolID = islandToolID;
    _id = ProjectBlock.getIdOrCreateNewId(id);
  }

  PianoBlock.withDefaults(AppLocalizations l10n) {
    _timeLastModified = DateTime.now();
    _title = l10n.piano;
    _volume = TIOMusicParams.defaultVolume;
    _keyboardPosition = PianoParams.defaultKeyboardPosition;
    _soundFontIndex = PianoParams.defaultSoundFontIndex;
    _islandToolID = null;
    _id = ProjectBlock.createNewId();
  }

  PianoBlock.withTitle(String newTitle) {
    _timeLastModified = DateTime.now();
    _title = newTitle;
    _volume = TIOMusicParams.defaultVolume;
    _keyboardPosition = PianoParams.defaultKeyboardPosition;
    _soundFontIndex = PianoParams.defaultSoundFontIndex;
    _islandToolID = null;
    _id = ProjectBlock.createNewId();
  }

  void toneDown() {
    _keyboardPosition--;
    if (midiToName(_keyboardPosition).length > 1) {
      _keyboardPosition--;
    }
    if (_keyboardPosition < PianoParams.lowestMidiNote) {
      _keyboardPosition = PianoParams.lowestMidiNote;
    }
    notifyListeners();
  }

  void toneUp() {
    _keyboardPosition++;
    if (midiToName(_keyboardPosition).length > 1) {
      _keyboardPosition++;
    }
    if (_keyboardPosition > PianoParams.highestMidiNote - PianoParams.numberOfWhiteKeys - 7) {
      _keyboardPosition = PianoParams.highestMidiNote - PianoParams.numberOfWhiteKeys - 7;
    }
    notifyListeners();
  }

  void octaveDown() {
    _keyboardPosition -= 12;
    if (_keyboardPosition < PianoParams.lowestMidiNote) {
      _keyboardPosition = PianoParams.lowestMidiNote;
    }
    notifyListeners();
  }

  void octaveUp() {
    _keyboardPosition += 12;
    if (_keyboardPosition > PianoParams.highestMidiNote - PianoParams.numberOfWhiteKeys - 7) {
      _keyboardPosition = PianoParams.highestMidiNote - PianoParams.numberOfWhiteKeys - 7;
    }
    notifyListeners();
  }

  @override
  get icon => PianoParams.icon;

  factory PianoBlock.fromJson(Map<String, dynamic> json) => _$PianoBlockFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PianoBlockToJson(this);
}
