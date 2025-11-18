// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Project _$ProjectFromJson(Map<String, dynamic> json) => Project(
  json['title'] as String? ?? 'Default Title',
  (json['_blocks'] as List<dynamic>?)
          ?.map((e) => ProjectBlock.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  json['thumbnailPath'] as String? ?? '',
  DateTime.parse(json['timeLastModified'] as String),
  (json['toolCounter'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      {
        'image': 0,
        'media_player': 0,
        'metronome': 0,
        'piano': 0,
        'text': 0,
        'tuner': 0,
      },
).._mediaPlayerRepeatAll = json['_mediaPlayerRepeatAll'] as bool? ?? false;

Map<String, dynamic> _$ProjectToJson(Project instance) => <String, dynamic>{
  'title': instance._title,
  '_blocks': instance._blocks.map((e) => e.toJson()).toList(),
  'thumbnailPath': instance._thumbnailPath,
  '_mediaPlayerRepeatAll': instance._mediaPlayerRepeatAll,
  'timeLastModified': instance._timeLastModified.toIso8601String(),
  'toolCounter': instance._toolCounter,
};
