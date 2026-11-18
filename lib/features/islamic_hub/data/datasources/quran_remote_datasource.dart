import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_io/io.dart';
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

  Future<bool> isFullQuranBundleCached();
  Future<void> downloadFullQuranOfflineBundle({
    void Function(double progress, String status)? onProgress,
  });
  Future<String?> getLocalMushafPageFilePath(int pageNumber);
  Future<int> getDownloadedMushafPagesCount();
  Future<void> downloadAllMushafPages({
    required void Function(int completed, int total) onProgress,
    bool Function()? isCancelled,
  });
}

class QuranRemoteDataSourceImpl implements QuranRemoteDataSource {
  final Dio _dio;
  List<SurahEntity>? _cachedSurahs;
  List<JuzEntity>? _cachedJuzs;
  final Map<int, List<AyahEntity>> _cachedPageAyahs = {};
  final Map<int, List<AyahEntity>> _cachedSurahAyahs = {};
  final Map<int, String> _cachedTafsir = {};

  List<AyahEntity>? _offlineAllAyahs;
  final Map<int, List<AyahEntity>> _offlineByPage = {};
  final Map<int, List<AyahEntity>> _offlineBySurah = {};
  Map<int, String>? _offlineTafsirMap;

  QuranRemoteDataSourceImpl({Dio? dio}) : _dio = dio ?? Dio();

  static final RegExp _arabicDiacriticsRegExp = RegExp(
    r'[\u064B-\u065F\u0670\u06D6-\u06ED\u0640]',
  );

