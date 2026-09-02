import 'package:flutter_test/flutter_test.dart';
import 'package:arkan/features/islamic_hub/domain/entities/islamic_settings_entity.dart';
import 'package:arkan/features/islamic_hub/domain/entities/prayer_time_entity.dart';

void main() {
  group('Arkan Islamic App Core Models & Calculations Test', () {
    test('IslamicSettingsEntity default values test', () {
      const settings = IslamicSettingsEntity();
      expect(settings.isEnabled, isTrue);
      expect(settings.azanSound, equals('makkah'));
      expect(settings.calculationMethod, equals('Egyptian'));
      expect(settings.selectedCity, equals('Cairo'));
      expect(settings.selectedCountry, equals('Egypt'));
    });

    test('DayPrayerTimes correctly identifies prayer items', () {
      final now = DateTime.now();
      final fajrItem = PrayerTimeItem(
        type: PrayerType.fajr,
        nameArabic: 'الفجر',
        nameEnglish: 'Fajr',
        time: now.subtract(const Duration(hours: 4)),
      );
      final dhuhrItem = PrayerTimeItem(
        type: PrayerType.dhuhr,
        nameArabic: 'الظهر',
        nameEnglish: 'Dhuhr',
        time: now.add(const Duration(hours: 1)),
      );

      final dayTimes = DayPrayerTimes(
        date: now,
        hijriDate: '1 رمضان 1448',
        hijriDay: '1',
        hijriMonth: 'رمضان',
        hijriYear: '1448',
        locationName: 'القاهرة، مصر',
        prayers: [fajrItem, dhuhrItem],
      );

      expect(dayTimes.prayers.length, equals(2));
      expect(dayTimes.prayers.first.time.isBefore(now), isTrue);
      expect(dayTimes.prayers.last.time.isAfter(now), isTrue);
      expect(dayTimes.locationName, equals('القاهرة، مصر'));
    });
  });
}
