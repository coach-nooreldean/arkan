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
  final bool isLoading;
  final String? error;

  const WorshipTrackerState({
    required this.selectedDate,
    required this.currentLog,
    this.recentLogs = const {},
    this.isLoading = false,
    this.error,
  });

  WorshipTrackerState copyWith({
    DateTime? selectedDate,
    DailyWorshipLogEntity? currentLog,
    Map<String, DailyWorshipLogEntity>? recentLogs,
    bool? isLoading,
    String? error,
  }) {
    return WorshipTrackerState(
      selectedDate: selectedDate ?? this.selectedDate,
      currentLog: currentLog ?? this.currentLog,
      recentLogs: recentLogs ?? this.recentLogs,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        selectedDate,
        currentLog,
        recentLogs,
        isLoading,
        error,
      ];
}

class WorshipTrackerCubit extends Cubit<WorshipTrackerState> {
  static const String _keyPrefix = 'islamic_worship_log_';

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

  Future<void> loadLogForDate(DateTime date) async {
    final dateKey = _formatDate(date);
    emit(state.copyWith(selectedDate: date, isLoading: true, error: null));

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString('$_keyPrefix$dateKey');

      DailyWorshipLogEntity log = DailyWorshipLogEntity(dateKey: dateKey);
      if (jsonStr != null) {
        try {
          final map = jsonDecode(jsonStr) as Map<String, dynamic>;
          log = DailyWorshipLogEntity.fromJson(map);
        } catch (_) {}
      }



      final updatedRecent = Map<String, DailyWorshipLogEntity>.from(state.recentLogs);
      updatedRecent[dateKey] = log;

      emit(state.copyWith(
        selectedDate: date,
        currentLog: log,
        recentLogs: updatedRecent,
        isLoading: false,
      ));
    } catch (e) {
      AppLogger.warning('Failed to load daily worship log: $e');
      emit(state.copyWith(isLoading: false, error: e.toString()));
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

    final dateKey = cur.dateKey;
    final updatedRecent = Map<String, DailyWorshipLogEntity>.from(state.recentLogs);
    updatedRecent[dateKey] = updated;

    emit(state.copyWith(currentLog: updated, recentLogs: updatedRecent));

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_keyPrefix$dateKey', jsonEncode(updated.toJson()));
    } catch (e) {
      AppLogger.warning('Failed to save updated worship log: $e');
    }
  }
}