  /// Normalizes Arabic text (removes tashkeel/Quranic marks & unifies alef/taa/yaa)
  /// for fast, diacritic-insensitive offline Quran search.
  static String normalizeArabicForSearch(String input) {
    return input
        .replaceAll(_arabicDiacriticsRegExp, '')
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ٱ', 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ة', 'ه')
        .replaceAll('ؤ', 'و')
        .replaceAll('ئ', 'ي')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim()
        .toLowerCase();
  }

  /// Searches a list of [AyahEntity] offline using normalized Arabic matching.
  static List<AyahEntity> searchInAyahList(
    List<AyahEntity> ayahs,
    String query, {
    int maxResults = 60,
  }) {
    final normalizedQuery = normalizeArabicForSearch(query);
    if (normalizedQuery.isEmpty) return const [];

    final matches = <AyahEntity>[];
    for (final ayah in ayahs) {
      if (normalizeArabicForSearch(ayah.text).contains(normalizedQuery)) {
        matches.add(ayah);
        if (matches.length >= maxResults) break;
      }
    }
    return matches;
  }

  Future<Directory?> _getCacheDir() async {
    if (kIsWeb) return null;
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final dir = Directory('${appDir.path}/quran_cache');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      return dir;
    } catch (_) {
      return null;
    }
  }

  Future<Directory?> _getPagesDir() async {
    if (kIsWeb) return null;
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final dir = Directory('${appDir.path}/mushaf_pages');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      return dir;
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeAyahListDiskCache(String fileName, List<AyahEntity> ayahs) async {
    if (ayahs.isEmpty) return;
    final dir = await _getCacheDir();
    if (dir == null) return;
    try {
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(jsonEncode(ayahs.map((a) => a.toJson()).toList()));
    } catch (_) {}
  }

  Future<List<AyahEntity>?> _readAyahListDiskCache(String fileName) async {
    final dir = await _getCacheDir();
    if (dir == null) return null;
    try {
      final file = File('${dir.path}/$fileName');
      if (!await file.exists()) return null;
      final raw = await file.readAsString();
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => AyahEntity.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> _loadOfflineQuranIndex() async {
    if (_offlineAllAyahs != null && _offlineAllAyahs!.isNotEmpty) return;
    final dir = await _getCacheDir();
    if (dir == null) return;
    try {
      final file = File('${dir.path}/full_quran_uthmani.json');
      if (!await file.exists()) return;
      final decoded = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      final list = (decoded['ayahs'] as List<dynamic>? ?? [])
          .map((e) => AyahEntity.fromJson(e as Map<String, dynamic>))
          .toList();
      _indexOfflineAyahs(list);
    } catch (e) {
      AppLogger.warning('Failed to read offline Quran bundle: $e');
    }
  }

  void _indexOfflineAyahs(List<AyahEntity> list) {
    _offlineAllAyahs = list;
    _offlineByPage.clear();
    _offlineBySurah.clear();
    for (final a in list) {
      _offlineByPage.putIfAbsent(a.page, () => []).add(a);
      _offlineBySurah.putIfAbsent(a.surahNumber, () => []).add(a);
    }
  }

  Future<void> _loadOfflineTafsirIndex() async {
    if (_offlineTafsirMap != null && _offlineTafsirMap!.isNotEmpty) return;
    final dir = await _getCacheDir();
    if (dir == null) return;
    try {
      final file = File('${dir.path}/full_tafsir_muyassar.json');
      if (!await file.exists()) return;
      final decoded = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      _offlineTafsirMap = decoded.map(
        (key, value) => MapEntry(int.tryParse(key) ?? 0, value.toString()),
      );
    } catch (e) {
      AppLogger.warning('Failed to read offline Tafsir bundle: $e');
    }
  }

  @override
  Future<bool> isFullQuranBundleCached() async {
    final dir = await _getCacheDir();
    if (dir == null) return false;
    final quranFile = File('${dir.path}/full_quran_uthmani.json');
    final tafsirFile = File('${dir.path}/full_tafsir_muyassar.json');
    return await quranFile.exists() && await tafsirFile.exists();
  }

  @override
  Future<void> downloadFullQuranOfflineBundle({
    void Function(double progress, String status)? onProgress,
  }) async {
    final dir = await _getCacheDir();
    if (dir == null) return;

    onProgress?.call(0.1, 'جاري تحميل نص القرآن الكريم كاملاً...');
    final quranResp = await _dio.get<dynamic>(
      'https://api.alquran.cloud/v1/quran/quran-uthmani',
      options: Options(receiveTimeout: const Duration(seconds: 30)),
    );

    if (quranResp.statusCode == 200 && quranResp.data != null) {
      final data = quranResp.data['data'] as Map<String, dynamic>? ?? {};
      final surahsJson = data['surahs'] as List<dynamic>? ?? [];
      final allAyahs = <AyahEntity>[];

      for (final s in surahsJson) {
        final sMap = s as Map<String, dynamic>;
        final surahNum = sMap['number'] as int? ?? 1;
        final surahName = sMap['name'] as String? ?? '';
        final ayahsJson = sMap['ayahs'] as List<dynamic>? ?? [];
        final surahPadded = surahNum.toString().padLeft(3, '0');

        for (final a in ayahsJson) {
          final aMap = a as Map<String, dynamic>;
          final ayahNum = aMap['number'] as int? ?? 1;
          final numInSurah = aMap['numberInSurah'] as int? ?? 1;
          final ayahPadded = numInSurah.toString().padLeft(3, '0');
          allAyahs.add(
            AyahEntity(
              number: ayahNum,
              surahNumber: surahNum,
              numberInSurah: numInSurah,
              page: aMap['page'] as int? ?? 1,
              juz: aMap['juz'] as int? ?? 1,
              hizbQuarter: aMap['hizbQuarter'] as int? ?? 1,
              text: (aMap['text'] as String? ?? '').trim(),
              surahName: surahName,
              audioUrl:
                  'https://everyayah.com/data/Alafasy_128kbps/$surahPadded$ayahPadded.mp3',
            ),
          );
        }
      }

      if (allAyahs.isNotEmpty) {
        final quranFile = File('${dir.path}/full_quran_uthmani.json');
        await quranFile.writeAsString(
          jsonEncode({'ayahs': allAyahs.map((a) => a.toJson()).toList()}),
        );
        _indexOfflineAyahs(allAyahs);
      }
    }

    onProgress?.call(0.55, 'جاري تحميل التفسير الميسر كاملاً...');
    final tafsirResp = await _dio.get<dynamic>(
      'https://api.alquran.cloud/v1/quran/ar.muyassar',
      options: Options(receiveTimeout: const Duration(seconds: 30)),
    );

    if (tafsirResp.statusCode == 200 && tafsirResp.data != null) {
      final data = tafsirResp.data['data'] as Map<String, dynamic>? ?? {};
      final surahsJson = data['surahs'] as List<dynamic>? ?? [];
      final tafsirMap = <String, String>{};
      final parsedIntMap = <int, String>{};

      for (final s in surahsJson) {
        final sMap = s as Map<String, dynamic>;
        final ayahsJson = sMap['ayahs'] as List<dynamic>? ?? [];
        for (final a in ayahsJson) {
          final aMap = a as Map<String, dynamic>;
          final num = aMap['number'] as int?;
          final text = (aMap['text'] as String? ?? '').trim();
          if (num != null && text.isNotEmpty) {
            tafsirMap[num.toString()] = text;
            parsedIntMap[num] = text;
          }
        }
      }

      if (tafsirMap.isNotEmpty) {
        final tafsirFile = File('${dir.path}/full_tafsir_muyassar.json');
        await tafsirFile.writeAsString(jsonEncode(tafsirMap));
        _offlineTafsirMap = parsedIntMap;
      }
    }

    onProgress?.call(1.0, 'اكتمل تحميل القرآن والتفسير أوفلاين بنجاح');
  }

  @override
  Future<String?> getLocalMushafPageFilePath(int pageNumber) async {
    final dir = await _getPagesDir();
    if (dir == null) return null;
    final padded = pageNumber.toString().padLeft(3, '0');
    final file = File('${dir.path}/page$padded.png');
    if (await file.exists() && await file.length() > 0) {
      return file.path;
    }
    return null;
  }

  @override
  Future<int> getDownloadedMushafPagesCount() async {
    final dir = await _getPagesDir();
    if (dir == null) return 0;
    try {
      int count = 0;
      await for (final entity in dir.list()) {
        if (entity is File && entity.path.endsWith('.png')) {
          if (await entity.length() > 0) count++;
        }
      }
      return count;
    } catch (_) {
      return 0;
    }
  }

  @override
  Future<void> downloadAllMushafPages({
    required void Function(int completed, int total) onProgress,
    bool Function()? isCancelled,
  }) async {
    final dir = await _getPagesDir();
    if (dir == null) return;

    const total = 604;
    int completed = 0;
    const batchSize = 6;

    for (int start = 1; start <= total; start += batchSize) {
      if (isCancelled?.call() == true) break;
      final end = (start + batchSize - 1).clamp(1, total);
      final futures = <Future<void>>[];

      for (int p = start; p <= end; p++) {
        futures.add(() async {
          if (isCancelled?.call() == true) return;
          final padded = p.toString().padLeft(3, '0');
          final file = File('${dir.path}/page$padded.png');
          if (await file.exists() && await file.length() > 0) {
            return;
          }
          final urls = getPageImageAlternativeUrls(p);
          for (final url in urls) {
            if (isCancelled?.call() == true) return;
            try {
              await _dio.download(
                url,
                file.path,
                options: Options(receiveTimeout: const Duration(seconds: 15)),
              );
              if (await file.exists() && await file.length() > 0) {
                return;
              }
            } catch (_) {}
          }
        }());
      }

      await Future.wait(futures);
      completed = end;
      onProgress(completed, total);
    }
  }

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

    // 0. Check persistent per-page disk cache (preserves lineSegments for highlight & long-press)
    final diskCached = await _readAyahListDiskCache('page_$pageNumber.json');
    if (diskCached != null && diskCached.isNotEmpty) {
      _cachedPageAyahs[pageNumber] = diskCached;
      return diskCached;
    }

    // 1. Try fetching rich verse lines data from api.quran.com
    try {
      final quranComUrl = 'https://api.quran.com/api/v4/verses/by_page/$pageNumber?words=true&fields=text_uthmani';
      final response = await _dio.get<dynamic>(quranComUrl, options: Options(receiveTimeout: const Duration(seconds: 8)));

      if (response.statusCode == 200 && response.data != null) {
        final versesJson = response.data['verses'] as List<dynamic>? ?? [];
        if (versesJson.isNotEmpty) {
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
            await _writeAyahListDiskCache('page_$pageNumber.json', list);
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

        final list = ayahsJson.map((item) {
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

        if (list.isNotEmpty) {
          _cachedPageAyahs[pageNumber] = list;
          await _writeAyahListDiskCache('page_$pageNumber.json', list);
          return list;
        }
      }
    } catch (e) {
      AppLogger.warning('Failed to fetch ayahs for page $pageNumber: $e');
    }

    // 3. Offline bundle fallback
    await _loadOfflineQuranIndex();
    final offline = _offlineByPage[pageNumber];
    if (offline != null && offline.isNotEmpty) {
      _cachedPageAyahs[pageNumber] = offline;
      return offline;
    }

    return [];
  }

  @override
  Future<List<AyahEntity>> fetchAyahsForSurah(int surahNumber) async {
    if (_cachedSurahAyahs.containsKey(surahNumber)) {
      return _cachedSurahAyahs[surahNumber]!;
    }

    await _loadOfflineQuranIndex();
    final offline = _offlineBySurah[surahNumber];
    if (offline != null && offline.isNotEmpty) {
      _cachedSurahAyahs[surahNumber] = offline;
      return offline;
    }

    final diskCached = await _readAyahListDiskCache('surah_$surahNumber.json');
    if (diskCached != null && diskCached.isNotEmpty) {
      _cachedSurahAyahs[surahNumber] = diskCached;
      return diskCached;
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
        await _writeAyahListDiskCache('surah_$surahNumber.json', list);
        return list;
      }
    } catch (e) {
      AppLogger.warning('Failed to fetch ayahs for surah $surahNumber: $e');
    }
    return [];
  }

  @override
  Future<String> fetchAyahTafsir(int ayahNumber) async {
    if (_cachedTafsir.containsKey(ayahNumber)) {
      return _cachedTafsir[ayahNumber]!;
    }

    await _loadOfflineTafsirIndex();
    final offlineText = _offlineTafsirMap?[ayahNumber];
    if (offlineText != null && offlineText.isNotEmpty) {
      _cachedTafsir[ayahNumber] = offlineText;
      return offlineText;
    }

    final dir = await _getCacheDir();
    if (dir != null) {
      try {
        final file = File('${dir.path}/tafsir_$ayahNumber.txt');
        if (await file.exists()) {
          final cached = await file.readAsString();
          if (cached.isNotEmpty) {
            _cachedTafsir[ayahNumber] = cached;
            return cached;
          }
        }
      } catch (_) {}
    }

    try {
      final url = 'https://api.alquran.cloud/v1/ayah/$ayahNumber/ar.muyassar';
      final response = await _dio.get<dynamic>(url, options: Options(receiveTimeout: const Duration(seconds: 8)));

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'] as Map<String, dynamic>? ?? {};
        final text = data['text'] as String? ?? '';
        if (text.isNotEmpty) {
          _cachedTafsir[ayahNumber] = text;
          if (dir != null) {
            try {
              await File('${dir.path}/tafsir_$ayahNumber.txt').writeAsString(text);
            } catch (_) {}
          }
          return text;
        }
      }
    } catch (e) {
      AppLogger.warning('Failed to fetch tafsir for ayah $ayahNumber: $e');
    }
    return 'التفسير الميسر غير متوفر حالياً بدون اتصال بالإنترنت. يمكنك تحميل التفسير أوفلاين من قائمة المصحف.';
  }

  @override
  Future<List<AyahEntity>> searchQuran(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return [];

    // 1. Offline local search (if full bundle is downloaded)
    await _loadOfflineQuranIndex();
    if (_offlineAllAyahs != null && _offlineAllAyahs!.isNotEmpty) {
      return searchInAyahList(_offlineAllAyahs!, cleanQuery);
    }

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

    // 2. Fallback: search whatever pages/surahs have been cached in memory
    final cachedPool = <AyahEntity>[
      for (final list in _cachedPageAyahs.values) ...list,
      for (final list in _cachedSurahAyahs.values) ...list,
    ];
    if (cachedPool.isNotEmpty) {
      return searchInAyahList(cachedPool, cleanQuery);
    }

    return [];
  }
}
