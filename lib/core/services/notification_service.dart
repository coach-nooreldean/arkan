import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:universal_io/io.dart';
import '../../features/islamic_hub/domain/entities/islamic_settings_entity.dart';
import '../utils/app_logger.dart';

class NotificationService {
  static NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static set instance(NotificationService mockInstance) => _instance = mockInstance;

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  void Function(String payload)? onNotificationTap;

  static const List<String> _legacyPrayerChannelIds = [
    'prayer_channel_makkah_v3',
    'prayer_channel_madinah_v3',
    'prayer_channel_egypt_v3',
    'prayer_channel_takbeerat_v3',
    'prayer_channel_notification_v3',
    'prayer_channel_silent_v3',
  ];

  void _configureLocalTimeZone() {
    tz.initializeTimeZones();
    final now = DateTime.now();
    final localOffset = now.timeZoneOffset;
    final localAbbr = now.timeZoneName;
    final locations = tz.timeZoneDatabase.locations;

    const preferredRegions = [
      'Africa/Cairo',
      'Asia/Riyadh',
      'Asia/Dubai',
      'Asia/Kuwait',
      'Asia/Qatar',
      'Asia/Bahrain',
      'Asia/Muscat',
      'Asia/Amman',
      'Asia/Beirut',
      'Asia/Baghdad',
      'Africa/Casablanca',
      'Africa/Tunis',
      'Africa/Algiers',
      'Europe/Istanbul',
      'Europe/London',
      'UTC',
    ];

    for (final name in preferredRegions) {
      final loc = locations[name];
      if (loc != null && loc.currentTimeZone.offset == localOffset) {
        tz.setLocalLocation(loc);
        return;
      }
    }

    for (final loc in locations.values) {
      final zone = loc.currentTimeZone;
      if (zone.offset == localOffset && zone.abbreviation == localAbbr) {
        tz.setLocalLocation(loc);
        return;
      }
    }

    for (final loc in locations.values) {
      if (loc.currentTimeZone.offset == localOffset) {
        tz.setLocalLocation(loc);
        return;
      }
    }
  }

  Future<void> init({bool requestPermissions = true}) async {
    try {
      _configureLocalTimeZone();

      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/launcher_icon');

      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const LinuxInitializationSettings linuxSettings =
          LinuxInitializationSettings(
        defaultActionName: 'Open notification',
      );

      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
        linux: linuxSettings,
      );

      await _notificationsPlugin.initialize(
        settings: settings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          if (response.actionId == 'stop_adhan') return;
          final payload = response.payload;
          if (payload != null && payload.isNotEmpty) {
            onNotificationTap?.call(payload);
          }
        },
      );

