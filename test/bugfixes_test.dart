import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arkan/core/services/compass_service.dart';
import 'package:arkan/core/services/location_service.dart';
import 'package:arkan/features/islamic_hub/data/datasources/islamic_local_datasource.dart';
import 'package:arkan/features/islamic_hub/domain/entities/ayah_entity.dart';
import 'package:arkan/features/islamic_hub/domain/entities/ayah_note_entity.dart';
import 'package:arkan/features/islamic_hub/domain/entities/azkar_category_entity.dart';
import 'package:arkan/features/islamic_hub/domain/entities/islamic_settings_entity.dart';
import 'package:arkan/features/islamic_hub/domain/entities/prayer_log_entity.dart';
import 'package:arkan/features/islamic_hub/domain/entities/prayer_time_entity.dart';
import 'package:arkan/features/islamic_hub/domain/entities/quran_khatmah_entity.dart';
import 'package:arkan/features/islamic_hub/domain/entities/surah_entity.dart';
import 'package:arkan/features/islamic_hub/domain/entities/tasbih_item_entity.dart';
import 'package:arkan/features/islamic_hub/domain/repositories/islamic_hub_repository.dart';
import 'package:arkan/features/islamic_hub/presentation/cubits/islamic_settings_cubit.dart';
import 'package:arkan/features/islamic_hub/presentation/cubits/khatmah_cubit.dart';
import 'package:arkan/features/islamic_hub/presentation/cubits/qibla_cubit.dart';
import 'package:arkan/features/islamic_hub/presentation/cubits/quran_cubit.dart';
import 'package:arkan/features/islamic_hub/presentation/screens/madani_quran_screen.dart';
import 'package:arkan/features/rewards/domain/entities/arkan_achievement.dart';
import 'package:arkan/features/rewards/domain/entities/arkan_coin_transaction.dart';
import 'package:arkan/features/rewards/domain/repositories/arkan_coins_repository.dart';
import 'package:arkan/features/rewards/presentation/cubits/arkan_coins_cubit.dart';

class _FakeIslamicHubRepository implements IslamicHubRepository {
  IslamicSettingsEntity _settings;
  final _settingsController = StreamController<IslamicSettingsEntity>.broadcast();

  _FakeIslamicHubRepository({IslamicSettingsEntity? initialSettings})
      : _settings = initialSettings ?? const IslamicSettingsEntity();

  @override
  Future<IslamicSettingsEntity> getSettings() async => _settings;

  @override
  Future<void> saveSettings(IslamicSettingsEntity settings) async {
    _settings = settings;
    _settingsController.add(settings);
  }

  @override
  Stream<IslamicSettingsEntity> watchSettings() => _settingsController.stream;

  @override
  Future<List<SurahEntity>> getAllSurahs() async => const [
        SurahEntity(
          number: 1,
          name: 'الفاتحة',
          englishName: 'Al-Fatihah',
          englishNameTranslation: 'The Opener',
          revelationType: 'Meccan',
          numberOfAyahs: 7,
          startPage: 1,
          endPage: 1,
          juz: 1,
        ),
        SurahEntity(
          number: 4,
          name: 'النساء',
          englishName: 'An-Nisa',
          englishNameTranslation: 'The Women',
          revelationType: 'Medinan',
          numberOfAyahs: 176,
          startPage: 77,
          endPage: 106,
          juz: 5,
        ),
      ];

  @override
  Future<List<JuzEntity>> getAllJuzs() async => const [
        JuzEntity(
          number: 1,
          name: 'الجزء الأول',
          startPage: 1,
          startSurah: 'الفاتحة',
          startAyah: 1,
        ),
        JuzEntity(
          number: 5,
          name: 'الجزء الخامس',
          startPage: 82,
          startSurah: 'النساء',
          startAyah: 24,
        ),
      ];

  @override
  Future<SurahEntity?> getSurahByNumber(int number) async => null;

  @override
  String getPageImageUrl(int pageNumber) => 'https://example.invalid/$pageNumber.png';

  @override
  List<String> getPageImageAlternativeUrls(int pageNumber) => const [];

  @override
  Future<Either<String, List<AyahEntity>>> getAyahsForPage(int pageNumber) async =>
      const Right([]);

  @override
  Future<Either<String, List<AyahEntity>>> getAyahsForSurah(int surahNumber) async =>
      const Right([]);

