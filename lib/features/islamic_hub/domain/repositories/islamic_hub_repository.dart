import 'package:fpdart/fpdart.dart';
import '../entities/prayer_time_entity.dart';
import '../entities/prayer_log_entity.dart';
import '../entities/surah_entity.dart';
import '../entities/ayah_entity.dart';
import '../entities/azkar_category_entity.dart';
import '../entities/tasbih_item_entity.dart';
import '../entities/islamic_settings_entity.dart';
import '../entities/quran_khatmah_entity.dart';
import '../entities/ayah_note_entity.dart';

abstract class IslamicHubRepository {
  // Settings
  Future<IslamicSettingsEntity> getSettings();
  Future<void> saveSettings(IslamicSettingsEntity settings);
  Stream<IslamicSettingsEntity> watchSettings();

  // Prayer Times
  Future<Either<String, DayPrayerTimes>> getPrayerTimes({
    DateTime? date,
    String? city,
    String? country,
    double? latitude,
    double? longitude,
    String? method,
  });

  // Prayer Logs & Gamification
  Future<Either<String, List<PrayerLogEntity>>> getPrayerLogs(String userId, DateTime date);
  Future<Either<String, PrayerLogEntity>> recordPrayer({
    required String userId,
    required String prayerName,
    required DateTime prayerDate,
    required bool isOnTime,
  });

  // Quran
  Future<List<SurahEntity>> getAllSurahs();
  Future<List<JuzEntity>> getAllJuzs();
  Future<SurahEntity?> getSurahByNumber(int number);
  String getPageImageUrl(int pageNumber);
  List<String> getPageImageAlternativeUrls(int pageNumber);
  Future<Either<String, List<AyahEntity>>> getAyahsForPage(int pageNumber);
  Future<Either<String, List<AyahEntity>>> getAyahsForSurah(int surahNumber);
  Future<Either<String, String>> getAyahTafsir(int ayahNumber);
  Future<List<AyahEntity>> searchQuran(String query);

  // Quran Khatmah
  Future<List<QuranKhatmahEntity>> getKhatmahs();
  Future<void> saveKhatmah(QuranKhatmahEntity khatmah);
  Future<void> deleteKhatmah(String id);

  // Ayah Notes / Reflections
  Future<List<AyahNoteEntity>> getAyahNotes();
  Future<void> saveAyahNote(AyahNoteEntity note);
  Future<void> deleteAyahNote(String id);

  // Azkar
  Future<List<AzkarCategoryEntity>> getAllAzkarCategories();
  Future<AzkarCategoryEntity?> getAzkarCategoryById(String categoryId);
  Future<Either<String, int>> claimAzkarReward(String userId, String categoryId);

  // Tasbih
  Future<List<TasbihItemEntity>> getTasbihItems();
  Future<void> updateTasbihCount(String id, int currentCount, int totalCount);
  Future<void> addCustomTasbih(String text, int target, {String? reward});
  Future<void> deleteTasbih(String id);
}
