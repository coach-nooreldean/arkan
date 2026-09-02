import 'package:equatable/equatable.dart';

class AyahLineSegment extends Equatable {
  final int line;
  final double leftRatio;
  final double widthRatio;

  const AyahLineSegment({
    required this.line,
    this.leftRatio = 0.0,
    this.widthRatio = 1.0,
  });

  @override
  List<Object?> get props => [line, leftRatio, widthRatio];
}

class AyahEntity extends Equatable {
  final int number;
  final int surahNumber;
  final int numberInSurah;
  final int page;
  final int juz;
  final int hizbQuarter;
  final String text;
  final String? audioUrl;
  final String? tafsirText;
  final String surahName;
  final List<int> lines;
  final List<AyahLineSegment> lineSegments;

  const AyahEntity({
    required this.number,
    this.surahNumber = 1,
    required this.numberInSurah,
    required this.page,
    this.juz = 1,
    this.hizbQuarter = 1,
    required this.text,
    this.audioUrl,
    this.tafsirText,
    this.surahName = '',
    this.lines = const [],
    this.lineSegments = const [],
  });

  @override
  List<Object?> get props => [
        number,
        surahNumber,
        numberInSurah,
        page,
        juz,
        hizbQuarter,
        text,
        audioUrl,
        tafsirText,
        surahName,
        lines,
        lineSegments,
      ];
}
