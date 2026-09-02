import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/prayer_time_entity.dart';
import '../../domain/entities/prayer_log_entity.dart';
import '../../domain/entities/surah_entity.dart';
import '../../domain/entities/ayah_entity.dart';
import '../../domain/entities/azkar_category_entity.dart';
import '../../domain/entities/tasbih_item_entity.dart';
import '../../domain/entities/islamic_settings_entity.dart';
import '../../domain/entities/quran_khatmah_entity.dart';
import '../../domain/entities/ayah_note_entity.dart';
import '../../domain/repositories/islamic_hub_repository.dart';
import '../datasources/prayer_remote_datasource.dart';
import '../datasources/quran_remote_datasource.dart';
import '../datasources/azkar_local_datasource.dart';
import '../datasources/islamic_local_datasource.dart';

class IslamicHubRepositoryImpl implements IslamicHubRepository {
  final IslamicLocalDataSource _localDataSource;
  final PrayerRemoteDataSource _prayerRemoteDataSource;
  final QuranRemoteDataSource _quranRemoteDataSource;
  final AzkarLocalDataSource _azkarLocalDataSource;

  IslamicHubRepositoryImpl({
    IslamicLocalDataSource? localDataSource,
    PrayerRemoteDataSource? prayerRemoteDataSource,
    QuranRemoteDataSource? quranRemoteDataSource,
    AzkarLocalDataSource? azkarLocalDataSource,
  })  : _localDataSource = localDataSource ?? IslamicLocalDataSourceImpl(),
        _prayerRemoteDataSource = prayerRemoteDataSource ?? PrayerRemoteDataSourceImpl(),
        _quranRemoteDataSource = quranRemoteDataSource ?? QuranRemoteDataSourceImpl(),
        _azkarLocalDataSource = azkarLocalDataSource ?? AzkarLocalDataSourceImpl();

  @override
  Future<IslamicSettingsEntity> getSettings() => _localDataSource.getSettings();

  @override
  Future<void> saveSettings(IslamicSettingsEntity settings) => _localDataSource.saveSettings(settings);

  @override
  Stream<IslamicSettingsEntity> watchSettings() => _localDataSource.watchSettings();

  @override
  Future<Either<String, DayPrayerTimes>> getPrayerTimes({
    DateTime? date,
    String? city,
    String? country,
    double? latitude,
    double? longitude,
    String? method,
  }) async {
    try {
      final settings = await getSettings();
      final targetCity = city ?? settings.selectedCity;
      final targetCountry = country ?? settings.selectedCountry;
      final targetLat = latitude ?? settings.customLatitude;
      final targetLng = longitude ?? settings.customLongitude;
      final targetMethod = method ?? settings.calculationMethod;

      final times = await _prayerRemoteDataSource.fetchPrayerTimes(
        date: date,
        city: targetCity,
        country: targetCountry,
        latitude: targetLat,
        longitude: targetLng,
        method: targetMethod,
      );

      return right(times);
    } catch (e) {
      AppLogger.error('Failed to get prayer times: $e');
      return left('تعذر تحميل مواقيت الصلاة: $e');
    }
  }

  @override
  Future<Either<String, List<PrayerLogEntity>>> getPrayerLogs(String userId, DateTime date) async {
    try {
      final logs = await _localDataSource.getPrayerLogs(userId, date);
      return right(logs);
    } catch (e) {
      return left('فشل جلب سجل الصلوات: $e');
    }
  }

  @override
  Future<Either<String, PrayerLogEntity>> recordPrayer({
    required String userId,
    required String prayerName,
    required DateTime prayerDate,
    required bool isOnTime,
  }) async {
    try {
      final coins = isOnTime ? 5 : 1;
      final log = await _localDataSource.recordPrayerLog(
        userId: userId,
        prayerName: prayerName,
        prayerDate: prayerDate,
        isOnTime: isOnTime,
        coinsEarned: coins,
      );
      return right(log);
    } catch (e) {
      return left('فشل تسجيل الصلاة: $e');
    }
  }

  @override
  Future<List<SurahEntity>> getAllSurahs() => _quranRemoteDataSource.getSurahs();

  @override
  Future<List<JuzEntity>> getAllJuzs() => _quranRemoteDataSource.getJuzs();

  @override
  Future<SurahEntity?> getSurahByNumber(int number) async {
    final surahs = await getAllSurahs();
    return surahs.where((s) => s.number == number).firstOrNull;
  }

  @override
  String getPageImageUrl(int pageNumber) => _quranRemoteDataSource.getPageImageUrl(pageNumber);

  @override
  List<String> getPageImageAlternativeUrls(int pageNumber) =>
      _quranRemoteDataSource.getPageImageAlternativeUrls(pageNumber);

  @override
  Future<Either<String, List<AyahEntity>>> getAyahsForPage(int pageNumber) async {
    try {
      final ayahs = await _quranRemoteDataSource.fetchAyahsForPage(pageNumber);
      return right(ayahs);
    } catch (e) {
      return left('فشل جلب آيات الصفحة: $e');
    }
  }

