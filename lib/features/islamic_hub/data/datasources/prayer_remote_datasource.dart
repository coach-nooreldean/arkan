import 'dart:convert';
import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/prayer_time_entity.dart';
import '../models/prayer_times_model.dart';

abstract class PrayerRemoteDataSource {
  Future<DayPrayerTimes> fetchPrayerTimes({
    DateTime? date,
    String city = 'Cairo',
    String country = 'Egypt',
    double? latitude,
    double? longitude,
    String method = 'Egyptian',
  });
}

class PrayerRemoteDataSourceImpl implements PrayerRemoteDataSource {
  final Dio _dio;
  static final Map<String, DayPrayerTimes> _memoryCache = {};

  PrayerRemoteDataSourceImpl({Dio? dio}) : _dio = dio ?? Dio();

  int _getMethodNumber(String method) {
    switch (method.toLowerCase()) {
      case 'egyptian':
      case 'egypt':
        return 5; // Egyptian General Authority of Survey
      case 'ummalqura':
      case 'makkah':
        return 4; // Umm Al-Qura University, Makkah
      case 'muslimworldleague':
      case 'mwl':
        return 3; // Muslim World League
      case 'karachi':
        return 1; // University of Islamic Sciences, Karachi
      case 'isna':
        return 2; // ISNA (North America)
      case 'kuwait':
        return 9; // Kuwait
      case 'qatar':
        return 10; // Qatar
      case 'dubai':
        return 16; // Dubai
      default:
        return 5;
    }
  }

  @override
  Future<DayPrayerTimes> fetchPrayerTimes({
    DateTime? date,
    String city = 'Cairo',
    String country = 'Egypt',
    double? latitude,
    double? longitude,
    String method = 'Egyptian',
  }) async {
    final targetDate = date ?? DateTime.now();
    final dateStr = DateFormat('dd-MM-yyyy').format(targetDate);
    final methodId = _getMethodNumber(method);
    final locationLabel = latitude != null && longitude != null
        ? '$city ($country)'
        : '$city, $country';

    final cacheKey = 'prayer_cache_${dateStr}_${city}_${country}_${methodId}_${latitude ?? 0}_${longitude ?? 0}';

    // 1. Check in-memory cache first
    if (_memoryCache.containsKey(cacheKey)) {
      return _memoryCache[cacheKey]!;
    }

    // 2. Check SharedPreferences local disk cache
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(cacheKey);
      if (cachedJson != null) {
        final decoded = jsonDecode(cachedJson) as Map<String, dynamic>;
        final cachedModel = PrayerTimesModel.fromAladhanJson(decoded, locationName: locationLabel);
        _memoryCache[cacheKey] = cachedModel;
        return cachedModel;
      }
    } catch (_) {}

