import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:universal_io/io.dart';
import '../../domain/entities/prayer_time_entity.dart';
import '../../domain/entities/prayer_log_entity.dart';
import '../../domain/repositories/islamic_hub_repository.dart';
import '../../../../core/services/home_widget_sync_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/utils/app_logger.dart';

import '../../domain/entities/islamic_settings_entity.dart';

enum PrayerTimesStatus { initial, loading, loaded, error }

class PrayerTimesState extends Equatable {
  final PrayerTimesStatus status;
  final DayPrayerTimes? dayPrayerTimes;
  final List<PrayerLogEntity> todayLogs;
  final PrayerTimeItem? nextPrayer;
  final Duration remainingTimeToNext;
  final String? errorMessage;
  final PrayerTimeItem? pendingCheckinPrayer;
  final int earnedCoinsLastAction;

  const PrayerTimesState({
    this.status = PrayerTimesStatus.initial,
    this.dayPrayerTimes,
    this.todayLogs = const [],
    this.nextPrayer,
    this.remainingTimeToNext = Duration.zero,
    this.errorMessage,
    this.pendingCheckinPrayer,
    this.earnedCoinsLastAction = 0,
  });

  PrayerTimesState copyWith({
    PrayerTimesStatus? status,
    DayPrayerTimes? dayPrayerTimes,
    List<PrayerLogEntity>? todayLogs,
    PrayerTimeItem? nextPrayer,
    Duration? remainingTimeToNext,
    String? errorMessage,
    PrayerTimeItem? pendingCheckinPrayer,
    int? earnedCoinsLastAction,
    bool clearPendingCheckin = false,
  }) {
    return PrayerTimesState(
      status: status ?? this.status,
      dayPrayerTimes: dayPrayerTimes ?? this.dayPrayerTimes,
      todayLogs: todayLogs ?? this.todayLogs,
      nextPrayer: nextPrayer ?? this.nextPrayer,
      remainingTimeToNext: remainingTimeToNext ?? this.remainingTimeToNext,
      errorMessage: errorMessage ?? this.errorMessage,
      pendingCheckinPrayer: clearPendingCheckin
          ? null
          : (pendingCheckinPrayer ?? this.pendingCheckinPrayer),
      earnedCoinsLastAction: earnedCoinsLastAction ?? this.earnedCoinsLastAction,
    );
  }

  bool isPrayerCompleted(String prayerName) {
    return todayLogs.any((log) => log.prayerName.toLowerCase() == prayerName.toLowerCase());
  }

  bool? isPrayerOnTime(String prayerName) {
    final match = todayLogs.where((l) => l.prayerName.toLowerCase() == prayerName.toLowerCase()).firstOrNull;
    return match?.isOnTime;
  }

  @override
  List<Object?> get props => [
        status,
        dayPrayerTimes,
        todayLogs,
        nextPrayer,
        remainingTimeToNext,
        errorMessage,
        pendingCheckinPrayer,
        earnedCoinsLastAction,
      ];
}

class PrayerTimesCubit extends Cubit<PrayerTimesState> {
  final IslamicHubRepository _repository;
  Timer? _countdownTimer;
  StreamSubscription<IslamicSettingsEntity>? _settingsSubscription;
  IslamicSettingsEntity? _lastSettings;
  bool _isLoading = false;
  bool _pendingReload = false;
  int _scheduleGeneration = 0;
  AudioPlayer? _foregroundAudioPlayer;
  final Set<String> _playedForegroundAdhanKeys = {};

  PrayerTimesCubit({required IslamicHubRepository repository})
      : _repository = repository,
        super(const PrayerTimesState()) {
    _startCountdownTimer();
    loadPrayerTimes();
    _subscribeToSettings();
  }