  @override
  Future<Either<String, String>> getAyahTafsir(int ayahNumber) async =>
      const Right('');

  @override
  Future<List<AyahEntity>> searchQuran(String query) async => const [];

  @override
  Future<bool> isFullQuranBundleCached() async => false;

  @override
  Future<int> getDownloadedMushafPagesCount() async => 0;

  @override
  Future<String?> getLocalMushafPagePath(int pageNumber) async => null;

  @override
  Future<Either<String, void>> downloadFullQuranOfflineBundle({
    void Function(double progress, String status)? onProgress,
  }) async =>
      const Right(null);

  @override
  Future<Either<String, void>> downloadAllMushafPages({
    required void Function(int completed, int total) onProgress,
    bool Function()? isCancelled,
  }) async =>
      const Right(null);

  @override
  Future<List<QuranKhatmahEntity>> getKhatmahs() async => [
        QuranKhatmahEntity(
          id: 'k1',
          title: 'ختمة اختبار',
          targetDays: 30,
          startDate: DateTime(2026, 1, 1),
          startPage: 1,
          endPage: 604,
          currentPage: 101,
          pagesReadToday: 0,
        ),
      ];

  @override
  Future<void> saveKhatmah(QuranKhatmahEntity khatmah) async {}

  @override
  Future<void> deleteKhatmah(String id) async {}

  @override
  Future<List<AyahNoteEntity>> getAyahNotes() async => const [];

  @override
  Future<void> saveAyahNote(AyahNoteEntity note) async {}

  @override
  Future<void> deleteAyahNote(String id) async {}

  @override
  Future<List<AzkarCategoryEntity>> getAllAzkarCategories() async => const [];

  @override
  Future<AzkarCategoryEntity?> getAzkarCategoryById(String categoryId) async =>
      null;

  @override
  Future<Either<String, int>> claimAzkarReward(String userId, String categoryId) async =>
      const Right(0);

  @override
  Future<List<TasbihItemEntity>> getTasbihItems() async => const [];

  @override
  Future<void> updateTasbihCount(String id, int currentCount, int totalCount) async {}

  @override
  Future<void> addCustomTasbih(String text, int target, {String? reward}) async {}

  @override
  Future<void> deleteTasbih(String id) async {}

  @override
  Future<Either<String, List<PrayerLogEntity>>> getPrayerLogs(
    String userId,
    DateTime date,
  ) async =>
      const Right([]);

  @override
  Future<Either<String, DayPrayerTimes>> getPrayerTimes({
    DateTime? date,
    String? city,
    String? country,
    double? latitude,
    double? longitude,
    String? method,
  }) async =>
      const Left('unused');

  @override
  Future<Either<String, PrayerLogEntity>> recordPrayer({
    required String userId,
    required String prayerName,
    required DateTime prayerDate,
    required bool isOnTime,
  }) async =>
      const Left('unused');

  void dispose() {
    _settingsController.close();
  }
}

class _FakeLocationService extends Fake implements LocationService {
  @override
  Future<LocationDataResult> determineCurrentLocation() async =>
      const LocationDataResult(isSuccess: false);
}

class _FakeAudioPlayer extends Fake implements AudioPlayer {
  @override
  Stream<PlayerState> get playerStateStream => const Stream.empty();

  @override
  Future<void> dispose() async {}
}

class _FakeArkanCoinsRepository implements ArkanCoinsRepository {
  @override
  Future<int> getBalance() async => 0;

  @override
  Future<int> addCoins({
    required int amount,
    required String title,
    String? subtitle,
    required ArkanCoinSource source,
  }) async =>
      amount;

  @override
  Future<List<ArkanAchievement>> getAchievements() async => const [];

  @override
  Future<List<ArkanCoinTransaction>> getTransactions() async => const [];

  @override
  Future<List<ArkanAchievement>> recordProgress({
    required String achievementId,
    int incrementBy = 1,
  }) async =>
      const [];
}

