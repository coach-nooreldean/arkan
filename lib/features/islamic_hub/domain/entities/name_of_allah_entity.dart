import 'package:equatable/equatable.dart';

class NameOfAllahEntity extends Equatable {
  final int id;
  final String name;
  final String transliteration;
  final String meaning;
  final String reference;
  final String benefit;

  const NameOfAllahEntity({
    required this.id,
    required this.name,
    required this.transliteration,
    required this.meaning,
    required this.reference,
    required this.benefit,
  });

  factory NameOfAllahEntity.fromJson(Map<String, dynamic> json) {
    return NameOfAllahEntity(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      transliteration: json['transliteration'] as String? ?? '',
      meaning: json['meaning'] as String? ?? '',
      reference: json['reference'] as String? ?? '',
      benefit: json['benefit'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'transliteration': transliteration,
      'meaning': meaning,
      'reference': reference,
      'benefit': benefit,
    };
  }

  @override
  List<Object?> get props => [id, name, transliteration, meaning, reference, benefit];
}
