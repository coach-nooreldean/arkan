class HijriDate {
  final int year;
  final int month;
  final int day;
  final String monthNameAr;
  final String monthNameEn;

  const HijriDate({
    required this.year,
    required this.month,
    required this.day,
    required this.monthNameAr,
    required this.monthNameEn,
  });

  String get formattedAr => '$day $monthNameAr $year هـ';
  String get formattedNumeric =>
      '${day.toString().padLeft(2, '0')}-${month.toString().padLeft(2, '0')}-$year';
  String get formattedEn => '$day $monthNameEn $year AH';
}

class HijriCalendarHelper {
  static const List<String> _monthsAr = [
    'محرم',
    'صفر',
    'ربيع الأول',
    'ربيع الآخر',
    'جمادى الأولى',
    'جمادى الآخرة',
    'رجب',
    'شعبان',
    'رمضان',
    'شوال',
    'ذو القعدة',
    'ذو الحجة',
  ];

  static const List<String> _monthsEn = [
    'Muharram',
    'Safar',
    'Rabi al-Awwal',
    'Rabi al-Thani',
    'Jumada al-Ula',
    'Jumada al-Akhirah',
    'Rajab',
    'Shaban',
    'Ramadan',
    'Shawwal',
    'Dhu al-Qadah',
    'Dhu al-Hijjah',
  ];

  /// Converts a Gregorian [DateTime] to a tabular/Kuwaiti Hijri date.
  static HijriDate fromGregorian(DateTime date) {
    final y = date.year;
    final m = date.month;
    final d = date.day;

    int jd;
    if (y > 1582 || (y == 1582 && m > 10) || (y == 1582 && m == 10 && d > 14)) {
      jd = ((1461 * (y + 4800 + ((m - 14) / 12).truncate())) / 4).truncate() +
          ((367 * (m - 2 - 12 * (((m - 14) / 12).truncate()))) / 12)
              .truncate() -
          ((3 * (((y + 4900 + ((m - 14) / 12).truncate()) / 100).truncate())) /
                  4)
              .truncate() +
          d -
          32075;
    } else {
      jd = 367 * y -
          ((7 * (y + 5001 + ((m - 9) / 7).truncate())) / 4).truncate() +
          ((275 * m) / 9).truncate() +
          d +
          1729777;
    }

    var l = jd - 1948440 + 10632;
    final n = ((l - 1) / 10631).truncate();
    l = l - 10631 * n + 354;
    final j = (((10985 - l) / 5316).truncate()) *
            (((50 * l) / 17719).truncate()) +
        ((l / 5670).truncate()) * (((43 * l) / 15238).truncate());
    l = l -
        (((30 - j) / 15).truncate()) * (((17719 * j) / 50).truncate()) -
        ((j / 16).truncate()) * (((15238 * j) / 43).truncate()) +
        29;

    final hMonth = (((24 * l) / 709).truncate()).clamp(1, 12);
    final hDay = (l - ((709 * hMonth) / 24).truncate()).clamp(1, 30);
    final hYear = 30 * n + j - 30;

    return HijriDate(
      year: hYear,
      month: hMonth,
      day: hDay,
      monthNameAr: _monthsAr[hMonth - 1],
      monthNameEn: _monthsEn[hMonth - 1],
    );
  }

  static String formatArabic(DateTime date) => fromGregorian(date).formattedAr;

  static bool isWhiteDay(HijriDate h) =>
      h.day == 13 || h.day == 14 || h.day == 15;

  static List<String> getRecommendedFastingTags(DateTime date) {
    final h = fromGregorian(date);
    final tags = <String>[];

    if (date.weekday == DateTime.monday) {
      tags.add('صيام الإثنين');
    } else if (date.weekday == DateTime.thursday) {
      tags.add('صيام الخميس');
    }

    if (isWhiteDay(h)) {
      tags.add('الأيام البيض (${h.day} ${h.monthNameAr})');
    }
    if (h.month == 1 && h.day == 9) {
      tags.add('تاسوعاء (9 محرم)');
    } else if (h.month == 1 && h.day == 10) {
      tags.add('يوم عاشوراء (10 محرم)');
    }
    if (h.month == 12 && h.day == 9) {
      tags.add('صيام يوم عرفة (9 ذو الحجة)');
    } else if (h.month == 12 && h.day >= 1 && h.day <= 8) {
      tags.add('عشر ذي الحجة');
    }
    if (h.month == 10 && h.day >= 2 && h.day <= 7) {
      tags.add('الست من شوال');
    }
    return tags;
  }

  static String? getIslamicOccasion(HijriDate h) {
    if (h.month == 1 && h.day == 1) return 'رأس السنة الهجرية';
    if (h.month == 1 && h.day == 10) return 'يوم عاشوراء';
    if (h.month == 9 && h.day == 1) return 'غرة شهر رمضان المبارك';
    if (h.month == 9 && h.day == 27) return 'ليلة السابع والعشرين من رمضان';
    if (h.month == 10 && h.day == 1) return 'عيد الفطر المبارك';
    if (h.month == 12 && h.day == 9) return 'يوم عرفة';
    if (h.month == 12 && h.day == 10) return 'عيد الأضحى المبارك';
    return null;
  }
}
