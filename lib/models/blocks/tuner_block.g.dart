// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tuner_block.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TunerBlock _$TunerBlockFromJson(Map<String, dynamic> json) => TunerBlock(
  json['title'] as String? ?? 'Tuner',
  json['id'] as String? ?? '',
  json['islandToolID'] as String?,
  (json['chamberNoteHz'] as num?)?.toDouble() ?? 440.0,
  json['timeLastModified'] == null ? getCurrentDateTime() : DateTime.parse(json['timeLastModified'] as String),
);

Map<String, dynamic> _$TunerBlockToJson(TunerBlock instance) => <String, dynamic>{
  'kind': instance.kind,
  'title': instance.title,
  'timeLastModified': instance.timeLastModified.toIso8601String(),
  'id': instance.id,
  'islandToolID': instance.islandToolID,
  'chamberNoteHz': instance.chamberNoteHz,
};
