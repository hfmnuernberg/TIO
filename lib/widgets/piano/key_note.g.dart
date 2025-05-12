// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'key_note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KeyNote _$KeyNoteFromJson(Map<String, dynamic> json) =>
    KeyNote(note: (json['note'] as num).toInt(), name: json['name'] as String, isNatural: json['isNatural'] as bool);

Map<String, dynamic> _$KeyNoteToJson(KeyNote instance) => <String, dynamic>{
  'note': instance.note,
  'name': instance.name,
  'isNatural': instance.isNatural,
};
