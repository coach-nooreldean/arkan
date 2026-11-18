import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/worship_tracker_entity.dart';

class WorshipTrackerState extends Equatable {
  final DateTime selectedDate;
  final DailyWorshipLogEntity currentLog;
  final Map<String, DailyWorshipLogEntity> recentLogs; // dateKey -> log
  final List<DailyWorshipLogEntity> last7Days;
  final int streakDays;
  final bool isLoading;
  final String? error;

  const WorshipTrackerState({
    required this.selectedDate,
    required this.currentLog,
    this.recentLogs = const {},
    this.last7Days = const [],
    this.streakDays = 0,
    this.isLoading = false,
    this.error,
  });

  WorshipTrackerState copyWith({
    DateTime? selectedDate,
    DailyWorshipLogEntity? currentLog,
    Map<String, DailyWorshipLogEntity>? recentLogs,
    List<DailyWorshipLogEntity>? last7Days,
    int? streakDays,
    bool? isLoading,
    String? error,
  }) {
    return WorshipTrackerState(
      selectedDate: selectedDate ?? this.selectedDate,
      currentLog: currentLog ?? this.currentLog,
      recentLogs: recentLogs ?? this.recentLogs,
      last7Days: last7Days ?? this.last7Days,
      streakDays: streakDays ?? this.streakDays,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        selectedDate,
        currentLog,
        recentLogs,
        last7Days,
        streakDays,
        isLoading,
        error,
      ];
}

class WorshipTrackerCubit extends Cubit<WorshipTrackerState> {
  static const String _keyPrefix = 'islamic_worship_log_';
  static const String _prayerLogsPrefix = 'arkan_prayer_logs_';

