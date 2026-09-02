import 'package:equatable/equatable.dart';

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
  });

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
      ];
}
