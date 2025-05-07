// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Note _$NoteFromJson(Map<String, dynamic> json) => Note(
  note: (json['note'] as num).toInt(),
  name: json['name'] as String,
  isNatural: json['isNatural'] as bool,
  isPlayed: json['isPlayed'] as bool,
);

Map<String, dynamic> _$NoteToJson(Note instance) => <String, dynamic>{
  'note': instance.note,
  'name': instance.name,
  'isNatural': instance.isNatural,
  'isPlayed': instance.isPlayed,
};
