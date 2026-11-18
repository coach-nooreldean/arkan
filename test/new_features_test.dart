import 'dart:convert';
import 'dart:io';
import 'package:arkan/core/services/backup_service.dart';
import 'package:arkan/core/services/home_widget_sync_service.dart';
import 'package:arkan/core/utils/hijri_calendar_helper.dart';
import 'package:arkan/features/islamic_hub/data/datasources/prayer_remote_datasource.dart';
import 'package:arkan/features/islamic_hub/data/datasources/quran_remote_datasource.dart';
import 'package:arkan/features/islamic_hub/domain/entities/ayah_entity.dart';
import 'package:arkan/features/islamic_hub/domain/entities/prayer_time_entity.dart';
import 'package:arkan/features/islamic_hub/presentation/cubits/worship_tracker_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('New Features (#6-#13) Verification', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('HijriCalendarHelper converts dates, formats Arabic & detects White Days', () {
      final hijri = HijriCalendarHelper.fromGregorian(DateTime(2025, 3, 1));
      expect(hijri.year, greaterThanOrEqualTo(1446));
      expect(hijri.month, inInclusiveRange(1, 12));
      expect(hijri.day, inInclusiveRange(1, 30));
      expect(hijri.formattedAr, contains('هـ'));

      const day12 = HijriDate(
        year: 1447,
        month: 9,
        day: 12,
        monthNameAr: 'رمضان',
        monthNameEn: 'Ramadan',
      );
      const day13 = HijriDate(
        year: 1447,
        month: 9,
        day: 13,
        monthNameAr: 'رمضان',
        monthNameEn: 'Ramadan',
      );
      const day14 = HijriDate(
        year: 1447,
        month: 9,
        day: 14,
        monthNameAr: 'رمضان',
        monthNameEn: 'Ramadan',
      );
      const day15 = HijriDate(
        year: 1447,
        month: 9,
        day: 15,
        monthNameAr: 'رمضان',
        monthNameEn: 'Ramadan',
      );
      expect(HijriCalendarHelper.isWhiteDay(day12), isFalse);
      expect(HijriCalendarHelper.isWhiteDay(day13), isTrue);
      expect(HijriCalendarHelper.isWhiteDay(day14), isTrue);
      expect(HijriCalendarHelper.isWhiteDay(day15), isTrue);

      const ramadan1 = HijriDate(
        year: 1447,
        month: 9,
        day: 1,
        monthNameAr: 'رمضان',
        monthNameEn: 'Ramadan',
      );
      expect(
        HijriCalendarHelper.getIslamicOccasion(ramadan1),
        contains('رمضان'),
      );
    });

    test('Offline Prayer calculation supports Shafi vs Hanafi Asr and valid Hijri date', () {
      final date = DateTime(2026, 5, 15);
      final shafi = PrayerRemoteDataSourceImpl.calculateOfflinePrayerTimes(
        date,
        lat: 30.0444,
        lng: 31.2357,
        locationName: 'Cairo, Egypt',
        method: 'Egyptian',
        asrSchool: 0,
      );
      final hanafi = PrayerRemoteDataSourceImpl.calculateOfflinePrayerTimes(
        date,
        lat: 30.0444,
        lng: 31.2357,
        locationName: 'Cairo, Egypt',
        method: 'Egyptian',
        asrSchool: 1,
      );

      final shafiAsr =
          shafi.prayers.firstWhere((p) => p.type == PrayerType.asr).time;
      final hanafiAsr =
          hanafi.prayers.firstWhere((p) => p.type == PrayerType.asr).time;
      final dhuhr =
          shafi.prayers.firstWhere((p) => p.type == PrayerType.dhuhr).time;
      final maghrib =
          shafi.prayers.firstWhere((p) => p.type == PrayerType.maghrib).time;

      expect(shafiAsr.hour, inInclusiveRange(13, 17));
      expect(hanafiAsr.hour, inInclusiveRange(14, 18));
      expect(shafiAsr.isAfter(dhuhr), isTrue);
      expect(hanafiAsr.isAfter(shafiAsr), isTrue);
      expect(maghrib.isAfter(hanafiAsr), isTrue);
      expect(shafi.hijriDate.trim(), isNotEmpty);
      expect(shafi.hijriYear.trim(), isNotEmpty);
    });

    test('BackupService exports and restores typed arkan_/islamic_ keys faithfully', () async {
      SharedPreferences.setMockInitialValues({
        'arkan_coins_balance': 42,
        'arkan_theme_flag': true,
        'arkan_rating_double': 1.5,
        'islamic_note_text': 'تدبر آية الكرسي',
        'islamic_favorite_ids': <String>['az_1', 'az_2'],
        'unrelated_third_party_key': 'should_be_ignored',
      });

      final jsonStr = await BackupService.exportBackupJson();
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
      expect(decoded['app'], 'arkan');
      final entries = decoded['entries'] as Map<String, dynamic>;
      expect(entries.containsKey('unrelated_third_party_key'), isFalse);

      // Wipe preferences and restore from backup
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      expect(prefs.getInt('arkan_coins_balance'), isNull);

      final restoredCount = await BackupService.importBackupJson(jsonStr);
      expect(restoredCount, 5);
      expect(prefs.getInt('arkan_coins_balance'), 42);
      expect(prefs.getBool('arkan_theme_flag'), isTrue);
      expect(prefs.getDouble('arkan_rating_double'), 1.5);
      expect(prefs.getString('islamic_note_text'), 'تدبر آية الكرسي');
      expect(
        prefs.getStringList('islamic_favorite_ids'),
        equals(<String>['az_1', 'az_2']),
      );
      expect(prefs.getString('unrelated_third_party_key'), isNull);

      await expectLater(
        () => BackupService.importBackupJson('{"app":"other","entries":{}}'),
        throwsFormatException,
      );
    });

    test('WorshipTrackerCubit auto-syncs Fard prayers, Azkar, Mulk & updates 7-day analytics', () async {
      final cubit = WorshipTrackerCubit();
      await cubit.loadLogForDate(DateTime.now());

      await cubit.markFardPrayerLogged('Fajr', date: DateTime.now());
      await cubit.markAzkarCategoryCompleted('morning');
      await cubit.markQuranActivity(wirdCompleted: true, pageNumber: 562);

      expect(cubit.state.currentLog.fajrFard, isTrue);
      expect(cubit.state.currentLog.morningEveningAzkar, isTrue);
      expect(cubit.state.currentLog.quranWird, isTrue);
      expect(cubit.state.currentLog.surahMulk, isTrue);
      expect(cubit.state.last7Days.length, 7);
      expect(cubit.state.streakDays, greaterThanOrEqualTo(1));

      await cubit.close();
    });

    test('Quran diacritic normalization matches text with or without tashkeel & hamza', () {
      const ayahs = [
        AyahEntity(
          number: 1,
          surahNumber: 1,
          numberInSurah: 1,
          page: 1,
          text: 'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ',
          surahName: 'الفاتحة',
        ),
        AyahEntity(
          number: 255,
          surahNumber: 2,
          numberInSurah: 255,
          page: 42,
          text: 'ٱللَّهُ لَآ إِلَـٰهَ إِلَّا هُوَ ٱلْحَىُّ ٱلْقَيُّومُ',
          surahName: 'البقرة',
        ),
      ];

      expect(
        QuranRemoteDataSourceImpl.normalizeArabicForSearch('إِبْرَاهِيمَ'),
        'ابراهيم',
      );

      final matches1 = QuranRemoteDataSourceImpl.searchInAyahList(ayahs, 'الرحمن');
      expect(matches1.length, 1);
      expect(matches1.first.number, 1);

      final matches2 =
          QuranRemoteDataSourceImpl.searchInAyahList(ayahs, 'لا اله الا هو الحي القيوم');
      expect(matches2.length, 1);
      expect(matches2.first.number, 255);
    });

    test('HomeWidgetSyncService persists widget payload and Android widget files are registered', () async {
      final date = DateTime(2026, 5, 15);
      final dayTimes = PrayerRemoteDataSourceImpl.calculateOfflinePrayerTimes(
        date,
        lat: 30.0444,
        lng: 31.2357,
        locationName: 'Cairo, Egypt',
      );
      await HomeWidgetSyncService.syncTodayPrayerTimes(dayTimes, dayTimes.prayers.first);

      final prefs = await SharedPreferences.getInstance();
      final savedJson = prefs.getString(HomeWidgetSyncService.prefsKey);
      expect(savedJson, isNotNull);

      final map = jsonDecode(savedJson!) as Map<String, dynamic>;
      expect(map['locationName'], 'Cairo, Egypt');
      expect((map['fajr'] as String).isNotEmpty, isTrue);
      expect((map['isha'] as String).isNotEmpty, isTrue);

      final providerFile = File(
        'android/app/src/main/kotlin/com/arkan/arkan/ArkanPrayerWidgetProvider.kt',
      );
      final layoutFile =
          File('android/app/src/main/res/layout/arkan_prayer_widget.xml');
      final bgFile =
          File('android/app/src/main/res/drawable/arkan_widget_bg.xml');
      final infoFile =
          File('android/app/src/main/res/xml/arkan_prayer_widget_info.xml');
      final stringsFile =
          File('android/app/src/main/res/values/strings.xml');
      final manifestFile = File('android/app/src/main/AndroidManifest.xml');

      expect(providerFile.existsSync(), isTrue);
      expect(layoutFile.existsSync(), isTrue);
      expect(bgFile.existsSync(), isTrue);
      expect(infoFile.existsSync(), isTrue);
      expect(stringsFile.existsSync(), isTrue);
      expect(
        manifestFile.readAsStringSync(),
        contains('.ArkanPrayerWidgetProvider'),
      );
    });
  });
}
