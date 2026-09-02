import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/islamic_settings_entity.dart';
import '../../domain/entities/prayer_log_entity.dart';
import '../../domain/entities/tasbih_item_entity.dart';
import '../../domain/entities/quran_khatmah_entity.dart';
import '../../domain/entities/ayah_note_entity.dart';

abstract class IslamicLocalDataSource {
  Future<IslamicSettingsEntity> getSettings();
  Future<void> saveSettings(IslamicSettingsEntity settings);
  Stream<IslamicSettingsEntity> watchSettings();

  Future<List<PrayerLogEntity>> getPrayerLogs(String userId, DateTime date);
  Future<PrayerLogEntity> recordPrayerLog({
    required String userId,
    required String prayerName,
    required DateTime prayerDate,
    required bool isOnTime,
    required int coinsEarned,
  });

  Future<List<TasbihItemEntity>> getCustomTasbihItems();
  Future<void> saveCustomTasbihItems(List<TasbihItemEntity> items);

  Future<List<QuranKhatmahEntity>> getKhatmahs();
  Future<void> saveKhatmahs(List<QuranKhatmahEntity> list);

  Future<List<AyahNoteEntity>> getAyahNotes();
  Future<void> saveAyahNotes(List<AyahNoteEntity> list);
}

class IslamicLocalDataSourceImpl implements IslamicLocalDataSource {
  static const String _keySettings = 'arkan_islamic_settings_v1';
  static const String _keyPrayerLogsPrefix = 'arkan_prayer_logs_';
  static const String _keyTasbihItems = 'arkan_custom_tasbih_v1';
  static const String _keyKhatmahs = 'arkan_quran_khatmahs_v1';
  static const String _keyAyahNotes = 'arkan_ayah_notes_v1';

  StreamController<IslamicSettingsEntity>? _settingsController;
  StreamController<IslamicSettingsEntity> get _controller =>
      _settingsController ??= StreamController<IslamicSettingsEntity>.broadcast();

  IslamicSettingsEntity _cachedSettings = const IslamicSettingsEntity();

  bool _parseBool(dynamic val, {bool defaultValue = false}) {
    if (val == null) return defaultValue;
    if (val is bool) return val;
    if (val is num) return val != 0;
    if (val is String) {
      final lower = val.toLowerCase().trim();
      if (lower == 'true' || lower == '1' || lower == 't') return true;
      if (lower == 'false' || lower == '0' || lower == 'f') return false;
    }
    return defaultValue;
  }

  List<int> _parseBookmarkedPages(dynamic val) {
    if (val is List) {
      return val.map((e) => (e as num).toInt()).toList();
    }
    if (val is String && val.isNotEmpty) {
      try {
        final decoded = jsonDecode(val);
        if (decoded is List) {
          return decoded.map((e) => (e as num).toInt()).toList();
        }
      } catch (_) {}
    }
    return const [];
  }