      if (!kIsWeb && Platform.isAndroid) {
        final androidPlugin = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

        if (androidPlugin != null) {
          for (final legacyId in _legacyPrayerChannelIds) {
            try {
              await androidPlugin.deleteNotificationChannel(channelId: legacyId);
            } catch (_) {}
          }

          const prayerMakkahChannel = AndroidNotificationChannel(
            'prayer_channel_makkah_v4',
            'مواقيت الصلاة (أذان مكة)',
            description: 'تنبيهات الأذان بصوت الحرم المكي الشريف',
            importance: Importance.max,
            sound: RawResourceAndroidNotificationSound('adhan_makkah'),
            playSound: true,
            enableVibration: true,
            audioAttributesUsage: AudioAttributesUsage.alarm,
          );

          const prayerMadinahChannel = AndroidNotificationChannel(
            'prayer_channel_madinah_v4',
            'مواقيت الصلاة (أذان المدينة)',
            description: 'تنبيهات الأذان بصوت المسجد النبوي الشريف',
            importance: Importance.max,
            sound: RawResourceAndroidNotificationSound('adhan_madinah'),
            playSound: true,
            enableVibration: true,
            audioAttributesUsage: AudioAttributesUsage.alarm,
          );

          const prayerEgyptChannel = AndroidNotificationChannel(
            'prayer_channel_egypt_v4',
            'مواقيت الصلاة (أذان مصر)',
            description: 'تنبيهات الأذان بصوت كروان مصر الشيخ محمد رفعت',
            importance: Importance.max,
            sound: RawResourceAndroidNotificationSound('adhan_egypt'),
            playSound: true,
            enableVibration: true,
            audioAttributesUsage: AudioAttributesUsage.alarm,
          );

          const prayerTakbeeratChannel = AndroidNotificationChannel(
            'prayer_channel_takbeerat_v4',
            'مواقيت الصلاة (تكبيرات الأذان)',
            description: 'تنبيهات تكبيرات الأذان فقط',
            importance: Importance.max,
            sound: RawResourceAndroidNotificationSound('adhan_takbeerat'),
            playSound: true,
            enableVibration: true,
            audioAttributesUsage: AudioAttributesUsage.alarm,
          );

          const prayerNotificationChannel = AndroidNotificationChannel(
            'prayer_channel_notification_v4',
            'مواقيت الصلاة (تنبيه مقتضب)',
            description: 'نغمة تنبيه هادئة ومقتضبة عند دخول وقت الصلاة',
            importance: Importance.high,
            playSound: true,
            enableVibration: true,
            audioAttributesUsage: AudioAttributesUsage.alarm,
          );

          const prayerSilentChannel = AndroidNotificationChannel(
            'prayer_channel_silent_v4',
            'مواقيت الصلاة (صامت)',
            description: 'إشعار مرئي بدون صوت لمواقيت الصلاة',
            importance: Importance.low,
            playSound: false,
            enableVibration: false,
          );

          const azkarChannel = AndroidNotificationChannel(
            'azkar_reminders_channel',
            'تذكيرات الأذكار والورد',
            description: 'تذكيرات أذكار الصباح والمساء والنوم',
            importance: Importance.high,
            playSound: true,
            enableVibration: true,
          );

          await androidPlugin.createNotificationChannel(prayerMakkahChannel);
          await androidPlugin.createNotificationChannel(prayerMadinahChannel);
          await androidPlugin.createNotificationChannel(prayerEgyptChannel);
          await androidPlugin.createNotificationChannel(prayerTakbeeratChannel);
          await androidPlugin.createNotificationChannel(prayerNotificationChannel);
          await androidPlugin.createNotificationChannel(prayerSilentChannel);
          await androidPlugin.createNotificationChannel(azkarChannel);

          if (requestPermissions) {
            try {
              await androidPlugin.requestNotificationsPermission();
            } catch (e) {
              AppLogger.warning('Could not request notification permission: $e');
            }
            try {
              final canExact =
                  await androidPlugin.canScheduleExactNotifications() ?? false;
              if (!canExact) {
                await androidPlugin.requestExactAlarmsPermission();
              }
            } catch (e) {
              AppLogger.warning('Could not request exact alarms permission: $e');
            }
          }
        }
      }

      if (requestPermissions && !kIsWeb && Platform.isIOS) {
        final iosPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
        if (iosPlugin != null) {
          try {
            await iosPlugin.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
          } catch (e) {
            AppLogger.warning('Could not request iOS notification permission: $e');
          }
        }
      }

