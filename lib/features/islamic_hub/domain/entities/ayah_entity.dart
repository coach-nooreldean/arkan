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

  Map<String, dynamic> toJson() => {
        'line': line,
        'leftRatio': leftRatio,
        'widthRatio': widthRatio,
      };

  factory AyahLineSegment.fromJson(Map<String, dynamic> json) {
    return AyahLineSegment(
      line: (json['line'] as num?)?.toInt() ?? 1,
      leftRatio: (json['leftRatio'] as num?)?.toDouble() ?? 0.0,
      widthRatio: (json['widthRatio'] as num?)?.toDouble() ?? 1.0,
    );
  }

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

  Map<String, dynamic> toJson() => {
        'number': number,
        'surahNumber': surahNumber,
        'numberInSurah': numberInSurah,
        'page': page,
        'juz': juz,
        'hizbQuarter': hizbQuarter,
        'text': text,
        'audioUrl': audioUrl,
        'tafsirText': tafsirText,
        'surahName': surahName,
        'lines': lines,
        'lineSegments': lineSegments.map((s) => s.toJson()).toList(),
      };

  factory AyahEntity.fromJson(Map<String, dynamic> json) {
    return AyahEntity(
      number: (json['number'] as num?)?.toInt() ?? 1,
      surahNumber: (json['surahNumber'] as num?)?.toInt() ?? 1,
      numberInSurah: (json['numberInSurah'] as num?)?.toInt() ?? 1,
      page: (json['page'] as num?)?.toInt() ?? 1,
      juz: (json['juz'] as num?)?.toInt() ?? 1,
      hizbQuarter: (json['hizbQuarter'] as num?)?.toInt() ?? 1,
      text: json['text'] as String? ?? '',
      audioUrl: json['audioUrl'] as String?,
      tafsirText: json['tafsirText'] as String?,
      surahName: json['surahName'] as String? ?? '',
      lines: (json['lines'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
      lineSegments: (json['lineSegments'] as List<dynamic>?)
              ?.map((e) => AyahLineSegment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

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
