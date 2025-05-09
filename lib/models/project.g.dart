// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Project _$ProjectFromJson(Map<String, dynamic> json) => Project(
  json['_title'] as String? ?? 'Default Title',
  (json['_blocks'] as List<dynamic>?)?.map((e) => ProjectBlock.fromJson(e as Map<String, dynamic>)).toList() ?? [],
  json['_thumbnailPath'] as String? ?? '',
  DateTime.parse(json['_timeLastModified'] as String),
  (json['_toolCounter'] as Map<String, dynamic>?)?.map((k, e) => MapEntry(k, (e as num).toInt())) ??
      {'image': 0, 'media_player': 0, 'metronome': 0, 'piano': 0, 'text': 0, 'tuner': 0},
);

Map<String, dynamic> _$ProjectToJson(Project instance) => <String, dynamic>{
  '_title': instance._title,
  '_blocks': instance._blocks.map((e) => e.toJson()).toList(),
  '_thumbnailPath': instance._thumbnailPath,
  '_timeLastModified': instance._timeLastModified.toIso8601String(),
  '_toolCounter': instance._toolCounter,
};