    try {
      Response<dynamic> response;
      if (latitude != null && longitude != null) {
        final url = 'https://api.aladhan.com/v1/timings/$dateStr';
        response = await _dio.get<dynamic>(
          url,
          queryParameters: {
            'latitude': latitude,
            'longitude': longitude,
            'method': methodId,
          },
          options: Options(receiveTimeout: const Duration(seconds: 10)),
        );
      } else {
        final url = 'https://api.aladhan.com/v1/timingsByCity/$dateStr';
        response = await _dio.get<dynamic>(
          url,
          queryParameters: {
            'city': city,
            'country': country,
            'method': methodId,
          },
          options: Options(receiveTimeout: const Duration(seconds: 10)),
        );
      }

      if (response.statusCode == 200 && response.data != null) {
        final rawData = response.data as Map<String, dynamic>;
        final parsed = PrayerTimesModel.fromAladhanJson(
          rawData,
          locationName: locationLabel,
        );

        // Store in memory & disk cache
        _memoryCache[cacheKey] = parsed;
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(cacheKey, jsonEncode(rawData));
        } catch (_) {}

        return parsed;
      }
    } catch (e) {
      AppLogger.warning('Aladhan API fetch failed, falling back to offline calculation: $e');
    }

    // Offline Mathematical Fallback Calculation
    final fallback = _calculateOfflinePrayerTimes(
      targetDate,
      lat: latitude ?? 30.0444, // Default Cairo latitude
      lng: longitude ?? 31.2357, // Default Cairo longitude
      locationName: city.isNotEmpty ? city : 'Cairo, Egypt',
    );
    _memoryCache[cacheKey] = fallback;
    return fallback;
  }

  DayPrayerTimes _calculateOfflinePrayerTimes(
    DateTime date, {
    required double lat,
    required double lng,
    required String locationName,
  }) {
    // Standard astronomical calculation for offline reliability
    final dayOfYear = int.parse(DateFormat('D').format(date));
    final b = 2 * math.pi * (dayOfYear - 81) / 365;
    final eot = 9.87 * math.sin(2 * b) - 7.53 * math.cos(b) - 1.5 * math.sin(b);
    final declination = 23.45 * math.sin(2 * math.pi * (284 + dayOfYear) / 365) * (math.pi / 180);

    // Solar noon in hours (approx timezone +2/3)
    final timezoneOffset = date.timeZoneOffset.inMinutes / 60.0;
    final noon = 12 + timezoneOffset - (lng / 15.0) - (eot / 60.0);

    final latRad = lat * (math.pi / 180);

    // Fajr (-19.5 deg for Egyptian survey)
    const fajrAngle = -19.5 * (math.pi / 180);
    final fajrCosH = (math.sin(fajrAngle) - math.sin(latRad) * math.sin(declination)) /
        (math.cos(latRad) * math.cos(declination));
    final fajrHourAngle = (math.acos(fajrCosH.clamp(-1.0, 1.0)) * 180 / math.pi) / 15.0;
    final fajrTime = noon - fajrHourAngle;

    // Sunrise (-0.833 deg)
    const sunriseAngle = -0.833 * (math.pi / 180);
    final sunriseCosH = (math.sin(sunriseAngle) - math.sin(latRad) * math.sin(declination)) /
        (math.cos(latRad) * math.cos(declination));
    final sunriseHourAngle = (math.acos(sunriseCosH.clamp(-1.0, 1.0)) * 180 / math.pi) / 15.0;
    final sunriseTime = noon - sunriseHourAngle;

    // Dhuhr
    final dhuhrTime = noon + (2 / 60.0); // +2 mins after solar noon

    // Asr (Shafi/Standard shadow = 1)
    final asrAngle = -math.atan(1 + math.tan((lat * math.pi / 180) - declination).abs());
    final asrCosH = (math.sin(asrAngle) - math.sin(latRad) * math.sin(declination)) /
        (math.cos(latRad) * math.cos(declination));
    final asrHourAngle = (math.acos(asrCosH.clamp(-1.0, 1.0)) * 180 / math.pi) / 15.0;
    final asrTime = noon + asrHourAngle;

    // Maghrib (Sunset)
    final maghribTime = noon + sunriseHourAngle + (2 / 60.0);

    // Isha (-17.5 deg for Egyptian survey)
    const ishaAngle = -17.5 * (math.pi / 180);
    final ishaCosH = (math.sin(ishaAngle) - math.sin(latRad) * math.sin(declination)) /
        (math.cos(latRad) * math.cos(declination));
    final ishaHourAngle = (math.acos(ishaCosH.clamp(-1.0, 1.0)) * 180 / math.pi) / 15.0;
    final ishaTime = noon + ishaHourAngle;

    DateTime hoursToDate(double hours) {
      final h = hours.floor() % 24;
      final m = ((hours - hours.floor()) * 60).round() % 60;
      return DateTime(date.year, date.month, date.day, h, m);
    }

    final prayers = <PrayerTimeItem>[
      PrayerTimeItem(type: PrayerType.fajr, nameArabic: 'الفجر', nameEnglish: 'Fajr', time: hoursToDate(fajrTime)),
      PrayerTimeItem(type: PrayerType.sunrise, nameArabic: 'الشروق', nameEnglish: 'Sunrise', time: hoursToDate(sunriseTime)),
      PrayerTimeItem(type: PrayerType.dhuhr, nameArabic: 'الظهر', nameEnglish: 'Dhuhr', time: hoursToDate(dhuhrTime)),
      PrayerTimeItem(type: PrayerType.asr, nameArabic: 'العصر', nameEnglish: 'Asr', time: hoursToDate(asrTime)),
      PrayerTimeItem(type: PrayerType.maghrib, nameArabic: 'المغرب', nameEnglish: 'Maghrib', time: hoursToDate(maghribTime)),
      PrayerTimeItem(type: PrayerType.isha, nameArabic: 'العشاء', nameEnglish: 'Isha', time: hoursToDate(ishaTime)),
    ];

    return DayPrayerTimes(
      date: date,
      hijriDate: '',
      hijriDay: '',
      hijriMonth: '',
      hijriYear: '',
      prayers: prayers,
      locationName: locationName,
    );
  }
}
