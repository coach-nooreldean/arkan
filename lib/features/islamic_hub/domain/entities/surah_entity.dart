import 'package:equatable/equatable.dart';

class SurahEntity extends Equatable {
  final int number;
  final String name;
  final String englishName;
  final String englishNameTranslation;
  final int numberOfAyahs;
  final String revelationType;
  final int startPage;
  final int endPage;
  final int juz;

  const SurahEntity({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.numberOfAyahs,
    required this.revelationType,
    required this.startPage,
    required this.endPage,
    required this.juz,
  });

  bool get isMeccan => revelationType.toLowerCase() == 'meccan';

  @override
  List<Object?> get props => [
        number,
        name,
        englishName,
        englishNameTranslation,
        numberOfAyahs,
        revelationType,
        startPage,
        endPage,
        juz,
      ];
}

class JuzEntity extends Equatable {
  final int number;
  final String name;
  final int startPage;
  final String startSurah;
  final int startAyah;

  const JuzEntity({
    required this.number,
    required this.name,
    required this.startPage,
    required this.startSurah,
    required this.startAyah,
  });

  @override
  List<Object?> get props => [number, name, startPage, startSurah, startAyah];
}
