// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rhythm_group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RhythmGroup _$RhythmGroupFromJson(Map<String, dynamic> json) => RhythmGroup(
  json['keyID'] as String? ?? '',
  json['beats'] == null ? [] : RhythmGroup._beatsFromJson(json['beats'] as List?),
  json['polyBeats'] == null ? [] : RhythmGroup._polyBeatsFromJson(json['polyBeats'] as List?),
  json['noteKey'] as String? ?? 'e4',
);

Map<String, dynamic> _$RhythmGroupToJson(RhythmGroup instance) => <String, dynamic>{
  'keyID': instance.keyID,
  'beats': RhythmGroup._beatsToJson(instance.beats),
  'polyBeats': RhythmGroup._polyBeatsToJson(instance.polyBeats),
  'noteKey': instance.noteKey,
};
