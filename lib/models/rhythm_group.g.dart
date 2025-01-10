// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rhythm_group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RhythmGroup _$RhythmGroupFromJson(Map<String, dynamic> json) => RhythmGroup(
      json['keyID'] as String? ?? '',
      (json['beats'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$BeatTypeEnumMap, e))
              .toList() ??
          [],
      (json['polyBeats'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$BeatTypePolyEnumMap, e))
              .toList() ??
          [],
      json['noteKey'] as String? ?? 'e4',
    );

Map<String, dynamic> _$RhythmGroupToJson(RhythmGroup instance) =>
    <String, dynamic>{
      'keyID': instance.keyID,
      'beats': instance.beats.map((e) => _$BeatTypeEnumMap[e]!).toList(),
      'polyBeats':
          instance.polyBeats.map((e) => _$BeatTypePolyEnumMap[e]!).toList(),
      'noteKey': instance.noteKey,
    };

const _$BeatTypeEnumMap = {
  BeatType.Accented: 'Accented',
  BeatType.Unaccented: 'Unaccented',
  BeatType.Muted: 'Muted',
};

const _$BeatTypePolyEnumMap = {
  BeatTypePoly.Accented: 'Accented',
  BeatTypePoly.Unaccented: 'Unaccented',
  BeatTypePoly.Muted: 'Muted',
};
