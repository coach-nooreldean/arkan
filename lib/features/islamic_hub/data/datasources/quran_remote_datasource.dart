import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/surah_entity.dart';
import '../../domain/entities/ayah_entity.dart';

abstract class QuranRemoteDataSource {
  Future<List<SurahEntity>> getSurahs();
  Future<List<JuzEntity>> getJuzs();
  String getPageImageUrl(int pageNumber);
  List<String> getPageImageAlternativeUrls(int pageNumber);
  Future<List<AyahEntity>> fetchAyahsForPage(int pageNumber);
  Future<List<AyahEntity>> fetchAyahsForSurah(int surahNumber);
  Future<String> fetchAyahTafsir(int ayahNumber);
  Future<List<AyahEntity>> searchQuran(String query);
}

class QuranRemoteDataSourceImpl implements QuranRemoteDataSource {
  final Dio _dio;
  List<SurahEntity>? _cachedSurahs;
  List<JuzEntity>? _cachedJuzs;
  final Map<int, List<AyahEntity>> _cachedSurahAyahs = {};
  final Map<int, List<AyahEntity>> _cachedPageAyahs = {};

  QuranRemoteDataSourceImpl({Dio? dio}) : _dio = dio ?? Dio();

  @override
  Future<List<SurahEntity>> getSurahs() async {
    if (_cachedSurahs != null && _cachedSurahs!.isNotEmpty) {
      return _cachedSurahs!;
    }

    try {
      final jsonString = await rootBundle.loadString('assets/data/quran_metadata.json');
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      final list = data['surahs'] as List<dynamic>? ?? [];

      _cachedSurahs = list.map((item) {
        final map = item as Map<String, dynamic>;
        return SurahEntity(
          number: map['number'] as int,
          name: map['name'] as String,
          englishName: map['englishName'] as String,
          englishNameTranslation: map['englishNameTranslation'] as String,
          numberOfAyahs: map['numberOfAyahs'] as int,
          revelationType: map['revelationType'] as String,
          startPage: map['startPage'] as int,
          endPage: map['endPage'] as int,
          juz: map['juz'] as int,
        );
      }).toList();

      return _cachedSurahs!;
    } catch (e) {
      AppLogger.error('Failed to load Quran surahs metadata: $e');
      return [];
    }
  }

  @override
  Future<List<JuzEntity>> getJuzs() async {
    if (_cachedJuzs != null && _cachedJuzs!.isNotEmpty) {
      return _cachedJuzs!;
    }

    try {
      final jsonString = await rootBundle.loadString('assets/data/quran_metadata.json');
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      final list = data['juzs'] as List<dynamic>? ?? [];

      _cachedJuzs = list.map((item) {
        final map = item as Map<String, dynamic>;
        return JuzEntity(
          number: map['number'] as int,
          name: map['name'] as String,
          startPage: map['startPage'] as int,
          startSurah: map['startSurah'] as String,
          startAyah: map['startAyah'] as int,
        );
      }).toList();

      return _cachedJuzs!;
    } catch (e) {
      AppLogger.error('Failed to load Quran juzs metadata: $e');
      return [];
    }
  }

  @override
  String getPageImageUrl(int pageNumber) {
    final padded = pageNumber.toString().padLeft(3, '0');
    if (kIsWeb) {
      return 'https://wsrv.nl/?url=files.quran.app/hafs/madani/width_1260/page$padded.png';
    }
    // High-res authentic Madani Mushaf page (1260x2038, optimal 1:1.62 aspect ratio for mobile screens)
    return 'https://files.quran.app/hafs/madani/width_1260/page$padded.png';
  }

  @override
  List<String> getPageImageAlternativeUrls(int pageNumber) {
    final padded = pageNumber.toString().padLeft(3, '0');
    if (kIsWeb) {
      return [
        'https://wsrv.nl/?url=files.quran.app/hafs/madani/width_1260/page$padded.png',
        'https://images.weserv.nl/?url=files.quran.app/hafs/madani/width_1260/page$padded.png',
        'https://wsrv.nl/?url=files.quran.app/hafs/madani/width_1024/page$padded.png',
        'https://images.weserv.nl/?url=quran.ksu.edu.sa/ayat/safahat1/$pageNumber.png',
      ];
    }
    return [
      'https://files.quran.app/hafs/madani/width_1260/page$padded.png',
      'https://files.quran.app/hafs/madani/width_1024/page$padded.png',
      'https://quran.ksu.edu.sa/ayat/safahat1/$pageNumber.png',
      'https://android.quran.com/data/width_1024/page$padded.png',
    ];
  }

