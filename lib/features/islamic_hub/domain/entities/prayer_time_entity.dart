import 'package:equatable/equatable.dart';

enum PrayerType {
  fajr,
  sunrise,
  dhuhr,
  asr,
  maghrib,
  isha,
}

class PrayerTimeItem extends Equatable {
  final PrayerType type;
  final String nameArabic;
  final String nameEnglish;
  final DateTime time;
  final bool isCompleted;
  final bool isOnTime;

  const PrayerTimeItem({
    required this.type,
    required this.nameArabic,
    required this.nameEnglish,
    required this.time,
    this.isCompleted = false,
    this.isOnTime = false,
  });

  PrayerTimeItem copyWith({
    PrayerType? type,
    String? nameArabic,
    String? nameEnglish,
    DateTime? time,
    bool? isCompleted,
    bool? isOnTime,
  }) {
    return PrayerTimeItem(
      type: type ?? this.type,
      nameArabic: nameArabic ?? this.nameArabic,
      nameEnglish: nameEnglish ?? this.nameEnglish,
      time: time ?? this.time,
      isCompleted: isCompleted ?? this.isCompleted,
      isOnTime: isOnTime ?? this.isOnTime,
    );
  }

  @override
  List<Object?> get props => [type, nameArabic, nameEnglish, time, isCompleted, isOnTime];
}

class DayPrayerTimes extends Equatable {
  final DateTime date;
  final String hijriDate;
  final String hijriDay;
  final String hijriMonth;
  final String hijriYear;
  final List<PrayerTimeItem> prayers;
  final String locationName;

  const DayPrayerTimes({
    required this.date,
    required this.hijriDate,
    required this.hijriDay,
    required this.hijriMonth,
    required this.hijriYear,
    required this.prayers,
    required this.locationName,
  });

  PrayerTimeItem? get nextPrayer {
    final now = DateTime.now();
    for (final p in prayers) {
      if (p.type != PrayerType.sunrise && p.time.isAfter(now)) {
        return p;
      }
    }
    // If all passed today, next is tomorrow Fajr (or first prayer)
    return prayers.isNotEmpty ? prayers.first : null;
  }

  PrayerTimeItem? get currentOrLastPrayer {
    final now = DateTime.now();
    PrayerTimeItem? last;
    for (final p in prayers) {
      if (p.type != PrayerType.sunrise && p.time.isBefore(now)) {
        last = p;
      }
    }
    return last;
  }

  @override
  List<Object?> get props => [
        date,
        hijriDate,
        hijriDay,
        hijriMonth,
        hijriYear,
        prayers,
        locationName,
      ];
}
