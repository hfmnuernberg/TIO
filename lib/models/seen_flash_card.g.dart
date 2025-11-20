// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seen_flash_card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SeenFlashCard _$SeenFlashCardFromJson(Map<String, dynamic> json) =>
    SeenFlashCard(id: json['id'] as String, seenAt: DateTime.parse(json['seenAt'] as String));

Map<String, dynamic> _$SeenFlashCardToJson(SeenFlashCard instance) => <String, dynamic>{
  'id': instance.id,
  'seenAt': instance.seenAt.toIso8601String(),
};
