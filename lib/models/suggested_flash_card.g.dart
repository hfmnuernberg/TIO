// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'suggested_flash_card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SuggestedFlashCard _$SuggestedFlashCardFromJson(Map<String, dynamic> json) =>
    SuggestedFlashCard(id: json['id'] as String, suggestedAt: DateTime.parse(json['suggestedAt'] as String));

Map<String, dynamic> _$SuggestedFlashCardToJson(SuggestedFlashCard instance) => <String, dynamic>{
  'id': instance.id,
  'suggestedAt': instance.suggestedAt.toIso8601String(),
};
