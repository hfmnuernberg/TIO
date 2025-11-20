import 'package:json_annotation/json_annotation.dart';

part 'seen_flash_card.g.dart';

@JsonSerializable()
class SeenFlashCard {
  final String id;
  final DateTime seenAt;

  SeenFlashCard({required this.id, required this.seenAt});

  factory SeenFlashCard.fromJson(Map<String, dynamic> json) => _$SeenFlashCardFromJson(json);

  Map<String, dynamic> toJson() => _$SeenFlashCardToJson(this);
}
