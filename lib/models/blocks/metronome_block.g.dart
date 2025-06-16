// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metronome_block.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MetronomeBlock _$MetronomeBlockFromJson(Map<String, dynamic> json) => MetronomeBlock(
  json['title'] as String? ?? 'Metronome',
  json['id'] as String? ?? '',
  json['islandToolID'] as String?,
  (json['bpm'] as num?)?.toInt() ?? 80,
  (json['randomMute'] as num?)?.toInt() ?? 0,
  (json['rhythmGroups'] as List<dynamic>?)?.map((e) => RhythmGroup.fromJson(e as Map<String, dynamic>)).toList() ?? [],
  (json['rhythmGroups2'] as List<dynamic>?)?.map((e) => RhythmGroup.fromJson(e as Map<String, dynamic>)).toList() ?? [],
  json['accSound'] as String? ?? 'click',
  json['unaccSound'] as String? ?? 'click',
  json['polyAccSound'] as String? ?? 'click',
  json['polyUnaccSound'] as String? ?? 'click',
  json['accSound2'] as String? ?? 'clock',
  json['unaccSound2'] as String? ?? 'clock',
  json['polyAccSound2'] as String? ?? 'cowbell',
  json['polyUnaccSound2'] as String? ?? 'cowbell',
  json['timeLastModified'] == null ? getCurrentDateTime() : DateTime.parse(json['timeLastModified'] as String),
  (json['volume'] as num?)?.toDouble() ?? 0.5,
);

Map<String, dynamic> _$MetronomeBlockToJson(MetronomeBlock instance) => <String, dynamic>{
  'kind': instance.kind,
  'title': instance.title,
  'timeLastModified': instance.timeLastModified.toIso8601String(),
  'id': instance.id,
  'islandToolID': instance.islandToolID,
  'volume': instance.volume,
  'bpm': instance.bpm,
  'randomMute': instance.randomMute,
  'accSound': instance.accSound,
  'unaccSound': instance.unaccSound,
  'polyAccSound': instance.polyAccSound,
  'polyUnaccSound': instance.polyUnaccSound,
  'accSound2': instance.accSound2,
  'unaccSound2': instance.unaccSound2,
  'polyAccSound2': instance.polyAccSound2,
  'polyUnaccSound2': instance.polyUnaccSound2,
  'rhythmGroups': instance.rhythmGroups,
  'rhythmGroups2': instance.rhythmGroups2,
};