  @override
  Future<List<AyahEntity>> fetchAyahsForPage(int pageNumber) async {
    if (_cachedPageAyahs.containsKey(pageNumber) && _cachedPageAyahs[pageNumber]!.isNotEmpty) {
      return _cachedPageAyahs[pageNumber]!;
    }

    // 1. Try fetching rich verse lines data from api.quran.com
    try {
      final quranComUrl = 'https://api.quran.com/api/v4/verses/by_page/$pageNumber?words=true&fields=text_uthmani';
      final response = await _dio.get<dynamic>(quranComUrl, options: Options(receiveTimeout: const Duration(seconds: 8)));

      if (response.statusCode == 200 && response.data != null) {
        final versesJson = response.data['verses'] as List<dynamic>? ?? [];
        if (versesJson.isNotEmpty) {
          // 1. Calculate total words per line on this page
          final lineTotalWords = <int, int>{};
          for (final v in versesJson) {
            if (v is Map<String, dynamic>) {
              final words = v['words'] as List<dynamic>? ?? [];
              for (final w in words) {
                if (w is Map<String, dynamic>) {
                  final ln = w['line_number'] as int?;
                  if (ln != null) {
                    lineTotalWords[ln] = (lineTotalWords[ln] ?? 0) + 1;
                  }
                }
              }
            }
          }

          // 2. Track current word offset per line as we iterate in order
          final lineCurrentWord = <int, int>{};

          final list = versesJson.map((item) {
            final m = item as Map<String, dynamic>;
            final verseKey = m['verse_key'] as String? ?? '1:1';
            final parts = verseKey.split(':');
            final surahNum = int.tryParse(parts[0]) ?? 1;
            final numInSurah = int.tryParse(parts.length > 1 ? parts[1] : '1') ?? 1;
            final ayahNum = m['id'] as int? ?? numInSurah;
            final surahPadded = surahNum.toString().padLeft(3, '0');
            final ayahPadded = numInSurah.toString().padLeft(3, '0');

            final words = m['words'] as List<dynamic>? ?? [];
            final linesSet = <int>{};
            final lineWordsCount = <int, int>{};

            for (final w in words) {
              if (w is Map<String, dynamic>) {
                final lineNum = w['line_number'] as int?;
                if (lineNum != null) {
                  linesSet.add(lineNum);
                  lineWordsCount[lineNum] = (lineWordsCount[lineNum] ?? 0) + 1;
                }
              }
            }

            final sortedLines = linesSet.toList()..sort();
            final segments = <AyahLineSegment>[];

            for (final ln in sortedLines) {
              final total = lineTotalWords[ln] ?? 1;
              final count = lineWordsCount[ln] ?? 1;
              final startIdx = lineCurrentWord[ln] ?? 0;
              final endIdx = startIdx + count - 1;
              lineCurrentWord[ln] = startIdx + count;

              if (count >= total) {
                segments.add(AyahLineSegment(line: ln, leftRatio: 0, widthRatio: 1));
              } else {
                // In Arabic / RTL:
                // Word 0 is at right edge, word (total-1) is at left edge
                final leftRatio = (total - 1 - endIdx) / total;
                final widthRatio = count / total;
                segments.add(AyahLineSegment(
                  line: ln,
                  leftRatio: leftRatio.clamp(0.0, 1.0),
                  widthRatio: widthRatio.clamp(0.0, 1.0),
                ));
              }
            }

            final ayahText = (m['text_uthmani'] as String? ?? '').trim();

            return AyahEntity(
              number: ayahNum,
              surahNumber: surahNum,
              numberInSurah: numInSurah,
              page: pageNumber,
              juz: m['juz_number'] as int? ?? 1,
              hizbQuarter: m['hizb_number'] as int? ?? 1,
              text: ayahText,
              surahName: '',
              lines: sortedLines,
              lineSegments: segments,
              audioUrl: 'https://everyayah.com/data/Alafasy_128kbps/$surahPadded$ayahPadded.mp3',
            );
          }).toList();

          if (list.isNotEmpty && list.every((a) => a.text.isNotEmpty)) {
            _cachedPageAyahs[pageNumber] = list;
            return list;
          }
        }
      }
    } catch (e) {
      AppLogger.warning('Quran.com page lines fetch failed, falling back: $e');
    }

    // 2. Fallback to alquran.cloud
    try {
      final url = 'https://api.alquran.cloud/v1/page/$pageNumber/quran-uthmani';
      final response = await _dio.get<dynamic>(url, options: Options(receiveTimeout: const Duration(seconds: 8)));

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'] as Map<String, dynamic>? ?? {};
        final ayahsJson = data['ayahs'] as List<dynamic>? ?? [];

        return ayahsJson.map((item) {
          final m = item as Map<String, dynamic>;
          final surahObj = m['surah'] as Map<String, dynamic>? ?? {};
          final ayahNum = m['number'] as int? ?? 1;
          final surahNum = surahObj['number'] as int? ?? 1;
          final numInSurah = m['numberInSurah'] as int? ?? 1;
          final surahPadded = surahNum.toString().padLeft(3, '0');
          final ayahPadded = numInSurah.toString().padLeft(3, '0');

          return AyahEntity(
            number: ayahNum,
            surahNumber: surahNum,
            numberInSurah: numInSurah,
            page: m['page'] as int? ?? pageNumber,
            juz: m['juz'] as int? ?? 1,
            hizbQuarter: m['hizbQuarter'] as int? ?? 1,
            text: m['text'] as String? ?? '',
            surahName: surahObj['name'] as String? ?? '',
            lines: const [],
            audioUrl: 'https://everyayah.com/data/Alafasy_128kbps/$surahPadded$ayahPadded.mp3',
          );
        }).toList();
      }
    } catch (e) {
      AppLogger.warning('Failed to fetch ayahs for page $pageNumber: $e');
    }
    return [];
  }

  @override
  Future<List<AyahEntity>> fetchAyahsForSurah(int surahNumber) async {
    if (_cachedSurahAyahs.containsKey(surahNumber)) {
      return _cachedSurahAyahs[surahNumber]!;
    }

    try {
      final url = 'https://api.alquran.cloud/v1/surah/$surahNumber/quran-uthmani';
      final response = await _dio.get<dynamic>(url, options: Options(receiveTimeout: const Duration(seconds: 10)));

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'] as Map<String, dynamic>? ?? {};
        final ayahsJson = data['ayahs'] as List<dynamic>? ?? [];
        final surahName = data['name'] as String? ?? '';

        final list = ayahsJson.map((item) {
          final m = item as Map<String, dynamic>;
          final ayahNum = m['number'] as int? ?? 1;
          final numInSurah = m['numberInSurah'] as int? ?? 1;
          final surahPadded = surahNumber.toString().padLeft(3, '0');
          final ayahPadded = numInSurah.toString().padLeft(3, '0');

          return AyahEntity(
            number: ayahNum,
            surahNumber: surahNumber,
            numberInSurah: numInSurah,
            page: m['page'] as int? ?? 1,
            juz: m['juz'] as int? ?? 1,
            hizbQuarter: m['hizbQuarter'] as int? ?? 1,
            text: m['text'] as String? ?? '',
            surahName: surahName,
            audioUrl: 'https://everyayah.com/data/Alafasy_128kbps/$surahPadded$ayahPadded.mp3',
          );
        }).toList();

        _cachedSurahAyahs[surahNumber] = list;
        return list;
      }
    } catch (e) {
      AppLogger.warning('Failed to fetch ayahs for surah $surahNumber: $e');
    }
    return [];
  }

  @override
  Future<String> fetchAyahTafsir(int ayahNumber) async {
    try {
      final url = 'https://api.alquran.cloud/v1/ayah/$ayahNumber/ar.muyassar';
      final response = await _dio.get<dynamic>(url, options: Options(receiveTimeout: const Duration(seconds: 8)));

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'] as Map<String, dynamic>? ?? {};
        return data['text'] as String? ?? '';
      }
    } catch (e) {
      AppLogger.warning('Failed to fetch tafsir for ayah $ayahNumber: $e');
    }
    return 'التفسير الميسر غير متوفر حالياً بدون اتصال بالإنترنت.';
  }

  @override
  Future<List<AyahEntity>> searchQuran(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return [];

    final surahs = await getSurahs();
    final editions = ['quran-simple', 'quran-simple-clean'];

    for (final edition in editions) {
      try {
        final encodedQuery = Uri.encodeComponent(cleanQuery);
        final url = 'https://api.alquran.cloud/v1/search/$encodedQuery/all/$edition';
        final response = await _dio.get<dynamic>(url, options: Options(receiveTimeout: const Duration(seconds: 10)));

        if (response.statusCode == 200 && response.data != null) {
          final data = response.data['data'] as Map<String, dynamic>?;
          final matches = data?['matches'] as List<dynamic>? ?? [];

          if (matches.isNotEmpty) {
            return matches.map((m) {
              final map = m as Map<String, dynamic>;
              final surahMap = map['surah'] as Map<String, dynamic>? ?? {};
              final surahNum = surahMap['number'] as int? ?? 1;
              final surahName = surahMap['name'] as String? ?? '';
              final numInSurah = map['numberInSurah'] as int? ?? 1;
              final ayahNum = map['number'] as int? ?? 1;
              final text = (map['text'] as String? ?? '').replaceAll('\n', '').trim();

              final localSurah = surahs.where((s) => s.number == surahNum).firstOrNull;
              final approxPage = localSurah != null
                  ? (localSurah.startPage +
                          ((numInSurah - 1) / (localSurah.numberOfAyahs > 0 ? localSurah.numberOfAyahs : 1) *
                                  (localSurah.endPage - localSurah.startPage))
                              .floor())
                      .clamp(localSurah.startPage, localSurah.endPage)
                  : 1;

              final surahPadded = surahNum.toString().padLeft(3, '0');
              final ayahPadded = numInSurah.toString().padLeft(3, '0');

              return AyahEntity(
                number: ayahNum,
                surahNumber: surahNum,
                numberInSurah: numInSurah,
                page: map['page'] as int? ?? approxPage,
                juz: localSurah?.juz ?? 1,
                hizbQuarter: 1,
                text: text,
                surahName: localSurah != null ? 'سورة ${localSurah.name}' : surahName,
                audioUrl: 'https://everyayah.com/data/Alafasy_128kbps/$surahPadded$ayahPadded.mp3',
              );
            }).toList();
          }
        }
      } catch (e) {
        AppLogger.warning('Quran search error on $edition: $e');
      }
    }

    return [];
  }
}
