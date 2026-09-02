import 'package:equatable/equatable.dart';

class HadithEntity extends Equatable {
  final int id;
  final String title;
  final String narrator;
  final String hadithText;
  final String reference;
  final String explanation;
  final List<String> benefits;

  const HadithEntity({
    required this.id,
    required this.title,
    required this.narrator,
    required this.hadithText,
    required this.reference,
    required this.explanation,
    required this.benefits,
  });

  factory HadithEntity.fromJson(Map<String, dynamic> json) {
    return HadithEntity(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      narrator: json['narrator'] as String? ?? '',
      hadithText: json['hadith_text'] as String? ?? '',
      reference: json['reference'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
      benefits: (json['benefits'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'narrator': narrator,
      'hadith_text': hadithText,
      'reference': reference,
      'explanation': explanation,
      'benefits': benefits,
    };
  }

  @override
  List<Object?> get props => [
        id,
        title,
        narrator,
        hadithText,
        reference,
        explanation,
        benefits,
      ];
}