  WorshipTrackerCubit()
      : super(WorshipTrackerState(
          selectedDate: DateTime.now(),
          currentLog: DailyWorshipLogEntity(dateKey: _formatDate(DateTime.now())),
        )) {
    loadLogForDate(DateTime.now());
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<DailyWorshipLogEntity> _readMergedLog(
    SharedPreferences prefs,
    DateTime date,
  ) async {
    final dateKey = _formatDate(date);
    DailyWorshipLogEntity log = DailyWorshipLogEntity(dateKey: dateKey);

    final jsonStr = prefs.getString('$_keyPrefix$dateKey');
    if (jsonStr != null) {
      try {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        log = DailyWorshipLogEntity.fromJson(map);
        if (log.dateKey.isEmpty) {
          log = log.copyWith(dateKey: dateKey);
        }
      } catch (_) {}
    }

    // Merge logged Fard prayers from arkan_prayer_logs_YYYY-MM-DD
    final prayerJsonStr = prefs.getString('$_prayerLogsPrefix$dateKey');
    if (prayerJsonStr != null) {
      try {
        final list = jsonDecode(prayerJsonStr) as List<dynamic>;
        for (final item in list) {
          final m = item as Map<String, dynamic>;
          final name = (m['prayer_name'] as String? ?? '').toLowerCase();
          log = _applyPrayerNameToLog(log, name);
        }
      } catch (_) {}
    }

    return log;
  }

  DailyWorshipLogEntity _applyPrayerNameToLog(
    DailyWorshipLogEntity log,
    String prayerNameLower,
  ) {
    switch (prayerNameLower) {
      case 'fajr':
        return log.copyWith(fajrFard: true);
      case 'dhuhr':
        return log.copyWith(dhuhrFard: true);
      case 'asr':
        return log.copyWith(asrFard: true);
      case 'maghrib':
        return log.copyWith(maghribFard: true);
      case 'isha':
        return log.copyWith(ishaFard: true);
      default:
        return log;
    }
  }

  Future<({List<DailyWorshipLogEntity> last7Days, int streakDays})>
      _computeAnalytics(SharedPreferences prefs) async {
    final now = DateTime.now();
    final todayOnly = DateTime(now.year, now.month, now.day);

    final last7 = <DailyWorshipLogEntity>[];
    for (int offset = 6; offset >= 0; offset--) {
      final d = todayOnly.subtract(Duration(days: offset));
      last7.add(await _readMergedLog(prefs, d));
    }

    int streak = 0;
    for (int offset = 0; offset < 30; offset++) {
      final d = todayOnly.subtract(Duration(days: offset));
      final log = await _readMergedLog(prefs, d);
      if (log.totalCompletedCount > 0) {
        streak++;
      } else {
        // Allow today to still be in progress without breaking yesterday's streak
        if (offset == 0) continue;
        break;
      }
    }

    return (last7Days: last7, streakDays: streak);
  }

  Future<void> loadLogForDate(DateTime date) async {
    final dateKey = _formatDate(date);
    emit(state.copyWith(selectedDate: date, isLoading: true, error: null));

    try {
      final prefs = await SharedPreferences.getInstance();
      final log = await _readMergedLog(prefs, date);
      final analytics = await _computeAnalytics(prefs);

      final updatedRecent = Map<String, DailyWorshipLogEntity>.from(state.recentLogs);
      updatedRecent[dateKey] = log;

      if (!isClosed) {
        emit(state.copyWith(
          selectedDate: date,
          currentLog: log,
          recentLogs: updatedRecent,
          last7Days: analytics.last7Days,
          streakDays: analytics.streakDays,
          isLoading: false,
        ));
      }
    } catch (e) {
      AppLogger.warning('Failed to load daily worship log: $e');
      if (!isClosed) {
        emit(state.copyWith(isLoading: false, error: e.toString()));
      }
    }
  }

  Future<void> _saveLogAndRefresh(
    DailyWorshipLogEntity updated,
    DateTime targetDate,
  ) async {
    final dateKey = updated.dateKey;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_keyPrefix$dateKey', jsonEncode(updated.toJson()));
    final analytics = await _computeAnalytics(prefs);

    final updatedRecent = Map<String, DailyWorshipLogEntity>.from(state.recentLogs);
    updatedRecent[dateKey] = updated;

    final isSelected = _formatDate(state.selectedDate) == dateKey;
    if (!isClosed) {
      emit(state.copyWith(
        currentLog: isSelected ? updated : state.currentLog,
        recentLogs: updatedRecent,
        last7Days: analytics.last7Days,
        streakDays: analytics.streakDays,
      ));
    }
  }

  Future<void> markFardPrayerLogged(
    String prayerNameEnglish, {
    DateTime? date,
  }) async {
    try {
      final targetDate = date ?? DateTime.now();
      final prefs = await SharedPreferences.getInstance();
      final current = await _readMergedLog(prefs, targetDate);
      final updated =
          _applyPrayerNameToLog(current, prayerNameEnglish.toLowerCase());
      await _saveLogAndRefresh(updated, targetDate);
    } catch (e) {
      AppLogger.warning('Auto-sync prayer failed: $e');
    }
  }

  Future<void> markAzkarCategoryCompleted(String categoryId) async {
    if (categoryId != 'morning' && categoryId != 'evening') return;
    try {
      final today = DateTime.now();
      final prefs = await SharedPreferences.getInstance();
      final current = await _readMergedLog(prefs, today);
      if (current.morningEveningAzkar) return;
      await _saveLogAndRefresh(
        current.copyWith(morningEveningAzkar: true),
        today,
      );
    } catch (e) {
      AppLogger.warning('Auto-sync azkar failed: $e');
    }
  }

  Future<void> markQuranActivity({
    bool wirdCompleted = false,
    int? pageNumber,
  }) async {
    try {
      final today = DateTime.now();
      final prefs = await SharedPreferences.getInstance();
      var updated = await _readMergedLog(prefs, today);
      bool changed = false;

      if (wirdCompleted && !updated.quranWird) {
        updated = updated.copyWith(quranWird: true);
        changed = true;
      }
      if (pageNumber != null &&
          pageNumber >= 562 &&
          pageNumber <= 564 &&
          !updated.surahMulk) {
        updated = updated.copyWith(surahMulk: true);
        changed = true;
      }
      if (pageNumber != null &&
          pageNumber >= 293 &&
          pageNumber <= 304 &&
          today.weekday == DateTime.friday &&
          !updated.surahKahf) {
        updated = updated.copyWith(surahKahf: true);
        changed = true;
      }

      if (changed) {
        await _saveLogAndRefresh(updated, today);
      }
    } catch (e) {
      AppLogger.warning('Auto-sync Quran activity failed: $e');
    }
  }

  Future<void> toggleItem(String itemKey) async {
    final cur = state.currentLog;
    DailyWorshipLogEntity updated;

    switch (itemKey) {
      // الفروض الخمسة
      case 'fajr_fard':
        updated = cur.copyWith(fajrFard: !cur.fajrFard);
        break;
      case 'dhuhr_fard':
        updated = cur.copyWith(dhuhrFard: !cur.dhuhrFard);
        break;
      case 'asr_fard':
        updated = cur.copyWith(asrFard: !cur.asrFard);
        break;
      case 'maghrib_fard':
        updated = cur.copyWith(maghribFard: !cur.maghribFard);
        break;
      case 'isha_fard':
        updated = cur.copyWith(ishaFard: !cur.ishaFard);
        break;

      // السنن الرواتب
      case 'fajr_sunnah':
        updated = cur.copyWith(fajrSunnah: !cur.fajrSunnah);
        break;
      case 'dhuhr_sunnah_before':
        updated = cur.copyWith(dhuhrSunnahBefore: !cur.dhuhrSunnahBefore);
        break;
      case 'dhuhr_sunnah_after':
        updated = cur.copyWith(dhuhrSunnahAfter: !cur.dhuhrSunnahAfter);
        break;
      case 'maghrib_sunnah':
        updated = cur.copyWith(maghribSunnah: !cur.maghribSunnah);
        break;
      case 'isha_sunnah':
        updated = cur.copyWith(ishaSunnah: !cur.ishaSunnah);
        break;

      // النوافل
      case 'duha_prayer':
        updated = cur.copyWith(duhaPrayer: !cur.duhaPrayer);
        break;
      case 'qiyam_witr':
        updated = cur.copyWith(qiyamAndWitr: !cur.qiyamAndWitr);
        break;

      // الأوراد والفضائل
      case 'morning_evening_azkar':
        updated = cur.copyWith(morningEveningAzkar: !cur.morningEveningAzkar);
        break;
      case 'quran_wird':
        updated = cur.copyWith(quranWird: !cur.quranWird);
        break;
      case 'surah_mulk':
        updated = cur.copyWith(surahMulk: !cur.surahMulk);
        break;
      case 'surah_kahf':
        updated = cur.copyWith(surahKahf: !cur.surahKahf);
        break;
      case 'fasting_sunnah':
        updated = cur.copyWith(fastingSunnah: !cur.fastingSunnah);
        break;
      case 'daily_charity':
        updated = cur.copyWith(dailyCharity: !cur.dailyCharity);
        break;
      default:
        return;
    }

    try {
      await _saveLogAndRefresh(updated, state.selectedDate);
    } catch (e) {
      AppLogger.warning('Failed to save updated worship log: $e');
    }
  }
}