  void _subscribeToSettings() {
    _settingsSubscription?.cancel();
    _settingsSubscription = _repository.watchSettings().listen((settings) {
      if (!isClosed) {
        if (_lastSettings == null) {
          _lastSettings = settings;
          return; // Initial value already handled by constructor
        }

        final hasChanged = _lastSettings!.selectedCity != settings.selectedCity ||
            _lastSettings!.selectedCountry != settings.selectedCountry ||
            _lastSettings!.calculationMethod != settings.calculationMethod ||
            _lastSettings!.customLatitude != settings.customLatitude ||
            _lastSettings!.customLongitude != settings.customLongitude ||
            _lastSettings!.azanSound != settings.azanSound ||
            _lastSettings!.isEnabled != settings.isEnabled ||
            _lastSettings!.asrJuristicMethod != settings.asrJuristicMethod ||
            _lastSettings!.preAzanReminderMinutes != settings.preAzanReminderMinutes ||
            _lastSettings!.iqamahReminderMinutes != settings.iqamahReminderMinutes ||
            !mapEquals(_lastSettings!.prayerMinuteOffsets, settings.prayerMinuteOffsets) ||
            !mapEquals(_lastSettings!.perPrayerAzanSound, settings.perPrayerAzanSound);

        _lastSettings = settings;
        if (hasChanged) {
          loadPrayerTimes();
        }
      }
    });
  }

  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateNextPrayerAndCountdown();
    });
  }

  @override
  Future<void> close() {
    _countdownTimer?.cancel();
    _settingsSubscription?.cancel();
    _foregroundAudioPlayer?.dispose();
    return super.close();
  }

  Future<void> loadPrayerTimes({String? userId, DateTime? date}) async {
    if (isClosed) return;
    if (_isLoading) {
      _pendingReload = true;
      return;
    }
    _isLoading = true;
    try {
      // If state already has prayer times, keep them while loading
      if (state.dayPrayerTimes == null) {
        emit(state.copyWith(status: PrayerTimesStatus.loading));
      }
      final targetDate = date ?? DateTime.now();
      final activeUserId = userId?.isNotEmpty == true ? userId! : 'local_user';

      final result = await _repository.getPrayerTimes(date: targetDate);
      if (isClosed) return;

    await result.fold(
      (err) async {
        if (isClosed) return;
        if (state.dayPrayerTimes == null) {
          emit(state.copyWith(
            status: PrayerTimesStatus.error,
            errorMessage: err,
          ));
        }
      },
      (times) async {
        if (isClosed) return;
        List<PrayerLogEntity> logs = [];
        if (activeUserId.isNotEmpty) {
          final logResult = await _repository.getPrayerLogs(activeUserId, targetDate);
          logs = logResult.getOrElse((_) => []);
        } else if (state.todayLogs.isNotEmpty) {
          logs = state.todayLogs;
        }
        if (isClosed) return;

        // Apply completion status to items
        final updatedPrayers = times.prayers.map((p) {
          final completed = logs.any((l) => l.prayerName.toLowerCase() == p.nameEnglish.toLowerCase());
          final onTime = logs.where((l) => l.prayerName.toLowerCase() == p.nameEnglish.toLowerCase()).firstOrNull?.isOnTime ?? false;
          return p.copyWith(isCompleted: completed, isOnTime: onTime);
        }).toList();

        final updatedDayTimes = DayPrayerTimes(
          date: times.date,
          hijriDate: times.hijriDate,
          hijriDay: times.hijriDay,
          hijriMonth: times.hijriMonth,
          hijriYear: times.hijriYear,
          prayers: updatedPrayers,
          locationName: times.locationName,
        );

        if (!isClosed) {
          emit(state.copyWith(
            status: PrayerTimesStatus.loaded,
            dayPrayerTimes: updatedDayTimes,
            todayLogs: logs,
          ));

          _updateNextPrayerAndCountdown();
          _checkPendingPrayerCheckin(updatedDayTimes, logs);
          _scheduleBackgroundPrayerNotifications(updatedDayTimes);
          unawaited(
            HomeWidgetSyncService.syncTodayPrayerTimes(
              updatedDayTimes,
              updatedDayTimes.nextPrayer,
            ),
          );
        }
      },
    );
    } finally {
      _isLoading = false;
      if (_pendingReload && !isClosed) {
        _pendingReload = false;
        unawaited(loadPrayerTimes(userId: userId, date: date));
      }
    }
  }

  Future<void> _scheduleBackgroundPrayerNotifications(DayPrayerTimes? todayTimes) async {
    final generation = ++_scheduleGeneration;
    try {
      final settings = await _repository.getSettings();
      if (generation != _scheduleGeneration || isClosed) return;

      final notificationService = NotificationService();
      await notificationService.cancelPrayerNotifications();
      if (generation != _scheduleGeneration || isClosed) return;

      if (!settings.isEnabled) {
        AppLogger.info('🕌 [PrayerTimesCubit] Islamic notifications disabled - skipped scheduling.');
        return;
      }

      final now = DateTime.now();
      int slot = 0;

      // Schedule for today (day 0) and the next 6 days (days 1..6)
      for (int dayOffset = 0; dayOffset < 7; dayOffset++) {
        if (generation != _scheduleGeneration || isClosed) return;
        final targetDate = now.add(Duration(days: dayOffset));
        DayPrayerTimes dayTimes;
        if (dayOffset == 0 && todayTimes != null) {
          dayTimes = todayTimes;
        } else {
          final result = await _repository.getPrayerTimes(date: targetDate);
          if (generation != _scheduleGeneration || isClosed) return;
          dayTimes = result.getOrElse((_) => todayTimes ?? DayPrayerTimes(
            date: targetDate,
            hijriDate: '',
            hijriDay: '',
            hijriMonth: '',
            hijriYear: '',
            prayers: const [],
            locationName: settings.selectedCity,
          ));
        }

        for (final p in dayTimes.prayers) {
          if (p.type != PrayerType.sunrise) {
            final prayerKey = p.nameEnglish.toLowerCase();
            final effectiveSound = settings.perPrayerAzanSound[prayerKey] ?? settings.azanSound;
            final prayerDateTime = DateTime(
              targetDate.year,
              targetDate.month,
              targetDate.day,
              p.time.hour,
              p.time.minute,
            );

            if (effectiveSound != 'silent' && prayerDateTime.isAfter(now)) {
              await notificationService.schedulePrayerNotification(
                id: 8000 + slot,
                prayerNameArabic: p.nameArabic,
                prayerTime: prayerDateTime,
                azanSound: effectiveSound,
              );
              if (generation != _scheduleGeneration || isClosed) return;
            }

            if (settings.preAzanReminderMinutes > 0) {
              final preTime = prayerDateTime.subtract(
                Duration(minutes: settings.preAzanReminderMinutes),
              );
              if (preTime.isAfter(now)) {
                await notificationService.schedulePrayerAuxiliaryNotification(
                  id: 8200 + slot,
                  title: 'اقترب أذان ${p.nameArabic}',
                  body: 'متبقي ${settings.preAzanReminderMinutes} دقائق على أذان ${p.nameArabic}',
                  scheduledTime: preTime,
                );
                if (generation != _scheduleGeneration || isClosed) return;
              }
            }

            if (settings.iqamahReminderMinutes > 0) {
              final iqamahTime = prayerDateTime.add(
                Duration(minutes: settings.iqamahReminderMinutes),
              );
              if (iqamahTime.isAfter(now)) {
                await notificationService.schedulePrayerAuxiliaryNotification(
                  id: 8400 + slot,
                  title: 'موعد إقامة صلاة ${p.nameArabic}',
                  body: 'حيّ على الصلاة.. حان وقت إقامة صلاة ${p.nameArabic}',
                  scheduledTime: iqamahTime,
                );
                if (generation != _scheduleGeneration || isClosed) return;
              }
            }

            slot++;
          }
        }
      }
      AppLogger.info('🕌 [PrayerTimesCubit] Scheduled upcoming prayers for 7 days (slots: $slot)');
    } catch (e) {
      AppLogger.warning('Could not schedule prayer notifications in cubit: $e');
    }
  }

  void _updateNextPrayerAndCountdown() {
    final dayTimes = state.dayPrayerTimes;
    if (dayTimes == null || dayTimes.prayers.isEmpty) return;

    final now = DateTime.now();
    PrayerTimeItem? next;
    Duration remaining = Duration.zero;

    for (final p in dayTimes.prayers) {
      if (p.type != PrayerType.sunrise && p.time.isAfter(now)) {
        next = p;
        remaining = p.time.difference(now);
        break;
      }
    }

    if (next == null) {
      // All passed today, tomorrow's first prayer
      next = dayTimes.prayers.first;
      final tomorrowFajr = next.time.add(const Duration(days: 1));
      remaining = tomorrowFajr.difference(now);
    }

    if (!isClosed) {
      emit(state.copyWith(
        nextPrayer: next,
        remainingTimeToNext: remaining,
      ));
      _checkForegroundAdhanFallback(dayTimes, now);
      if (state.pendingCheckinPrayer == null && state.dayPrayerTimes != null) {
        _checkPendingPrayerCheckin(state.dayPrayerTimes!, state.todayLogs);
      }
    }
  }

  void _checkForegroundAdhanFallback(DayPrayerTimes dayTimes, DateTime now) {
    final isDesktopOrWeb =
        kIsWeb || (!kIsWeb && (Platform.isLinux || Platform.isWindows));
    if (!isDesktopOrWeb) return;
    final settings = _lastSettings;
    if (settings == null || !settings.isEnabled) {
      return;
    }

    for (final p in dayTimes.prayers) {
      if (p.type == PrayerType.sunrise) continue;
      final effectiveSound =
          settings.perPrayerAzanSound[p.nameEnglish.toLowerCase()] ?? settings.azanSound;
      if (effectiveSound == 'silent') continue;
      if (p.time.year == now.year &&
          p.time.month == now.month &&
          p.time.day == now.day &&
          p.time.hour == now.hour &&
          p.time.minute == now.minute &&
          now.second < 5) {
        final key = '${now.year}-${now.month}-${now.day}_${p.nameEnglish}';
        if (_playedForegroundAdhanKeys.add(key)) {
          unawaited(_playForegroundAdhan(effectiveSound));
        }
      }
    }
  }

  Future<void> _playForegroundAdhan(String azanSound) async {
    try {
      String assetPath;
      switch (azanSound) {
        case 'makkah':
          assetPath = 'audio/adhan_makkah.mp3';
          break;
        case 'madinah':
          assetPath = 'audio/adhan_madinah.mp3';
          break;
        case 'egypt':
          assetPath = 'audio/adhan_egypt.mp3';
          break;
        case 'takbeerat_only':
        case 'takbeerat':
          assetPath = 'audio/adhan_takbeerat.mp3';
          break;
        case 'notification_only':
        default:
          assetPath = 'audio/ui_success.mp3';
          break;
      }
      _foregroundAudioPlayer ??= AudioPlayer();
      await _foregroundAudioPlayer!.stop();
      await _foregroundAudioPlayer!.play(AssetSource(assetPath));
    } catch (e) {
      AppLogger.warning('Foreground Adhan playback failed: $e');
    }
  }

  final Set<String> _promptedPrayerKeys = {};

  void _checkPendingPrayerCheckin(DayPrayerTimes dayTimes, List<PrayerLogEntity> logs) {
    if (isClosed) return;
    if (_lastSettings != null && !_lastSettings!.isEnabled) return;
    final now = DateTime.now();
    // Find the latest passed prayer (excluding sunrise) that has NOT been logged
    for (final p in dayTimes.prayers.reversed) {
      if (p.type != PrayerType.sunrise && p.time.isBefore(now)) {
        final isLogged = logs.any((l) => l.prayerName.toLowerCase() == p.nameEnglish.toLowerCase());
        if (!isLogged) {
          final dateKey = '${p.time.year}-${p.time.month}-${p.time.day}_${p.nameEnglish.toLowerCase()}';
          if (_promptedPrayerKeys.contains(dateKey)) {
            continue;
          }
          _promptedPrayerKeys.add(dateKey);
          if (!isClosed) {
            emit(state.copyWith(pendingCheckinPrayer: p));
          }
          return;
        }
      }
    }
  }

  void dismissPendingCheckin() {
    if (isClosed) return;
    emit(state.copyWith(clearPendingCheckin: true));
  }

  Future<int> recordPrayer({
    required String userId,
    required PrayerTimeItem prayer,
    required bool isOnTime,
  }) async {
    final now = DateTime.now();
    final activeUserId = userId.isNotEmpty ? userId : 'local_user';

    // ── ANTI-CHEAT GUARD 1: Prevent recording future prayers ──
    if (prayer.time.isAfter(now)) {
      AppLogger.warning('Anti-cheat: Attempted to record a future prayer (${prayer.nameEnglish}) before its time');
      return 0;
    }

    // ── ANTI-CHEAT GUARD 2: Prevent duplicate recording ──
    if (state.isPrayerCompleted(prayer.nameEnglish)) {
      AppLogger.warning('Anti-cheat: Prayer ${prayer.nameEnglish} already recorded for today');
      return 0;
    }

    final result = await _repository.recordPrayer(
      userId: activeUserId,
      prayerName: prayer.nameEnglish,
      prayerDate: prayer.time,
      isOnTime: isOnTime,
    );

    int coins = 0;
    result.fold(
      (err) => null,
      (log) {
        coins = log.coinsEarned;
        final updatedLogs = [...state.todayLogs.where((l) => l.prayerName != log.prayerName), log];

        // Update prayers in dayPrayerTimes
        if (state.dayPrayerTimes != null) {
          final updatedPrayers = state.dayPrayerTimes!.prayers.map((p) {
            if (p.nameEnglish.toLowerCase() == prayer.nameEnglish.toLowerCase()) {
              return p.copyWith(isCompleted: true, isOnTime: isOnTime);
            }
            return p;
          }).toList();

          final updatedDay = DayPrayerTimes(
            date: state.dayPrayerTimes!.date,
            hijriDate: state.dayPrayerTimes!.hijriDate,
            hijriDay: state.dayPrayerTimes!.hijriDay,
            hijriMonth: state.dayPrayerTimes!.hijriMonth,
            hijriYear: state.dayPrayerTimes!.hijriYear,
            prayers: updatedPrayers,
            locationName: state.dayPrayerTimes!.locationName,
          );

          emit(state.copyWith(
            dayPrayerTimes: updatedDay,
            todayLogs: updatedLogs,
            clearPendingCheckin: true,
            earnedCoinsLastAction: coins,
          ));
        }
      },
    );

    return coins;
  }
}

