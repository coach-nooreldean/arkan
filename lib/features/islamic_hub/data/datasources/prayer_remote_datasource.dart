import 'dart:convert';
import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/hijri_calendar_helper.dart';
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
    int asrSchool = 0,
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
    int asrSchool = 0,
  }) async {
    final targetDate = date ?? DateTime.now();
    final dateStr = DateFormat('dd-MM-yyyy').format(targetDate);
    final methodId = _getMethodNumber(method);
    final locationLabel = latitude != null && longitude != null
        ? '$city ($country)'
        : '$city, $country';

    final cacheKey =
        'prayer_cache_${dateStr}_${city}_${country}_${methodId}_${asrSchool}_${latitude ?? 0}_${longitude ?? 0}';

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
        final cachedModel = PrayerTimesModel.fromAladhanJson(
          decoded,
          locationName: locationLabel,
        );
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
            'school': asrSchool,
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
            'school': asrSchool,
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

        _memoryCache[cacheKey] = parsed;
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(cacheKey, jsonEncode(rawData));
        } catch (_) {}

        return parsed;
      }
    } catch (e) {
      AppLogger.warning(
        'Aladhan API fetch failed, falling back to offline calculation: $e',
      );
    }

    // Offline Mathematical Fallback Calculation
    final fallback = calculateOfflinePrayerTimes(
      targetDate,
      lat: latitude ?? 30.0444,
      lng: longitude ?? 31.2357,
      locationName: city.isNotEmpty ? '$city, $country' : 'Cairo, Egypt',
      method: method,
      asrSchool: asrSchool,
    );
    _memoryCache[cacheKey] = fallback;
    return fallback;
  }

  static ({double fajrDeg, double ishaDeg, int? ishaMinutesAfterMaghrib})
      _methodAngles(String method) {
    switch (method.toLowerCase()) {
      case 'ummalqura':
      case 'makkah':
        return (fajrDeg: 18.5, ishaDeg: 18.0, ishaMinutesAfterMaghrib: 90);
      case 'muslimworldleague':
      case 'mwl':
        return (fajrDeg: 18.0, ishaDeg: 17.0, ishaMinutesAfterMaghrib: null);
      case 'karachi':
        return (fajrDeg: 18.0, ishaDeg: 18.0, ishaMinutesAfterMaghrib: null);
      case 'isna':
        return (fajrDeg: 15.0, ishaDeg: 15.0, ishaMinutesAfterMaghrib: null);
      case 'egyptian':
      case 'egypt':
      default:
        return (fajrDeg: 19.5, ishaDeg: 17.5, ishaMinutesAfterMaghrib: null);
    }
  }

  /// Astronomical prayer time calculation for offline use supporting calculation
  /// methods, Shafi (0) vs Hanafi (1) Asr juristic school, and Hijri conversion.
  static DayPrayerTimes calculateOfflinePrayerTimes(
    DateTime date, {
    required double lat,
    required double lng,
    required String locationName,
    String method = 'Egyptian',
    int asrSchool = 0,
  }) {
    final dayOfYear = int.parse(DateFormat('D').format(date));
    final b = 2 * math.pi * (dayOfYear - 81) / 365;
    final eot = 9.87 * math.sin(2 * b) - 7.53 * math.cos(b) - 1.5 * math.sin(b);
    final declination =
        23.45 * math.sin(2 * math.pi * (284 + dayOfYear) / 365) * (math.pi / 180);

    final timezoneOffset = date.timeZoneOffset.inMinutes / 60.0;
    final noon = 12 + timezoneOffset - (lng / 15.0) - (eot / 60.0);
    final latRad = lat * (math.pi / 180);

    double hourAngleForAltitude(double altitudeRad) {
      final cosH = (math.sin(altitudeRad) - math.sin(latRad) * math.sin(declination)) /
          (math.cos(latRad) * math.cos(declination));
      return (math.acos(cosH.clamp(-1.0, 1.0)) * 180 / math.pi) / 15.0;
    }

    final angles = _methodAngles(method);

    // Fajr
    final fajrTime = noon - hourAngleForAltitude(-angles.fajrDeg * (math.pi / 180));

    // Sunrise / Sunset (-0.833 deg)
    final sunHorizonH = hourAngleForAltitude(-0.833 * (math.pi / 180));
    final sunriseTime = noon - sunHorizonH;

    // Dhuhr
    final dhuhrTime = noon + (2 / 60.0);

    // Asr: shadowFactor = 1 (Shafi/Jumhur) or 2 (Hanafi), positive altitude above horizon
    final shadowFactor = asrSchool == 1 ? 2.0 : 1.0;
    final asrAltitude = math.atan(
      1.0 / (shadowFactor + math.tan((latRad - declination).abs())),
    );
    final asrTime = noon + hourAngleForAltitude(asrAltitude);

    // Maghrib
    final maghribTime = noon + sunHorizonH + (2 / 60.0);

    // Isha
    final ishaTime = angles.ishaMinutesAfterMaghrib != null
        ? maghribTime + (angles.ishaMinutesAfterMaghrib! / 60.0)
        : noon + hourAngleForAltitude(-angles.ishaDeg * (math.pi / 180));

    DateTime hoursToDate(double hours) {
      final normalized = ((hours % 24.0) + 24.0) % 24.0;
      var h = normalized.floor();
      var m = ((normalized - h) * 60).round();
      if (m >= 60) {
        m = 0;
        h = (h + 1) % 24;
      }
      return DateTime(date.year, date.month, date.day, h, m);
    }

    final hijri = HijriCalendarHelper.fromGregorian(date);

    final prayers = <PrayerTimeItem>[
      PrayerTimeItem(
        type: PrayerType.fajr,
        nameArabic: 'الفجر',
        nameEnglish: 'Fajr',
        time: hoursToDate(fajrTime),
      ),
      PrayerTimeItem(
        type: PrayerType.sunrise,
        nameArabic: 'الشروق',
        nameEnglish: 'Sunrise',
        time: hoursToDate(sunriseTime),
      ),
      PrayerTimeItem(
        type: PrayerType.dhuhr,
        nameArabic: 'الظهر',
        nameEnglish: 'Dhuhr',
        time: hoursToDate(dhuhrTime),
      ),
      PrayerTimeItem(
        type: PrayerType.asr,
        nameArabic: 'العصر',
        nameEnglish: 'Asr',
        time: hoursToDate(asrTime),
      ),
      PrayerTimeItem(
        type: PrayerType.maghrib,
        nameArabic: 'المغرب',
        nameEnglish: 'Maghrib',
        time: hoursToDate(maghribTime),
      ),
      PrayerTimeItem(
        type: PrayerType.isha,
        nameArabic: 'العشاء',
        nameEnglish: 'Isha',
        time: hoursToDate(ishaTime),
      ),
    ];

    return DayPrayerTimes(
      date: date,
      hijriDate: hijri.formattedNumeric,
      hijriDay: hijri.day.toString(),
      hijriMonth: hijri.monthNameAr,
      hijriYear: hijri.year.toString(),
      prayers: prayers,
      locationName: locationName,
    );
  }
}
