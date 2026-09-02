import 'package:equatable/equatable.dart';

class DailyWorshipLogEntity extends Equatable {
  final String dateKey; // YYYY-MM-DD

  // 1. الصلوات الخمس المفروضة
  final bool fajrFard;
  final bool dhuhrFard;
  final bool asrFard;
  final bool maghribFard;
  final bool ishaFard;

  // 2. السنن الرواتب (12 ركعة)
  final bool fajrSunnah;
  final bool dhuhrSunnahBefore;
  final bool dhuhrSunnahAfter;
  final bool maghribSunnah;
  final bool ishaSunnah;

  // 3. النوافل
  final bool duhaPrayer;
  final bool qiyamAndWitr;

  // 4. الأوراد والفضائل
  final bool morningEveningAzkar;
  final bool quranWird;
  final bool surahMulk;
  final bool surahKahf;
  final bool fastingSunnah;
  final bool dailyCharity;

  const DailyWorshipLogEntity({
    required this.dateKey,
    this.fajrFard = false,
    this.dhuhrFard = false,
    this.asrFard = false,
    this.maghribFard = false,
    this.ishaFard = false,
    this.fajrSunnah = false,
    this.dhuhrSunnahBefore = false,
    this.dhuhrSunnahAfter = false,
    this.maghribSunnah = false,
    this.ishaSunnah = false,
    this.duhaPrayer = false,
    this.qiyamAndWitr = false,
    this.morningEveningAzkar = false,
    this.quranWird = false,
    this.surahMulk = false,
    this.surahKahf = false,
    this.fastingSunnah = false,
    this.dailyCharity = false,
  });

  /// Total count of all completed acts of worship
  int get totalCompletedCount {
    int count = 0;
    // Fard (5)
    if (fajrFard) count++;
    if (dhuhrFard) count++;
    if (asrFard) count++;
    if (maghribFard) count++;
    if (ishaFard) count++;

    // Sunan Rawatib (5)
    if (fajrSunnah) count++;
    if (dhuhrSunnahBefore) count++;
    if (dhuhrSunnahAfter) count++;
    if (maghribSunnah) count++;
    if (ishaSunnah) count++;

    // Nawafil (2)
    if (duhaPrayer) count++;
    if (qiyamAndWitr) count++;

    // Wirds (6)
    if (morningEveningAzkar) count++;
    if (quranWird) count++;
    if (surahMulk) count++;
    if (surahKahf) count++;
    if (fastingSunnah) count++;
    if (dailyCharity) count++;

    return count;
  }

  /// Total completed obligatory prayers (out of 5)
  int get totalFardCount {
    int count = 0;
    if (fajrFard) count++;
    if (dhuhrFard) count++;
    if (asrFard) count++;
    if (maghribFard) count++;
    if (ishaFard) count++;
    return count;
  }

  /// Total completed Sunan Rawatib rak'ahs (out of 12)
  int get totalSunanRawatibCount {
    int count = 0;
    if (fajrSunnah) count += 2;
    if (dhuhrSunnahBefore) count += 4;
    if (dhuhrSunnahAfter) count += 2;
    if (maghribSunnah) count += 2;
    if (ishaSunnah) count += 2;
    return count;
  }

