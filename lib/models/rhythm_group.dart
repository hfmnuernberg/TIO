import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tiomusic/models/note_handler.dart';
import 'package:tiomusic/src/rust/api/modules/metronome_rhythm.dart';
import 'package:tiomusic/util/constants.dart';

part 'rhythm_group.g.dart';

@JsonSerializable()
class RhythmGroup extends Equatable {
  @override
  List<Object> get props => [beats, polyBeats, beatLen];

  @JsonKey(defaultValue: MetronomeParams.defaultId)
  late String keyID;

  @JsonKey(defaultValue: [])
  late List<BeatType> beats;

  @JsonKey(defaultValue: [])
  late List<BeatTypePoly> polyBeats;

  @JsonKey(defaultValue: MetronomeParams.defaultNoteKey)
  late String noteKey;

  @JsonKey(includeToJson: false, includeFromJson: false)
  late double beatLen;

  RhythmGroup(
    this.keyID,
    this.beats,
    this.polyBeats,
    this.noteKey,
  ) {
    if (keyID == "") {
      keyID = MetronomeParams.getNewKeyID();
    }
    beatLen = NoteHandler.getBeatLength(noteKey);

    // this is because we cannot use the default values in @JsonKey(defaultValue: ), it wants a literal
    if (beats.isEmpty) {
      beats = MetronomeParams.defaultBeats;
    }
    if (polyBeats.isEmpty) {
      polyBeats = MetronomeParams.defaultPolyBeats;
    }

    // we need to do list.from with growable true to avoid the unmodifiable list error
    beats = List<BeatType>.from(beats, growable: true);
    polyBeats = List<BeatTypePoly>.from(polyBeats, growable: true);
  }

  factory RhythmGroup.fromJson(Map<String, dynamic> json) => _$RhythmGroupFromJson(json);

  Map<String, dynamic> toJson() => _$RhythmGroupToJson(this);
}