      _initialized = true;
    } catch (e) {
      AppLogger.warning('Error initializing NotificationService: $e');
    }
  }

  NotificationDetails _buildPrayerNotificationDetails({
    required String azanSound,
  }) {
    String channelId;
    String channelName;
    AndroidNotificationSound? androidSound;
    String? iosSound;
    bool isSilent = false;

    switch (azanSound) {
      case 'makkah':
        channelId = 'prayer_channel_makkah_v4';
        channelName = 'مواقيت الصلاة (أذان مكة)';
        androidSound = const RawResourceAndroidNotificationSound('adhan_makkah');
        iosSound = 'adhan_makkah.mp3';
        break;
      case 'madinah':
        channelId = 'prayer_channel_madinah_v4';
        channelName = 'مواقيت الصلاة (أذان المدينة)';
        androidSound = const RawResourceAndroidNotificationSound('adhan_madinah');
        iosSound = 'adhan_madinah.mp3';
        break;
      case 'egypt':
        channelId = 'prayer_channel_egypt_v4';
        channelName = 'مواقيت الصلاة (أذان مصر)';
        androidSound = const RawResourceAndroidNotificationSound('adhan_egypt');
        iosSound = 'adhan_egypt.mp3';
        break;
      case 'takbeerat_only':
      case 'takbeerat':
        channelId = 'prayer_channel_takbeerat_v4';
        channelName = 'مواقيت الصلاة (تكبيرات الأذان)';
        androidSound = const RawResourceAndroidNotificationSound('adhan_takbeerat');
        iosSound = 'adhan_takbeerat.mp3';
        break;
      case 'notification_only':
        channelId = 'prayer_channel_notification_v4';
        channelName = 'مواقيت الصلاة (تنبيه مقتضب)';
        androidSound = null;
        iosSound = null;
        break;
      case 'silent':
      default:
        channelId = 'prayer_channel_silent_v4';
        channelName = 'مواقيت الصلاة (صامت)';
        androidSound = null;
        iosSound = null;
        isSilent = true;
        break;
    }

    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: 'تنبيهات مواقيت الصلاة والأذان في موعدها بدقة',
        importance: isSilent ? Importance.low : Importance.max,
        priority: isSilent ? Priority.low : Priority.max,
        playSound: !isSilent,
        sound: androidSound,
        enableVibration: !isSilent,
        fullScreenIntent: !isSilent,
        category: AndroidNotificationCategory.alarm,
        audioAttributesUsage: AudioAttributesUsage.alarm,
        visibility: NotificationVisibility.public,
        actions: isSilent
            ? null
            : const [
                AndroidNotificationAction(
                  'stop_adhan',
                  'إيقاف الصوت',
                  cancelNotification: true,
                  showsUserInterface: false,
                ),
              ],
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: !isSilent,
        presentBadge: true,
        presentSound: !isSilent,
        sound: isSilent ? null : iosSound,
        presentBanner: !isSilent,
        presentList: true,
        interruptionLevel: InterruptionLevel.timeSensitive,
      ),
      linux: const LinuxNotificationDetails(
        urgency: LinuxNotificationUrgency.critical,
      ),
    );
  }

  Future<AndroidScheduleMode> _preferredScheduleMode() async {
    if (!kIsWeb && Platform.isAndroid) {
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      final canExact =
          await androidPlugin?.canScheduleExactNotifications() ?? false;
      if (canExact) {
        return AndroidScheduleMode.exactAllowWhileIdle;
      }
    }
    return AndroidScheduleMode.inexactAllowWhileIdle;
  }

  Future<void> cancelNotifications(List<int> ids) async {
    for (final id in ids) {
      await _notificationsPlugin.cancel(id: id);
    }
  }

  Future<void> cancelPrayerNotifications() async {
    final ids = <int>[
      ...List<int>.generate(60, (i) => 8000 + i), // Azan
      ...List<int>.generate(60, (i) => 8200 + i), // Pre-Azan
      ...List<int>.generate(60, (i) => 8400 + i), // Iqamah
    ];
    await cancelNotifications(ids);
  }

  Future<void> schedulePrayerNotification({
    required int id,
    required String prayerNameArabic,
    required DateTime prayerTime,
    String azanSound = 'makkah',
  }) async {
    if (kIsWeb || (!kIsWeb && (Platform.isLinux || Platform.isWindows))) {
      return;
    }
    try {
      if (!_initialized) {
        await init(requestPermissions: false);
      }

      final now = tz.TZDateTime.now(tz.local);
      final scheduledDate = tz.TZDateTime.from(prayerTime, tz.local);

      if (scheduledDate.isBefore(now)) {
        return;
      }

      final scheduleMode = await _preferredScheduleMode();

      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: 'حان الآن موعد أذان $prayerNameArabic',
        body: 'الله أكبر، الله أكبر .. حيّ على الصلاة، حيّ على الفلاح',
        scheduledDate: scheduledDate,
        notificationDetails: _buildPrayerNotificationDetails(azanSound: azanSound),
        payload: jsonEncode({
          'route': '/prayer-times',
          'action': 'prayer_checkin',
          'prayer': prayerNameArabic,
        }),
        androidScheduleMode: scheduleMode,
      );
      AppLogger.info(
        '🕌 [PrayerNotification] Scheduled $prayerNameArabic at $scheduledDate (ID: $id, Sound: $azanSound, Mode: $scheduleMode)',
      );
    } catch (e) {
      AppLogger.warning('Failed to schedule prayer notification for $prayerNameArabic: $e');
    }
  }

  Future<void> schedulePrayerAuxiliaryNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    if (kIsWeb || (!kIsWeb && (Platform.isLinux || Platform.isWindows))) {
      return;
    }
    try {
      if (!_initialized) {
        await init(requestPermissions: false);
      }
      final now = tz.TZDateTime.now(tz.local);
      final scheduledDate = tz.TZDateTime.from(scheduledTime, tz.local);
      if (scheduledDate.isBefore(now)) {
        return;
      }
      final scheduleMode = await _preferredScheduleMode();

      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'prayer_channel_notification_v4',
            'مواقيت الصلاة (تنبيه مقتضب)',
            channelDescription: 'تنبيهات الاستعداد للصلاة والإقامة',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: payload ?? jsonEncode({'route': '/prayer-times'}),
        androidScheduleMode: scheduleMode,
      );
    } catch (e) {
      AppLogger.warning('Failed to schedule auxiliary prayer notification: $e');
    }
  }

  Future<bool> showTestPrayerNotification({required String azanSound}) async {
    if (kIsWeb || (!kIsWeb && (Platform.isLinux || Platform.isWindows))) {
      return false;
    }
    try {
      if (!_initialized) {
        await init(requestPermissions: true);
      }
      if (!kIsWeb && Platform.isAndroid) {
        final androidPlugin = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        final enabled = await androidPlugin?.areNotificationsEnabled() ?? true;
        if (!enabled) {
          await androidPlugin?.requestNotificationsPermission();
        }
      }
      await _notificationsPlugin.show(
        id: 8999,
        title: 'تجربة تنبيه الأذان 🕌',
        body: 'الله أكبر، الله أكبر .. تنبيه الأذان يعمل بنجاح',
        notificationDetails: _buildPrayerNotificationDetails(azanSound: azanSound),
        payload: jsonEncode({'route': '/prayer-times'}),
      );
      return true;
    } catch (e) {
      AppLogger.warning('Failed to show test prayer notification: $e');
      return false;
    }
  }

  Future<void> scheduleAzkarReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
    DateTimeComponents matchDateTimeComponents = DateTimeComponents.time,
    DateTime? firstScheduledDate,
  }) async {
    if (kIsWeb || (!kIsWeb && (Platform.isLinux || Platform.isWindows))) {
      return;
    }
    try {
      if (!_initialized) {
        await init(requestPermissions: false);
      }
      final now = tz.TZDateTime.now(tz.local);
      tz.TZDateTime scheduledDate;
      if (firstScheduledDate != null) {
        scheduledDate = tz.TZDateTime.from(firstScheduledDate, tz.local);
        while (scheduledDate.isBefore(now)) {
          scheduledDate = scheduledDate.add(const Duration(days: 7));
        }
      } else {
        scheduledDate = tz.TZDateTime(
          tz.local,
          now.year,
          now.month,
          now.day,
          hour,
          minute,
        );
        if (scheduledDate.isBefore(now)) {
          scheduledDate = scheduledDate.add(const Duration(days: 1));
        }
      }

      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'azkar_reminders_channel',
            'تذكيرات الأذكار والورد',
            channelDescription: 'تنبيهات أذكار اليوم والورد القرآني',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: payload,
        matchDateTimeComponents: matchDateTimeComponents,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (e) {
      AppLogger.warning('Failed to schedule azkar reminder: $e');
    }
  }

  Future<void> syncSmartReminders(IslamicSettingsEntity settings) async {
    if (kIsWeb || (!kIsWeb && (Platform.isLinux || Platform.isWindows))) {
      return;
    }
    try {
      await cancelNotifications(const [9101, 9102, 9103, 9104, 9105]);
      if (!settings.isEnabled) return;

      if (settings.morningAzkarReminderEnabled) {
        await scheduleAzkarReminder(
          id: 9101,
          title: 'أذكار الصباح ☀️',
          body: 'حصّن يومك بذكر الله وقراءة أذكار الصباح',
          hour: settings.morningAzkarHour,
          minute: settings.morningAzkarMinute,
          payload: jsonEncode({'route': '/azkar/reader/morning'}),
        );
      }

      if (settings.eveningAzkarReminderEnabled) {
        await scheduleAzkarReminder(
          id: 9102,
          title: 'أذكار المساء 🌙',
          body: 'موعد أذكار المساء.. ألا بذكر الله تطمئن القلوب',
          hour: settings.eveningAzkarHour,
          minute: settings.eveningAzkarMinute,
          payload: jsonEncode({'route': '/azkar/reader/evening'}),
        );
      }

      if (settings.sleepAzkarReminderEnabled) {
        await scheduleAzkarReminder(
          id: 9103,
          title: 'أذكار النوم والملك 🛌',
          body: 'لا تنسَ أذكار النوم وسورة الملك قبل المنام',
          hour: settings.sleepAzkarHour,
          minute: settings.sleepAzkarMinute,
          payload: jsonEncode({'route': '/azkar/reader/sleep'}),
        );
      }

      if (settings.quranWirdReminderEnabled) {
        await scheduleAzkarReminder(
          id: 9104,
          title: 'الورد القرآني اليومي 📖',
          body: 'تذكير بقراءة وردك اليومي من كتاب الله',
          hour: settings.quranWirdHour,
          minute: settings.quranWirdMinute,
          payload: jsonEncode({'route': '/quran/read'}),
        );
      }

      if (settings.fridayKahfReminderEnabled) {
        final now = DateTime.now();
        var nextFriday = DateTime(now.year, now.month, now.day, 10, 30);
        while (nextFriday.weekday != DateTime.friday || nextFriday.isBefore(now)) {
          nextFriday = nextFriday.add(const Duration(days: 1));
        }
        await scheduleAzkarReminder(
          id: 9105,
          title: 'نور ما بين الجمعتين 🕌',
          body: 'لا تنسَ قراءة سورة الكهف والإكثار من الصلاة على النبي ﷺ',
          hour: 10,
          minute: 30,
          payload: jsonEncode({'route': '/quran/read'}),
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          firstScheduledDate: nextFriday,
        );
      }
    } catch (e) {
      AppLogger.warning('Failed to sync smart reminders: $e');
    }
  }
}