void main() {
  group('Bugfix #1: Qibla Compass Sensor & Smoothing', () {
    test('CompassService circular smoothing wraps across 359 <-> 2 without jumping', () {
      final s1 = CompassService.applyCircularSmoothing(359.0, null);
      expect(s1, equals(359.0));

      final s2 = CompassService.applyCircularSmoothing(2.0, s1);
      // Shortest arc from 359 to 2 is +3 deg -> 359 + 0.25*3 = 359.75
      expect(s2, closeTo(359.75, 0.01));
    });

    test('QiblaCubit reacts to compass headings and reports unavailable sensor', () async {
      final repo = _FakeIslamicHubRepository(
        initialSettings: const IslamicSettingsEntity(
          customLatitude: 30.0444,
          customLongitude: 31.2357,
          isAutoLocationEnabled: false,
        ),
      );
      final controller = StreamController<CompassReading>();
      final compassService = CompassService(
        streamOverride: () => controller.stream,
      );

      final cubit = QiblaCubit(
        repository: repo,
        compassService: compassService,
        locationService: _FakeLocationService(),
      );

      await cubit.initQibla();
      expect(cubit.state.qiblaAngle, closeTo(136.1, 1.0));

      cubit.startCompass();
      controller.add(const CompassReading(isAvailable: true, heading: 0.0, accuracy: 3));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(cubit.state.hasCompassSensor, isTrue);
      expect(cubit.state.isFacingQibla, isFalse);
      expect(cubit.state.needleAngle, closeTo(cubit.state.qiblaAngle, 0.1));

      controller.add(
        CompassReading(isAvailable: true, heading: cubit.state.qiblaAngle, accuracy: 3),
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(cubit.state.isFacingQibla, isTrue);
      expect(cubit.state.needleAngle, closeTo(0.0, 0.1));

      controller.add(const CompassReading(isAvailable: false));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(cubit.state.hasCompassSensor, isFalse);
      expect(cubit.state.isFacingQibla, isFalse);

      await controller.close();
      await cubit.close();
      repo.dispose();
    });
  });

  group('Bugfix #2: Adhan Android Raw Resources & Manifest Receivers', () {
    test('All 4 Adhan MP3 files and keep.xml exist in Android res/raw', () {
      const requiredFiles = [
        'android/app/src/main/res/raw/adhan_makkah.mp3',
        'android/app/src/main/res/raw/adhan_madinah.mp3',
        'android/app/src/main/res/raw/adhan_egypt.mp3',
        'android/app/src/main/res/raw/adhan_takbeerat.mp3',
        'android/app/src/main/res/raw/keep.xml',
      ];
      for (final path in requiredFiles) {
        final file = File(path);
        expect(file.existsSync(), isTrue, reason: 'Missing $path');
        expect(file.lengthSync(), greaterThan(0), reason: 'Empty $path');
      }
    });

    test('AndroidManifest declares notification receivers and full screen intent', () {
      final manifest = File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
      expect(manifest, contains('USE_FULL_SCREEN_INTENT'));
      expect(manifest, contains('ScheduledNotificationReceiver'));
      expect(manifest, contains('ScheduledNotificationBootReceiver'));
      expect(manifest, contains('ActionBroadcastReceiver'));
    });

    test('No broken references to missing audio/notification_sound.mp3 remain', () {
      final prayerScreen = File(
        'lib/features/islamic_hub/presentation/screens/prayer_times_screen.dart',
      ).readAsStringSync();
      final soundService = File(
        'lib/core/services/sound_effects_service.dart',
      ).readAsStringSync();
      expect(prayerScreen, isNot(contains('notification_sound.mp3')));
      expect(soundService, isNot(contains('notification_sound.mp3')));
    });
  });

  group('Bugfix #3 & #4: Mushaf RTL Direction & Dual/Single Page Sync', () {
    testWidgets(
      'MadaniQuranScreen flips RTL (reverse=false) and preserves page 101 when switching dual -> single',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1024, 768);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final repo = _FakeIslamicHubRepository(
          initialSettings: const IslamicSettingsEntity(lastReadQuranPage: 101),
        );
        final quranCubit = QuranCubit(
          repository: repo,
          audioPlayer: _FakeAudioPlayer(),
        );
        final khatmahCubit = KhatmahCubit(repository: repo);
        final coinsCubit = ArkanCoinsCubit(repository: _FakeArkanCoinsRepository());

        await tester.pumpWidget(
          ScreenUtilInit(
            designSize: const Size(1024, 768),
            builder: (context, _) => MultiBlocProvider(
              providers: [
                BlocProvider<QuranCubit>.value(value: quranCubit),
                BlocProvider<KhatmahCubit>.value(value: khatmahCubit),
                BlocProvider<ArkanCoinsCubit>.value(value: coinsCubit),
              ],
              child: const MaterialApp(
                home: MadaniQuranScreen(),
              ),
            ),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        // Starts in dual-page mode on wide tablet screen at page 101 (spread 50)
        final dualFinder = find.byKey(const ValueKey('quran_dual_pageview'));
        expect(dualFinder, findsOneWidget);
        final dualPageView = tester.widget<PageView>(dualFinder);
        expect(dualPageView.reverse, isFalse);
        expect(dualPageView.controller?.page?.round(), equals(50));

        final scrollable = tester.widget<Scrollable>(
          find.descendant(of: dualFinder, matching: find.byType(Scrollable)),
        );
        expect(scrollable.axisDirection, equals(AxisDirection.left));

        // Switch from dual-page to single-page mode
        final toggleToSingleBtn = find.byTooltip('عرض صفحة واحدة');
        expect(toggleToSingleBtn, findsOneWidget);
        await tester.tap(toggleToSingleBtn);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        // Must stay on page 101 (index 100), NOT jump to half (index 50 / page 51)
        final singleFinder = find.byKey(const ValueKey('quran_single_pageview'));
        expect(singleFinder, findsOneWidget);
        final singlePageView = tester.widget<PageView>(singleFinder);
        expect(singlePageView.reverse, isFalse);
        expect(singlePageView.controller?.page?.round(), equals(100));

        final singleScrollable = tester.widget<Scrollable>(
          find.descendant(of: singleFinder, matching: find.byType(Scrollable)),
        );
        expect(singleScrollable.axisDirection, equals(AxisDirection.left));

        // Switch back to dual-page mode: still spread 50 (pages 101-102)
        final toggleToDualBtn = find.byTooltip('عرض صفحتين متجاورتين');
        expect(toggleToDualBtn, findsOneWidget);
        await tester.tap(toggleToDualBtn);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        expect(find.byKey(const ValueKey('quran_dual_pageview')), findsOneWidget);
        expect(
          tester.widget<PageView>(find.byKey(const ValueKey('quran_dual_pageview')))
              .controller
              ?.page
              ?.round(),
          equals(50),
        );

        await quranCubit.close();
        await khatmahCubit.close();
        await coinsCubit.close();
        repo.dispose();
      },
    );
  });

  group('Bugfix #5: Device Theme Mode & Startup Theme Persistence', () {
    test('IslamicSettingsEntity defaults to system theme and startup prompt unseen', () {
      const settings = IslamicSettingsEntity();
      expect(settings.appThemeMode, equals('system'));
      expect(settings.resolvedThemeMode, equals(ThemeMode.system));
      expect(settings.hasChosenThemeOnStartup, isFalse);

      expect(settings.copyWith(appThemeMode: 'light').resolvedThemeMode, equals(ThemeMode.light));
      expect(settings.copyWith(appThemeMode: 'dark').resolvedThemeMode, equals(ThemeMode.dark));
    });

    test('IslamicLocalDataSourceImpl & IslamicSettingsCubit persist theme choice', () async {
      SharedPreferences.setMockInitialValues({});
      final dataSource = IslamicLocalDataSourceImpl();
      final repo = _FakeIslamicHubRepository();

      final initialFromDisk = await dataSource.getSettings();
      expect(initialFromDisk.appThemeMode, equals('system'));
      expect(initialFromDisk.hasChosenThemeOnStartup, isFalse);

      await dataSource.saveSettings(
        initialFromDisk.copyWith(
          appThemeMode: 'light',
          hasChosenThemeOnStartup: true,
        ),
      );
      final reloaded = await dataSource.getSettings();
      expect(reloaded.appThemeMode, equals('light'));
      expect(reloaded.resolvedThemeMode, equals(ThemeMode.light));
      expect(reloaded.hasChosenThemeOnStartup, isTrue);

      final cubit = IslamicSettingsCubit(
        repository: repo,
        initialSettings: const IslamicSettingsEntity(),
      );
      await cubit.updateAppThemeMode('dark', markStartupChosen: false);
      expect(cubit.state.settings.resolvedThemeMode, equals(ThemeMode.dark));
      expect(cubit.state.settings.hasChosenThemeOnStartup, isFalse);

      await cubit.updateAppThemeMode('light', markStartupChosen: true);
      expect(cubit.state.settings.resolvedThemeMode, equals(ThemeMode.light));
      expect(cubit.state.settings.hasChosenThemeOnStartup, isTrue);

      await cubit.close();
      repo.dispose();
    });
  });
}
