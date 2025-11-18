// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'text_block.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TextBlock _$TextBlockFromJson(Map<String, dynamic> json) => TextBlock(
  json['title'] as String? ?? 'Text',
  json['id'] as String? ?? '',
  json['islandToolID'] as String?,
  json['content'] as String? ?? '',
  json['timeLastModified'] == null
      ? getCurrentDateTime()
      : DateTime.parse(json['timeLastModified'] as String),
);

Map<String, dynamic> _$TextBlockToJson(TextBlock instance) => <String, dynamic>{
  'kind': instance.kind,
  'title': instance.title,
  'timeLastModified': instance.timeLastModified.toIso8601String(),
  'id': instance.id,
  'islandToolID': instance.islandToolID,
  'content': instance.content,
};