  @override
  Future<Either<String, List<AyahEntity>>> getAyahsForSurah(int surahNumber) async {
    try {
      final ayahs = await _quranRemoteDataSource.fetchAyahsForSurah(surahNumber);
      return right(ayahs);
    } catch (e) {
      return left('فشل جلب آيات السورة: $e');
    }
  }

  @override
  Future<Either<String, String>> getAyahTafsir(int ayahNumber) async {
    try {
      final tafsir = await _quranRemoteDataSource.fetchAyahTafsir(ayahNumber);
      return right(tafsir);
    } catch (e) {
      return left('فشل جلب التفسير: $e');
    }
  }

  @override
  Future<List<AzkarCategoryEntity>> getAllAzkarCategories() => _azkarLocalDataSource.loadAzkarCategories();

  @override
  Future<AzkarCategoryEntity?> getAzkarCategoryById(String categoryId) async {
    final list = await getAllAzkarCategories();
    return list.where((c) => c.id == categoryId).firstOrNull;
  }

  @override
  Future<Either<String, int>> claimAzkarReward(String userId, String categoryId) async {
    try {
      final category = await getAzkarCategoryById(categoryId);
      if (category == null) {
        return left('قسم الأذكار غير موجود');
      }

      if (category.isFullyClaimedToday) {
        final msg = category.id == 'after_prayer'
            ? 'لقد استلمت مكافأة أذكار بعد الصلاة 5 مرات اليوم بالفعل'
            : 'لقد استلمت مكافأة هذا الذكر لليوم بالفعل';
        return left(msg);
      }

      final coins = category.rewardCoins;
      final today = DateTime.now();

      // Record claim locally to maintain fresh state
      await _azkarLocalDataSource.recordAzkarClaim(categoryId, today);

      return right(coins);
    } catch (e) {
      return left('فشل صرف مكافأة الأذكار: $e');
    }
  }

  @override
  Future<List<TasbihItemEntity>> getTasbihItems() async {
    final custom = await _localDataSource.getCustomTasbihItems();
    if (custom.isNotEmpty) {
      return custom;
    }
    final defaults = await _azkarLocalDataSource.loadDefaultTasbihPhrases();
    await _localDataSource.saveCustomTasbihItems(defaults);
    return defaults;
  }

  @override
  Future<void> updateTasbihCount(String id, int currentCount, int totalCount) async {
    final items = await getTasbihItems();
    final updated = items.map((item) {
      if (item.id == id) {
        return item.copyWith(
          currentCount: currentCount,
          totalAllTimeCount: totalCount,
        );
      }
      return item;
    }).toList();
    await _localDataSource.saveCustomTasbihItems(updated);
  }

  @override
  Future<void> addCustomTasbih(String text, int target, {String? reward}) async {
    final items = await getTasbihItems();
    final newItem = TasbihItemEntity(
      id: const Uuid().v4(),
      text: text,
      target: target,
      reward: reward,
      currentCount: 0,
      totalAllTimeCount: 0,
    );
    await _localDataSource.saveCustomTasbihItems([...items, newItem]);
  }

  @override
  Future<void> deleteTasbih(String id) async {
    final items = await getTasbihItems();
    final updated = items.where((i) => i.id != id).toList();
    await _localDataSource.saveCustomTasbihItems(updated);
  }

  @override
  Future<List<AyahEntity>> searchQuran(String query) {
    return _quranRemoteDataSource.searchQuran(query);
  }

  @override
  Future<List<QuranKhatmahEntity>> getKhatmahs() {
    return _localDataSource.getKhatmahs();
  }

  @override
  Future<void> saveKhatmah(QuranKhatmahEntity khatmah) async {
    final list = await getKhatmahs();
    final index = list.indexWhere((k) => k.id == khatmah.id);
    if (index >= 0) {
      list[index] = khatmah;
    } else {
      list.insert(0, khatmah);
    }
    await _localDataSource.saveKhatmahs(list);
  }

  @override
  Future<void> deleteKhatmah(String id) async {
    final list = await getKhatmahs();
    final updated = list.where((k) => k.id != id).toList();
    await _localDataSource.saveKhatmahs(updated);
  }

  @override
  Future<List<AyahNoteEntity>> getAyahNotes() {
    return _localDataSource.getAyahNotes();
  }

  @override
  Future<void> saveAyahNote(AyahNoteEntity note) async {
    final list = await getAyahNotes();
    final index = list.indexWhere((n) => n.id == note.id);
    if (index >= 0) {
      list[index] = note;
    } else {
      list.insert(0, note);
    }
    await _localDataSource.saveAyahNotes(list);
  }

  @override
  Future<void> deleteAyahNote(String id) async {
    final list = await getAyahNotes();
    final updated = list.where((n) => n.id != id).toList();
    await _localDataSource.saveAyahNotes(updated);
  }
}
