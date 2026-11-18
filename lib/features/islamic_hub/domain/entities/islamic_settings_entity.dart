import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class IslamicSettingsEntity extends Equatable {
  final bool isEnabled;
  final bool hasSeenOnboardingPrompt;
  final String azanSound; // makkah, madinah, egypt, takbeerat, silent
  final String calculationMethod; // Egyptian, UmmAlQura, MuslimWorldLeague
  final bool enableVibration;
  final bool enableSound;
  final int lastReadQuranPage;
  final List<int> bookmarkedPages;
  final String selectedCity;
  final String selectedCountry;
  final double? customLatitude;
  final double? customLongitude;
  final bool isAutoLocationEnabled;
  final String quranReadingMode; // classic, dark, sepia
  final String quranSelectedReciter; // alafasy, alhusary, abdulbasit, minshawi
  final int quranAyahRepeat; // 1, 2, 3, 5, etc.
  final int quranRangeRepeat; // 1, 2, 3, 5, etc.
  final String appThemeMode; // system, light, dark
  final bool hasChosenThemeOnStartup;

  // Advanced prayer settings
  final int asrJuristicMethod; // 0 = Shafi/Standard, 1 = Hanafi
  final int preAzanReminderMinutes; // 0 = off, 5, 10, 15, 20
  final int iqamahReminderMinutes; // 0 = off, 10, 15, 20
  final Map<String, int> prayerMinuteOffsets; // fajr..isha -> -15..+15
  final Map<String, String> perPrayerAzanSound; // fajr..isha -> soundKey

  // Smart reminders
  final bool morningAzkarReminderEnabled;
  final int morningAzkarHour;
  final int morningAzkarMinute;
  final bool eveningAzkarReminderEnabled;
  final int eveningAzkarHour;
  final int eveningAzkarMinute;
  final bool sleepAzkarReminderEnabled;
  final int sleepAzkarHour;
  final int sleepAzkarMinute;
  final bool quranWirdReminderEnabled;
  final int quranWirdHour;
  final int quranWirdMinute;
  final bool fridayKahfReminderEnabled;

  // Azkar reader preferences
  final double azkarFontScale;
  final List<String> favoriteAzkarIds;

  const IslamicSettingsEntity({
    this.isEnabled = true,
    this.hasSeenOnboardingPrompt = false,
    this.azanSound = 'makkah',
    this.calculationMethod = 'Egyptian',
    this.enableVibration = true,
    this.enableSound = true,
    this.lastReadQuranPage = 1,
    this.bookmarkedPages = const [],
    this.selectedCity = 'Cairo',
    this.selectedCountry = 'Egypt',
    this.customLatitude,
    this.customLongitude,
    this.isAutoLocationEnabled = true,
    this.quranReadingMode = 'classic',
    this.quranSelectedReciter = 'alafasy',
    this.quranAyahRepeat = 1,
    this.quranRangeRepeat = 1,
    this.appThemeMode = 'system',
    this.hasChosenThemeOnStartup = false,
    this.asrJuristicMethod = 0,
    this.preAzanReminderMinutes = 0,
    this.iqamahReminderMinutes = 0,
    this.prayerMinuteOffsets = const {},
    this.perPrayerAzanSound = const {},
    this.morningAzkarReminderEnabled = true,
    this.morningAzkarHour = 7,
    this.morningAzkarMinute = 0,
    this.eveningAzkarReminderEnabled = true,
    this.eveningAzkarHour = 17,
    this.eveningAzkarMinute = 30,
    this.sleepAzkarReminderEnabled = false,
    this.sleepAzkarHour = 22,
    this.sleepAzkarMinute = 30,
    this.quranWirdReminderEnabled = true,
    this.quranWirdHour = 20,
    this.quranWirdMinute = 0,
    this.fridayKahfReminderEnabled = true,
    this.azkarFontScale = 1.0,
    this.favoriteAzkarIds = const [],
  });

  ThemeMode get resolvedThemeMode {
    switch (appThemeMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  IslamicSettingsEntity copyWith({
    bool? isEnabled,
    bool? hasSeenOnboardingPrompt,
    String? azanSound,
    String? calculationMethod,
    bool? enableVibration,
    bool? enableSound,
    int? lastReadQuranPage,
    List<int>? bookmarkedPages,
    String? selectedCity,
    String? selectedCountry,
    double? customLatitude,
    double? customLongitude,
    bool? isAutoLocationEnabled,
    String? quranReadingMode,
    String? quranSelectedReciter,
    int? quranAyahRepeat,
    int? quranRangeRepeat,
    String? appThemeMode,
    bool? hasChosenThemeOnStartup,
    int? asrJuristicMethod,
    int? preAzanReminderMinutes,
    int? iqamahReminderMinutes,
    Map<String, int>? prayerMinuteOffsets,
    Map<String, String>? perPrayerAzanSound,
    bool? morningAzkarReminderEnabled,
    int? morningAzkarHour,
    int? morningAzkarMinute,
    bool? eveningAzkarReminderEnabled,
    int? eveningAzkarHour,
    int? eveningAzkarMinute,
    bool? sleepAzkarReminderEnabled,
    int? sleepAzkarHour,
    int? sleepAzkarMinute,
    bool? quranWirdReminderEnabled,
    int? quranWirdHour,
    int? quranWirdMinute,
    bool? fridayKahfReminderEnabled,
    double? azkarFontScale,
    List<String>? favoriteAzkarIds,
  }) {
    return IslamicSettingsEntity(
      isEnabled: isEnabled ?? this.isEnabled,
      hasSeenOnboardingPrompt: hasSeenOnboardingPrompt ?? this.hasSeenOnboardingPrompt,
      azanSound: azanSound ?? this.azanSound,
      calculationMethod: calculationMethod ?? this.calculationMethod,
      enableVibration: enableVibration ?? this.enableVibration,
      enableSound: enableSound ?? this.enableSound,
      lastReadQuranPage: lastReadQuranPage ?? this.lastReadQuranPage,
      bookmarkedPages: bookmarkedPages ?? this.bookmarkedPages,
      selectedCity: selectedCity ?? this.selectedCity,
      selectedCountry: selectedCountry ?? this.selectedCountry,
      customLatitude: customLatitude ?? this.customLatitude,
      customLongitude: customLongitude ?? this.customLongitude,
      isAutoLocationEnabled: isAutoLocationEnabled ?? this.isAutoLocationEnabled,
      quranReadingMode: quranReadingMode ?? this.quranReadingMode,
      quranSelectedReciter: quranSelectedReciter ?? this.quranSelectedReciter,
      quranAyahRepeat: quranAyahRepeat ?? this.quranAyahRepeat,
      quranRangeRepeat: quranRangeRepeat ?? this.quranRangeRepeat,
      appThemeMode: appThemeMode ?? this.appThemeMode,
      hasChosenThemeOnStartup: hasChosenThemeOnStartup ?? this.hasChosenThemeOnStartup,
      asrJuristicMethod: asrJuristicMethod ?? this.asrJuristicMethod,
      preAzanReminderMinutes: preAzanReminderMinutes ?? this.preAzanReminderMinutes,
      iqamahReminderMinutes: iqamahReminderMinutes ?? this.iqamahReminderMinutes,
      prayerMinuteOffsets: prayerMinuteOffsets ?? this.prayerMinuteOffsets,
      perPrayerAzanSound: perPrayerAzanSound ?? this.perPrayerAzanSound,
      morningAzkarReminderEnabled:
          morningAzkarReminderEnabled ?? this.morningAzkarReminderEnabled,
      morningAzkarHour: morningAzkarHour ?? this.morningAzkarHour,
      morningAzkarMinute: morningAzkarMinute ?? this.morningAzkarMinute,
      eveningAzkarReminderEnabled:
          eveningAzkarReminderEnabled ?? this.eveningAzkarReminderEnabled,
      eveningAzkarHour: eveningAzkarHour ?? this.eveningAzkarHour,
      eveningAzkarMinute: eveningAzkarMinute ?? this.eveningAzkarMinute,
      sleepAzkarReminderEnabled:
          sleepAzkarReminderEnabled ?? this.sleepAzkarReminderEnabled,
      sleepAzkarHour: sleepAzkarHour ?? this.sleepAzkarHour,
      sleepAzkarMinute: sleepAzkarMinute ?? this.sleepAzkarMinute,
      quranWirdReminderEnabled:
          quranWirdReminderEnabled ?? this.quranWirdReminderEnabled,
      quranWirdHour: quranWirdHour ?? this.quranWirdHour,
      quranWirdMinute: quranWirdMinute ?? this.quranWirdMinute,
      fridayKahfReminderEnabled:
          fridayKahfReminderEnabled ?? this.fridayKahfReminderEnabled,
      azkarFontScale: azkarFontScale ?? this.azkarFontScale,
      favoriteAzkarIds: favoriteAzkarIds ?? this.favoriteAzkarIds,
    );
  }

  @override
  List<Object?> get props => [
        isEnabled,
        hasSeenOnboardingPrompt,
        azanSound,
        calculationMethod,
        enableVibration,
        enableSound,
        lastReadQuranPage,
        bookmarkedPages,
        selectedCity,
        selectedCountry,
        customLatitude,
        customLongitude,
        isAutoLocationEnabled,
        quranReadingMode,
        quranSelectedReciter,
        quranAyahRepeat,
        quranRangeRepeat,
        appThemeMode,
        hasChosenThemeOnStartup,
        asrJuristicMethod,
        preAzanReminderMinutes,
        iqamahReminderMinutes,
        prayerMinuteOffsets,
        perPrayerAzanSound,
        morningAzkarReminderEnabled,
        morningAzkarHour,
        morningAzkarMinute,
        eveningAzkarReminderEnabled,
        eveningAzkarHour,
        eveningAzkarMinute,
        sleepAzkarReminderEnabled,
        sleepAzkarHour,
        sleepAzkarMinute,
        quranWirdReminderEnabled,
        quranWirdHour,
        quranWirdMinute,
        fridayKahfReminderEnabled,
        azkarFontScale,
        favoriteAzkarIds,
      ];
}
