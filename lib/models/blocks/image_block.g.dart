// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_block.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImageBlock _$ImageBlockFromJson(Map<String, dynamic> json) => ImageBlock(
  json['title'] as String? ?? 'Image',
  json['id'] as String? ?? '',
  json['islandToolID'] as String?,
  json['relativePath'] as String? ?? '',
  json['timeLastModified'] == null ? getCurrentDateTime() : DateTime.parse(json['timeLastModified'] as String),
);

Map<String, dynamic> _$ImageBlockToJson(ImageBlock instance) => <String, dynamic>{
  'kind': instance.kind,
  'title': instance.title,
  'timeLastModified': instance.timeLastModified.toIso8601String(),
  'relativePath': instance.relativePath,
  'id': instance.id,
  'islandToolID': instance.islandToolID,
};
