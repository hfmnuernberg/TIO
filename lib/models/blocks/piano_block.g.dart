// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'piano_block.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PianoBlock _$PianoBlockFromJson(Map<String, dynamic> json) => PianoBlock(
      json['title'] as String? ?? 'Piano',
      json['id'] as String? ?? '',
      json['islandToolID'] as String?,
      (json['volume'] as num?)?.toDouble() ?? 0.5,
      (json['keyboardPosition'] as num?)?.toInt() ?? 60,
      (json['soundFontIndex'] as num?)?.toInt() ?? 0,
      json['timeLastModified'] == null ? getCurrentDateTime() : DateTime.parse(json['timeLastModified'] as String),
    );

Map<String, dynamic> _$PianoBlockToJson(PianoBlock instance) => <String, dynamic>{
      'kind': instance.kind,
      'title': instance.title,
      'timeLastModified': instance.timeLastModified.toIso8601String(),
      'id': instance.id,
      'islandToolID': instance.islandToolID,
      'volume': instance.volume,
      'keyboardPosition': instance.keyboardPosition,
      'soundFontIndex': instance.soundFontIndex,
    };