  DailyWorshipLogEntity copyWith({
    String? dateKey,
    bool? fajrFard,
    bool? dhuhrFard,
    bool? asrFard,
    bool? maghribFard,
    bool? ishaFard,
    bool? fajrSunnah,
    bool? dhuhrSunnahBefore,
    bool? dhuhrSunnahAfter,
    bool? maghribSunnah,
    bool? ishaSunnah,
    bool? duhaPrayer,
    bool? qiyamAndWitr,
    bool? morningEveningAzkar,
    bool? quranWird,
    bool? surahMulk,
    bool? surahKahf,
    bool? fastingSunnah,
    bool? dailyCharity,
  }) {
    return DailyWorshipLogEntity(
      dateKey: dateKey ?? this.dateKey,
      fajrFard: fajrFard ?? this.fajrFard,
      dhuhrFard: dhuhrFard ?? this.dhuhrFard,
      asrFard: asrFard ?? this.asrFard,
      maghribFard: maghribFard ?? this.maghribFard,
      ishaFard: ishaFard ?? this.ishaFard,
      fajrSunnah: fajrSunnah ?? this.fajrSunnah,
      dhuhrSunnahBefore: dhuhrSunnahBefore ?? this.dhuhrSunnahBefore,
      dhuhrSunnahAfter: dhuhrSunnahAfter ?? this.dhuhrSunnahAfter,
      maghribSunnah: maghribSunnah ?? this.maghribSunnah,
      ishaSunnah: ishaSunnah ?? this.ishaSunnah,
      duhaPrayer: duhaPrayer ?? this.duhaPrayer,
      qiyamAndWitr: qiyamAndWitr ?? this.qiyamAndWitr,
      morningEveningAzkar: morningEveningAzkar ?? this.morningEveningAzkar,
      quranWird: quranWird ?? this.quranWird,
      surahMulk: surahMulk ?? this.surahMulk,
      surahKahf: surahKahf ?? this.surahKahf,
      fastingSunnah: fastingSunnah ?? this.fastingSunnah,
      dailyCharity: dailyCharity ?? this.dailyCharity,
    );
  }

  factory DailyWorshipLogEntity.fromJson(Map<String, dynamic> json) {
    return DailyWorshipLogEntity(
      dateKey: json['date_key'] as String? ?? '',
      fajrFard: json['fajr_fard'] as bool? ?? false,
      dhuhrFard: json['dhuhr_fard'] as bool? ?? false,
      asrFard: json['asr_fard'] as bool? ?? false,
      maghribFard: json['maghrib_fard'] as bool? ?? false,
      ishaFard: json['isha_fard'] as bool? ?? false,
      fajrSunnah: json['fajr_sunnah'] as bool? ?? false,
      dhuhrSunnahBefore: json['dhuhr_sunnah_before'] as bool? ?? false,
      dhuhrSunnahAfter: json['dhuhr_sunnah_after'] as bool? ?? false,
      maghribSunnah: json['maghrib_sunnah'] as bool? ?? false,
      ishaSunnah: json['isha_sunnah'] as bool? ?? false,
      duhaPrayer: json['duha_prayer'] as bool? ?? false,
      qiyamAndWitr: json['qiyam_and_witr'] as bool? ?? false,
      morningEveningAzkar: json['morning_evening_azkar'] as bool? ?? false,
      quranWird: json['quran_wird'] as bool? ?? false,
      surahMulk: json['surah_mulk'] as bool? ?? false,
      surahKahf: json['surah_kahf'] as bool? ?? false,
      fastingSunnah: json['fasting_sunnah'] as bool? ?? false,
      dailyCharity: json['daily_charity'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date_key': dateKey,
      'fajr_fard': fajrFard,
      'dhuhr_fard': dhuhrFard,
      'asr_fard': asrFard,
      'maghrib_fard': maghribFard,
      'isha_fard': ishaFard,
      'fajr_sunnah': fajrSunnah,
      'dhuhr_sunnah_before': dhuhrSunnahBefore,
      'dhuhr_sunnah_after': dhuhrSunnahAfter,
      'maghrib_sunnah': maghribSunnah,
      'isha_sunnah': ishaSunnah,
      'duha_prayer': duhaPrayer,
      'qiyam_and_witr': qiyamAndWitr,
      'morning_evening_azkar': morningEveningAzkar,
      'quran_wird': quranWird,
      'surah_mulk': surahMulk,
      'surah_kahf': surahKahf,
      'fasting_sunnah': fastingSunnah,
      'daily_charity': dailyCharity,
    };
  }

  @override
  List<Object?> get props => [
        dateKey,
        fajrFard,
        dhuhrFard,
        asrFard,
        maghribFard,
        ishaFard,
        fajrSunnah,
        dhuhrSunnahBefore,
        dhuhrSunnahAfter,
        maghribSunnah,
        ishaSunnah,
        duhaPrayer,
        qiyamAndWitr,
        morningEveningAzkar,
        quranWird,
        surahMulk,
        surahKahf,
        fastingSunnah,
        dailyCharity,
      ];
}
