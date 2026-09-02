import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:universal_io/io.dart';
import '../utils/app_logger.dart';

class NotificationService {
  static NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static set instance(NotificationService mockInstance) => _instance = mockInstance;

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init({bool requestPermissions = true}) async {
    try {
      tz.initializeTimeZones();

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
      );

      if (!kIsWeb && Platform.isAndroid) {
        final androidPlugin = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

        if (androidPlugin != null) {
          // Setup Prayer Channels
          const prayerMakkahChannel = AndroidNotificationChannel(
            'prayer_channel_makkah_v3',
            'مواقيت الصلاة (أذان مكة)',
            description: 'تنبيهات الأذان بصوت الحرم المكي الشريف',
            importance: Importance.max,
            sound: RawResourceAndroidNotificationSound('adhan_makkah'),
            playSound: true,
            enableVibration: true,
          );

          const prayerMadinahChannel = AndroidNotificationChannel(
            'prayer_channel_madinah_v3',
            'مواقيت الصلاة (أذان المدينة)',
            description: 'تنبيهات الأذان بصوت المسجد النبوي الشريف',
            importance: Importance.max,
            sound: RawResourceAndroidNotificationSound('adhan_madinah'),
            playSound: true,
            enableVibration: true,
          );

          const prayerEgyptChannel = AndroidNotificationChannel(
            'prayer_channel_egypt_v3',
            'مواقيت الصلاة (أذان مصر)',
            description: 'تنبيهات الأذان بصوت كروان مصر الشيخ محمد رفعت',
            importance: Importance.max,
            sound: RawResourceAndroidNotificationSound('adhan_egypt'),
            playSound: true,
            enableVibration: true,
          );

          const prayerTakbeeratChannel = AndroidNotificationChannel(
            'prayer_channel_takbeerat_v3',
            'مواقيت الصلاة (تكبيرات الأذان)',
            description: 'تنبيهات تكبيرات الأذان فقط',
            importance: Importance.max,
            sound: RawResourceAndroidNotificationSound('adhan_takbeerat'),
            playSound: true,
            enableVibration: true,
          );

          const prayerNotificationChannel = AndroidNotificationChannel(
            'prayer_channel_notification_v3',
            'مواقيت الصلاة (تنبيه مقتضب)',
            description: 'نغمة تنبيه هادئة ومقتضبة عند دخول وقت الصلاة',
            importance: Importance.high,
            playSound: true,
            enableVibration: true,
          );

          const prayerSilentChannel = AndroidNotificationChannel(
            'prayer_channel_silent_v3',
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
              await androidPlugin.requestExactAlarmsPermission();
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
    } catch (e) {
      AppLogger.warning('Error initializing NotificationService: $e');
    }
  }

  Future<void> cancelNotifications(List<int> ids) async {
    for (final id in ids) {
      await _notificationsPlugin.cancel(id: id);
    }
  }

  Future<void> cancelPrayerNotifications() async {
    final ids = List<int>.generate(100, (i) => 8000 + i);
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
      final now = tz.TZDateTime.now(tz.local);
      final scheduledDate = tz.TZDateTime.from(prayerTime, tz.local);

      if (scheduledDate.isBefore(now)) {
        return;
      }

      String channelId;
      String channelName;
      AndroidNotificationSound? androidSound;
      String? iosSound;
      bool isSilent = false;

      switch (azanSound) {
        case 'makkah':
          channelId = 'prayer_channel_makkah_v3';
          channelName = 'مواقيت الصلاة (أذان مكة)';
          androidSound = const RawResourceAndroidNotificationSound('adhan_makkah');
          iosSound = 'adhan_makkah.mp3';
          break;
        case 'madinah':
          channelId = 'prayer_channel_madinah_v3';
          channelName = 'مواقيت الصلاة (أذان المدينة)';
          androidSound = const RawResourceAndroidNotificationSound('adhan_madinah');
          iosSound = 'adhan_madinah.mp3';
          break;
        case 'egypt':
          channelId = 'prayer_channel_egypt_v3';
          channelName = 'مواقيت الصلاة (أذان مصر)';
          androidSound = const RawResourceAndroidNotificationSound('adhan_egypt');
          iosSound = 'adhan_egypt.mp3';
          break;
        case 'takbeerat_only':
        case 'takbeerat':
          channelId = 'prayer_channel_takbeerat_v3';
          channelName = 'مواقيت الصلاة (تكبيرات الأذان)';
          androidSound = const RawResourceAndroidNotificationSound('adhan_takbeerat');
          iosSound = 'adhan_takbeerat.mp3';
          break;
        case 'notification_only':
          channelId = 'prayer_channel_notification_v3';
          channelName = 'مواقيت الصلاة (تنبيه مقتضب)';
          androidSound = null;
          iosSound = 'notification_sound.mp3';
          break;
        case 'silent':
        default:
          channelId = 'prayer_channel_silent_v3';
          channelName = 'مواقيت الصلاة (صامت)';
          androidSound = null;
          iosSound = null;
          isSilent = true;
          break;
      }

      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: 'حان الآن موعد أذان $prayerNameArabic',
        body: 'الله أكبر، الله أكبر .. حيّ على الصلاة، حيّ على الفلاح',
        scheduledDate: scheduledDate,
        notificationDetails: NotificationDetails(
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
        ),
        payload: jsonEncode({'route': '/prayer-times', 'action': 'prayer_checkin', 'prayer': prayerNameArabic}),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      AppLogger.info('🕌 [PrayerNotification] Scheduled $prayerNameArabic at $scheduledDate (ID: $id, Sound: $azanSound)');
    } catch (e) {
      AppLogger.warning('Failed to schedule prayer notification for $prayerNameArabic: $e');
    }
  }

  Future<void> scheduleAzkarReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    if (kIsWeb || (!kIsWeb && (Platform.isLinux || Platform.isWindows))) {
      return;
    }
    try {
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
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
        matchDateTimeComponents: DateTimeComponents.time,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (e) {
      AppLogger.warning('Failed to schedule azkar reminder: $e');
    }
  }
}
