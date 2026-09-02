import 'package:intl/intl.dart';
import '../../domain/entities/prayer_time_entity.dart';

class PrayerTimesModel {
  static DayPrayerTimes fromAladhanJson(Map<String, dynamic> json, {required String locationName}) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final timings = data['timings'] as Map<String, dynamic>? ?? {};
    final dateObj = data['date'] as Map<String, dynamic>? ?? {};
    final gregorian = dateObj['gregorian'] as Map<String, dynamic>? ?? {};
    final hijri = dateObj['hijri'] as Map<String, dynamic>? ?? {};

    final gregorianDateStr = gregorian['date'] as String? ?? DateFormat('dd-MM-yyyy').format(DateTime.now());
    DateTime parsedDate;
    try {
      parsedDate = DateFormat('dd-MM-yyyy').parse(gregorianDateStr);
    } catch (_) {
      parsedDate = DateTime.now();
    }

    final hijriDate = hijri['date'] as String? ?? '';
    final hijriDay = hijri['day']?.toString() ?? '';
    final hijriMonthObj = hijri['month'] as Map<String, dynamic>? ?? {};
    final hijriMonth = hijriMonthObj['ar'] as String? ?? hijriMonthObj['en'] as String? ?? '';
    final hijriYear = hijri['year']?.toString() ?? '';

    DateTime parseTime(String? timeStr, DateTime baseDate) {
      if (timeStr == null) return baseDate;
      // Format might be "04:30 (EEST)" or "04:30"
      final clean = timeStr.split(' ').first;
      final parts = clean.split(':');
      if (parts.length >= 2) {
        final h = int.tryParse(parts[0]) ?? 0;
        final m = int.tryParse(parts[1]) ?? 0;
        return DateTime(baseDate.year, baseDate.month, baseDate.day, h, m);
      }
      return baseDate;
    }

    final prayers = <PrayerTimeItem>[
      PrayerTimeItem(
        type: PrayerType.fajr,
        nameArabic: 'الفجر',
        nameEnglish: 'Fajr',
        time: parseTime(timings['Fajr'] as String?, parsedDate),
      ),
      PrayerTimeItem(
        type: PrayerType.sunrise,
        nameArabic: 'الشروق',
        nameEnglish: 'Sunrise',
        time: parseTime(timings['Sunrise'] as String?, parsedDate),
      ),
      PrayerTimeItem(
        type: PrayerType.dhuhr,
        nameArabic: 'الظهر',
        nameEnglish: 'Dhuhr',
        time: parseTime(timings['Dhuhr'] as String?, parsedDate),
      ),
      PrayerTimeItem(
        type: PrayerType.asr,
        nameArabic: 'العصر',
        nameEnglish: 'Asr',
        time: parseTime(timings['Asr'] as String?, parsedDate),
      ),
      PrayerTimeItem(
        type: PrayerType.maghrib,
        nameArabic: 'المغرب',
        nameEnglish: 'Maghrib',
        time: parseTime(timings['Maghrib'] as String?, parsedDate),
      ),
      PrayerTimeItem(
        type: PrayerType.isha,
        nameArabic: 'العشاء',
        nameEnglish: 'Isha',
        time: parseTime(timings['Isha'] as String?, parsedDate),
      ),
    ];

    return DayPrayerTimes(
      date: parsedDate,
      hijriDate: hijriDate,
      hijriDay: hijriDay,
      hijriMonth: hijriMonth,
      hijriYear: hijriYear,
      prayers: prayers,
      locationName: locationName,
    );
  }
}
