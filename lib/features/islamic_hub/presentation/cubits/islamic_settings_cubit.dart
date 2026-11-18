import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/islamic_settings_entity.dart';
import '../../domain/repositories/islamic_hub_repository.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/notification_service.dart';

class IslamicSettingsState extends Equatable {
  final IslamicSettingsEntity settings;
  final bool isLoading;

  const IslamicSettingsState({
    this.settings = const IslamicSettingsEntity(),
    this.isLoading = false,
  });

  IslamicSettingsState copyWith({
    IslamicSettingsEntity? settings,
    bool? isLoading,
  }) {
    return IslamicSettingsState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [settings, isLoading];
}

class IslamicSettingsCubit extends Cubit<IslamicSettingsState> {
  final IslamicHubRepository _repository;
  StreamSubscription<IslamicSettingsEntity>? _settingsSub;

  IslamicSettingsCubit({
    required IslamicHubRepository repository,
    IslamicSettingsEntity? initialSettings,
  })  : _repository = repository,
        super(
          IslamicSettingsState(
            settings: initialSettings ?? const IslamicSettingsEntity(),
          ),
        ) {
    _listenToRepository();
    if (initialSettings == null) {
      loadSettings();
    }
  }

  void _listenToRepository() {
    _settingsSub = _repository.watchSettings().listen((settings) {
      if (!isClosed) {
        emit(state.copyWith(settings: settings, isLoading: false));
      }
    });
  }

  @override
  Future<void> close() {
    _settingsSub?.cancel();
    return super.close();
  }

  Future<IslamicSettingsEntity> loadSettings() async {
    emit(state.copyWith(isLoading: true));
    final settings = await _repository.getSettings();
    if (!isClosed) {
      emit(state.copyWith(settings: settings, isLoading: false));
    }
    return settings;
  }

  Future<void> toggleFeature(bool enabled) async {
    final updated = state.settings.copyWith(isEnabled: enabled);
    emit(state.copyWith(settings: updated));
    await _repository.saveSettings(updated);
    await NotificationService().syncSmartReminders(updated);
  }

  Future<void> setOnboardingPromptSeen(bool enabled) async {
    final updated = state.settings.copyWith(
      isEnabled: enabled,
      hasSeenOnboardingPrompt: true,
    );
    emit(state.copyWith(settings: updated));
    await _repository.saveSettings(updated);
  }

  Future<void> updateAzanSound(String sound) async {
    final updated = state.settings.copyWith(azanSound: sound);
    emit(state.copyWith(settings: updated));
    await _repository.saveSettings(updated);
  }

  Future<void> updateCalculationMethod(String method) async {
    final updated = state.settings.copyWith(calculationMethod: method);
    emit(state.copyWith(settings: updated));
    await _repository.saveSettings(updated);
  }

  Future<void> updateLocation({
    required String city,
    required String country,
    double? latitude,
    double? longitude,
    bool isAutoLocation = false,
  }) async {
    final updated = state.settings.copyWith(
      selectedCity: city,
      selectedCountry: country,
      customLatitude: latitude,
      customLongitude: longitude,
      isAutoLocationEnabled: isAutoLocation,
    );
    emit(state.copyWith(settings: updated));
    await _repository.saveSettings(updated);
  }

  Future<LocationDataResult> detectAndApplyCurrentLocation() async {
    emit(state.copyWith(isLoading: true));
    try {
      final result = await LocationService().determineCurrentLocation();
      if (result.isSuccess && result.latitude != null && result.longitude != null) {
        final city = (result.city != null && result.city != 'Unknown')
            ? result.city!
            : state.settings.selectedCity;
        final country = (result.country != null && result.country != 'Unknown')
            ? result.country!
            : state.settings.selectedCountry;

        await updateLocation(
          city: city,
          country: country,
          latitude: result.latitude,
          longitude: result.longitude,
          isAutoLocation: true,
        );
      } else {
        emit(state.copyWith(isLoading: false));
      }
      return result;
    } catch (e) {
      emit(state.copyWith(isLoading: false));
      return LocationDataResult(
        isSuccess: false,
        errorMessage: 'حدث خطأ أثناء تحديد الموقع: $e',
      );
    }
  }

  Future<void> saveLastReadQuranPage(int page) async {
    final updated = state.settings.copyWith(lastReadQuranPage: page);
    emit(state.copyWith(settings: updated));
    await _repository.saveSettings(updated);
  }

  Future<void> toggleBookmarkPage(int page) async {
    final bookmarks = List<int>.from(state.settings.bookmarkedPages);
    if (bookmarks.contains(page)) {
      bookmarks.remove(page);
    } else {
      bookmarks.add(page);
    }
    final updated = state.settings.copyWith(bookmarkedPages: bookmarks);
    emit(state.copyWith(settings: updated));
    await _repository.saveSettings(updated);
  }

