import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_io/io.dart';
import '../../features/islamic_hub/domain/entities/prayer_time_entity.dart';

/// Persists today's prayer summary to [SharedPreferences] and triggers the
/// native Android AppWidget provider via [MethodChannel] when available.
class HomeWidgetSyncService {
  static const String prefsKey = 'arkan_widget_prayers_v1';
  static const String _channelName = 'com.arkan.arkan/widget';

  static String _formatTime12h(DateTime time) {
    final hour12 = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'م' : 'ص';
    return '$hour12:$minute $period';
  }

  static String _timeFor(List<PrayerTimeItem> prayers, PrayerType type) {
    for (final p in prayers) {
      if (p.type == type) {
        return _formatTime12h(p.time);
      }
    }
    return '--:--';
  }

  /// Writes formatted prayer times for the native home widget and requests
  /// an immediate refresh on Android. Safe in headless tests and non-Android hosts.
  static Future<void> syncTodayPrayerTimes(
    DayPrayerTimes dayTimes,
    PrayerTimeItem? nextPrayer,
  ) async {
    try {
      final resolvedNext = nextPrayer ?? dayTimes.nextPrayer;
      final payload = <String, String>{
        'locationName': dayTimes.locationName,
        'hijriDate': dayTimes.hijriDate,
        'nextPrayerName': resolvedNext?.nameArabic ?? 'الصلاة القادمة',
        'nextPrayerTime':
            resolvedNext != null ? _formatTime12h(resolvedNext.time) : '--:--',
        'fajr': _timeFor(dayTimes.prayers, PrayerType.fajr),
        'dhuhr': _timeFor(dayTimes.prayers, PrayerType.dhuhr),
        'asr': _timeFor(dayTimes.prayers, PrayerType.asr),
        'maghrib': _timeFor(dayTimes.prayers, PrayerType.maghrib),
        'isha': _timeFor(dayTimes.prayers, PrayerType.isha),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(prefsKey, jsonEncode(payload));

      if (!kIsWeb && Platform.isAndroid) {
        try {
          await const MethodChannel(_channelName)
              .invokeMethod<void>('updatePrayerWidget');
        } catch (_) {
          // Ignore when running outside full Android Activity context (e.g., tests).
        }
      }
    } catch (_) {
      // Non-critical widget sync; never interrupt main UI/cubit flow.
    }
  }
}
