import 'package:equatable/equatable.dart';

class AyahNoteEntity extends Equatable {
  final String id;
  final int surahNumber;
  final String surahName;
  final int numberInSurah;
  final int ayahNumber;
  final String ayahText;
  final int page;
  final String noteText;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const AyahNoteEntity({
    required this.id,
    required this.surahNumber,
    required this.surahName,
    required this.numberInSurah,
    required this.ayahNumber,
    required this.ayahText,
    required this.page,
    required this.noteText,
    required this.createdAt,
    this.updatedAt,
  });

  AyahNoteEntity copyWith({
    String? id,
    int? surahNumber,
    String? surahName,
    int? numberInSurah,
    int? ayahNumber,
    String? ayahText,
    int? page,
    String? noteText,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AyahNoteEntity(
      id: id ?? this.id,
      surahNumber: surahNumber ?? this.surahNumber,
      surahName: surahName ?? this.surahName,
      numberInSurah: numberInSurah ?? this.numberInSurah,
      ayahNumber: ayahNumber ?? this.ayahNumber,
      ayahText: ayahText ?? this.ayahText,
      page: page ?? this.page,
      noteText: noteText ?? this.noteText,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'surahNumber': surahNumber,
      'surahName': surahName,
      'numberInSurah': numberInSurah,
      'ayahNumber': ayahNumber,
      'ayahText': ayahText,
      'page': page,
      'noteText': noteText,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory AyahNoteEntity.fromJson(Map<String, dynamic> json) {
    return AyahNoteEntity(
      id: json['id'] as String? ?? '',
      surahNumber: json['surahNumber'] as int? ?? 1,
      surahName: json['surahName'] as String? ?? '',
      numberInSurah: json['numberInSurah'] as int? ?? 1,
      ayahNumber: json['ayahNumber'] as int? ?? 1,
      ayahText: json['ayahText'] as String? ?? '',
      page: json['page'] as int? ?? 1,
      noteText: json['noteText'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [
        id,
        surahNumber,
        surahName,
        numberInSurah,
        ayahNumber,
        ayahText,
        page,
        noteText,
        createdAt,
        updatedAt,
      ];
}
