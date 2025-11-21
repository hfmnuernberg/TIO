import 'package:json_annotation/json_annotation.dart';

part 'suggested_flash_card.g.dart';

@JsonSerializable()
class SuggestedFlashCard {
  final String id;
  final DateTime suggestedAt;

  SuggestedFlashCard({required this.id, required this.suggestedAt});

  factory SuggestedFlashCard.fromJson(Map<String, dynamic> json) => _$SuggestedFlashCardFromJson(json);

  Map<String, dynamic> toJson() => _$SuggestedFlashCardToJson(this);
}