  Future<void> toggleVibration(bool enable) async {
    final updated = state.settings.copyWith(enableVibration: enable);
    emit(state.copyWith(settings: updated));
    await _repository.saveSettings(updated);
  }

  Future<void> toggleSound(bool enable) async {
    final updated = state.settings.copyWith(enableSound: enable);
    emit(state.copyWith(settings: updated));
    await _repository.saveSettings(updated);
  }

  Future<void> updateAppThemeMode(
    String mode, {
    bool markStartupChosen = true,
  }) async {
    final normalizedMode =
        (mode == 'light' || mode == 'dark' || mode == 'system')
            ? mode
            : 'system';
    final updated = state.settings.copyWith(
      appThemeMode: normalizedMode,
      hasChosenThemeOnStartup:
          markStartupChosen ? true : state.settings.hasChosenThemeOnStartup,
    );
    emit(state.copyWith(settings: updated));
    await _repository.saveSettings(updated);
  }

  Future<void> updateAsrJuristicMethod(int method) async {
    final updated = state.settings.copyWith(asrJuristicMethod: method.clamp(0, 1));
    emit(state.copyWith(settings: updated));
    await _repository.saveSettings(updated);
  }

  Future<void> updatePreAzanReminder(int minutes) async {
    final updated = state.settings.copyWith(
      preAzanReminderMinutes: minutes.clamp(0, 60),
    );
    emit(state.copyWith(settings: updated));
    await _repository.saveSettings(updated);
  }

  Future<void> updateIqamahReminder(int minutes) async {
    final updated = state.settings.copyWith(
      iqamahReminderMinutes: minutes.clamp(0, 60),
    );
    emit(state.copyWith(settings: updated));
    await _repository.saveSettings(updated);
  }

  Future<void> updatePrayerMinuteOffset(String prayerKey, int offsetMinutes) async {
    final updatedOffsets = Map<String, int>.from(state.settings.prayerMinuteOffsets);
    final clamped = offsetMinutes.clamp(-30, 30);
    if (clamped == 0) {
      updatedOffsets.remove(prayerKey.toLowerCase());
    } else {
      updatedOffsets[prayerKey.toLowerCase()] = clamped;
    }
    final updated = state.settings.copyWith(prayerMinuteOffsets: updatedOffsets);
    emit(state.copyWith(settings: updated));
    await _repository.saveSettings(updated);
  }

  Future<void> updatePerPrayerAzanSound(String prayerKey, String? sound) async {
    final updatedSounds = Map<String, String>.from(state.settings.perPrayerAzanSound);
    if (sound == null || sound.isEmpty || sound == 'default') {
      updatedSounds.remove(prayerKey.toLowerCase());
    } else {
      updatedSounds[prayerKey.toLowerCase()] = sound;
    }
    final updated = state.settings.copyWith(perPrayerAzanSound: updatedSounds);
    emit(state.copyWith(settings: updated));
    await _repository.saveSettings(updated);
  }

  Future<void> updateSmartReminders({
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
  }) async {
    final updated = state.settings.copyWith(
      morningAzkarReminderEnabled: morningAzkarReminderEnabled,
      morningAzkarHour: morningAzkarHour,
      morningAzkarMinute: morningAzkarMinute,
      eveningAzkarReminderEnabled: eveningAzkarReminderEnabled,
      eveningAzkarHour: eveningAzkarHour,
      eveningAzkarMinute: eveningAzkarMinute,
      sleepAzkarReminderEnabled: sleepAzkarReminderEnabled,
      sleepAzkarHour: sleepAzkarHour,
      sleepAzkarMinute: sleepAzkarMinute,
      quranWirdReminderEnabled: quranWirdReminderEnabled,
      quranWirdHour: quranWirdHour,
      quranWirdMinute: quranWirdMinute,
      fridayKahfReminderEnabled: fridayKahfReminderEnabled,
    );
    emit(state.copyWith(settings: updated));
    await _repository.saveSettings(updated);
    await NotificationService().syncSmartReminders(updated);
  }

  Future<void> updateAzkarFontScale(double scale) async {
    final updated = state.settings.copyWith(azkarFontScale: scale.clamp(0.85, 1.6));
    emit(state.copyWith(settings: updated));
    await _repository.saveSettings(updated);
  }

  Future<void> toggleFavoriteAzkar(String itemId) async {
    final favs = List<String>.from(state.settings.favoriteAzkarIds);
    if (favs.contains(itemId)) {
      favs.remove(itemId);
    } else {
      favs.add(itemId);
    }
    final updated = state.settings.copyWith(favoriteAzkarIds: favs);
    emit(state.copyWith(settings: updated));
    await _repository.saveSettings(updated);
  }
}
