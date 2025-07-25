// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_player_block.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MediaPlayerBlock _$MediaPlayerBlockFromJson(Map<String, dynamic> json) => MediaPlayerBlock(
  json['title'] as String? ?? 'Media Player',
  json['id'] as String? ?? '',
  json['islandToolID'] as String?,
  (json['bpm'] as num?)?.toInt() ?? 80,
  (json['volume'] as num?)?.toDouble() ?? 0.5,
  (json['pitchSemitones'] as num?)?.toDouble() ?? 0.0,
  (json['speedFactor'] as num?)?.toDouble() ?? 1.0,
  json['relativePath'] as String? ?? '',
  (json['rangeStart'] as num?)?.toDouble() ?? 0.0,
  (json['rangeEnd'] as num?)?.toDouble() ?? 1.0,
  json['looping'] as bool? ?? false,
  json['loopingAll'] as bool? ?? false,
  json['timeLastModified'] == null ? getCurrentDateTime() : DateTime.parse(json['timeLastModified'] as String),
  (json['markerPositions'] as List<dynamic>?)?.map((e) => (e as num).toDouble()).toList() ?? [],
);

Map<String, dynamic> _$MediaPlayerBlockToJson(MediaPlayerBlock instance) => <String, dynamic>{
  'kind': instance.kind,
  'title': instance.title,
  'timeLastModified': instance.timeLastModified.toIso8601String(),
  'id': instance.id,
  'islandToolID': instance.islandToolID,
  'volume': instance.volume,
  'bpm': instance.bpm,
  'pitchSemitones': instance.pitchSemitones,
  'speedFactor': instance.speedFactor,
  'rangeStart': instance.rangeStart,
  'rangeEnd': instance.rangeEnd,
  'looping': instance.looping,
  'loopingAll': instance.loopingAll,
  'relativePath': instance.relativePath,
  'markerPositions': instance.markerPositions,
};