  IslamicSettingsEntity _settingsFromMap(Map<String, dynamic> map) {
    return IslamicSettingsEntity(
      isEnabled: _parseBool(map['is_enabled'], defaultValue: true),
      hasSeenOnboardingPrompt: _parseBool(map['has_seen_onboarding_prompt'], defaultValue: false),
      azanSound: map['azan_sound'] as String? ?? 'makkah',
      calculationMethod: map['calculation_method'] as String? ?? 'Egyptian',
      enableVibration: _parseBool(map['enable_vibration'], defaultValue: true),
      enableSound: _parseBool(map['enable_sound'], defaultValue: true),
      lastReadQuranPage: (map['last_read_quran_page'] as num?)?.toInt() ?? 1,
      bookmarkedPages: _parseBookmarkedPages(map['bookmarked_pages']),
      selectedCity: map['selected_city'] as String? ?? 'Cairo',
      selectedCountry: map['selected_country'] as String? ?? 'Egypt',
      customLatitude: (map['custom_latitude'] as num?)?.toDouble(),
      customLongitude: (map['custom_longitude'] as num?)?.toDouble(),
      isAutoLocationEnabled: _parseBool(map['is_auto_location_enabled'], defaultValue: true),
      quranReadingMode: map['quran_reading_mode'] as String? ?? 'classic',
      quranSelectedReciter: map['quran_selected_reciter'] as String? ?? 'alafasy',
      quranAyahRepeat: (map['quran_ayah_repeat'] as num?)?.toInt() ?? 1,
      quranRangeRepeat: (map['quran_range_repeat'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> _settingsToMap(IslamicSettingsEntity settings) {
    return {
      'is_enabled': settings.isEnabled,
      'has_seen_onboarding_prompt': settings.hasSeenOnboardingPrompt,
      'azan_sound': settings.azanSound,
      'calculation_method': settings.calculationMethod,
      'enable_vibration': settings.enableVibration,
      'enable_sound': settings.enableSound,
      'last_read_quran_page': settings.lastReadQuranPage,
      'bookmarked_pages': settings.bookmarkedPages,
      'selected_city': settings.selectedCity,
      'selected_country': settings.selectedCountry,
      'custom_latitude': settings.customLatitude,
      'custom_longitude': settings.customLongitude,
      'is_auto_location_enabled': settings.isAutoLocationEnabled,
      'quran_reading_mode': settings.quranReadingMode,
      'quran_selected_reciter': settings.quranSelectedReciter,
      'quran_ayah_repeat': settings.quranAyahRepeat,
      'quran_range_repeat': settings.quranRangeRepeat,
    };
  }

  @override
  Future<IslamicSettingsEntity> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keySettings);
    IslamicSettingsEntity localSettings = const IslamicSettingsEntity();

    if (jsonStr != null) {
      try {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        localSettings = _settingsFromMap(map);
      } catch (e) {
        AppLogger.warning('Failed to decode islamic settings: $e');
      }
    }

    _cachedSettings = localSettings;
    return _cachedSettings;
  }

  @override
  Future<void> saveSettings(IslamicSettingsEntity settings) async {
    _cachedSettings = settings;
    _controller.add(settings);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySettings, jsonEncode(_settingsToMap(settings)));
  }

  @override
  Stream<IslamicSettingsEntity> watchSettings() async* {
    final current = await getSettings();
    yield current;
    yield* _controller.stream;
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Future<List<PrayerLogEntity>> getPrayerLogs(String userId, DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrayerLogsPrefix${_dateKey(date)}';
    final jsonStr = prefs.getString(key);

    if (jsonStr != null) {
      try {
        final list = jsonDecode(jsonStr) as List<dynamic>;
        return list.map((item) {
          final m = item as Map<String, dynamic>;
          return PrayerLogEntity(
            id: m['id'] as String,
            userId: m['user_id'] as String? ?? 'local_user',
            prayerName: m['prayer_name'] as String,
            prayerDate: DateTime.parse(m['prayer_date'] as String),
            isOnTime: m['is_on_time'] as bool,
            coinsEarned: m['coins_earned'] as int? ?? 0,
            createdAt: DateTime.parse(m['created_at'] as String),
          );
        }).toList();
      } catch (e) {
        AppLogger.warning('Failed to parse local prayer logs: $e');
      }
    }

    return [];
  }

  @override
  Future<PrayerLogEntity> recordPrayerLog({
    required String userId,
    required String prayerName,
    required DateTime prayerDate,
    required bool isOnTime,
    required int coinsEarned,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrayerLogsPrefix${_dateKey(prayerDate)}';
    final currentLogs = await getPrayerLogs(userId, prayerDate);

    // Remove old log for same prayer if already logged
    currentLogs.removeWhere((p) => p.prayerName.toLowerCase() == prayerName.toLowerCase());

    final newLog = PrayerLogEntity(
      id: const Uuid().v4(),
      userId: 'local_user',
      prayerName: prayerName,
      prayerDate: prayerDate,
      isOnTime: isOnTime,
      coinsEarned: coinsEarned,
      createdAt: DateTime.now(),
    );

    currentLogs.add(newLog);

    final list = currentLogs.map((p) => {
      'id': p.id,
      'user_id': p.userId,
      'prayer_name': p.prayerName,
      'prayer_date': p.prayerDate.toIso8601String(),
      'is_on_time': p.isOnTime,
      'coins_earned': p.coinsEarned,
      'created_at': p.createdAt.toIso8601String(),
    }).toList();

    await prefs.setString(key, jsonEncode(list));
    return newLog;
  }

  @override
  Future<List<TasbihItemEntity>> getCustomTasbihItems() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyTasbihItems);

    if (jsonStr != null) {
      try {
        final list = jsonDecode(jsonStr) as List<dynamic>;
        return list.map((item) {
          final m = item as Map<String, dynamic>;
          return TasbihItemEntity(
            id: m['id'] as String,
            text: m['text'] as String,
            target: m['target'] as int? ?? 33,
            reward: m['reward']?.toString(),
            currentCount: m['current_count'] as int? ?? 0,
            totalAllTimeCount: m['total_count'] as int? ?? 0,
          );
        }).toList();
      } catch (e) {
        AppLogger.warning('Failed to load custom tasbih items: $e');
      }
    }

    return [];
  }

  @override
  Future<void> saveCustomTasbihItems(List<TasbihItemEntity> items) async {
    final prefs = await SharedPreferences.getInstance();
    final list = items.map((t) => {
          'id': t.id,
          'text': t.text,
          'target': t.target,
          'reward': t.reward,
          'current_count': t.currentCount,
          'total_count': t.totalAllTimeCount,
        }).toList();
    await prefs.setString(_keyTasbihItems, jsonEncode(list));
  }

  @override
  Future<List<QuranKhatmahEntity>> getKhatmahs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyKhatmahs);

    if (jsonStr != null) {
      try {
        final list = jsonDecode(jsonStr) as List<dynamic>;
        return list.map((item) => QuranKhatmahEntity.fromJson(item as Map<String, dynamic>)).toList();
      } catch (e) {
        AppLogger.warning('Failed to load Quran khatmahs: $e');
      }
    }

    return [];
  }

  @override
  Future<void> saveKhatmahs(List<QuranKhatmahEntity> list) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = list.map((k) => k.toJson()).toList();
    await prefs.setString(_keyKhatmahs, jsonEncode(jsonList));
  }

  @override
  Future<List<AyahNoteEntity>> getAyahNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyAyahNotes);

    if (jsonStr != null) {
      try {
        final list = jsonDecode(jsonStr) as List<dynamic>;
        return list.map((item) => AyahNoteEntity.fromJson(item as Map<String, dynamic>)).toList();
      } catch (e) {
        AppLogger.warning('Failed to load Ayah notes: $e');
      }
    }

    return [];
  }

  @override
  Future<void> saveAyahNotes(List<AyahNoteEntity> list) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = list.map((n) => n.toJson()).toList();
    await prefs.setString(_keyAyahNotes, jsonEncode(jsonList));
  }
}
