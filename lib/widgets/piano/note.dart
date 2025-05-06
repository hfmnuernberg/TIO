import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'note.g.dart';

@JsonSerializable()
class Note with EquatableMixin {
  final int note;
  final String name;
  final bool isNatural;
  final bool isPlayed;

  const Note({required this.note, required this.name, required this.isNatural, required this.isPlayed});

  @override
  List<Object?> get props => [note, name, isNatural, isPlayed];

  Map<String, dynamic> toJson() => _$NoteToJson(this);
}
