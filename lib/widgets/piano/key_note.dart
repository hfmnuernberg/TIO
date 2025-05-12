import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'key_note.g.dart';

@JsonSerializable()
class KeyNote with EquatableMixin {
  final int note;
  final String name;
  final bool isNatural;

  const KeyNote({required this.note, required this.name, required this.isNatural});

  @override
  List<Object?> get props => [note, name, isNatural];

  Map<String, dynamic> toJson() => _$KeyNoteToJson(this);
}
