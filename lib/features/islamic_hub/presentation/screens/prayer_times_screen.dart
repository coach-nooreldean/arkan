import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../../../shared/widgets/premium_background.dart';
import '../cubits/prayer_times_cubit.dart';
import '../cubits/islamic_settings_cubit.dart';
import '../../domain/entities/prayer_time_entity.dart';
import '../widgets/prayer_checkin_dialog.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _playingAzanSound;
  bool _isPlaying = false;
  bool _isDetectingLocation = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _playingAzanSound = null;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final settings = context.read<IslamicSettingsCubit>().state.settings;
        if (settings.isAutoLocationEnabled && settings.customLatitude == null) {
          _handleAutoLocation(showFeedback: false);
        }
      }
    });
  }

  Future<void> _handleAutoLocation({bool showFeedback = true}) async {
    if (_isDetectingLocation) return;
    setState(() => _isDetectingLocation = true);
    final settingsCubit = context.read<IslamicSettingsCubit>();
    final prayerCubit = context.read<PrayerTimesCubit>();

    final result = await settingsCubit.detectAndApplyCurrentLocation();
    if (!mounted) return;
    setState(() => _isDetectingLocation = false);
    if (showFeedback) {
      if (result.isSuccess) {
        prayerCubit.loadPrayerTimes();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('islamic.prayer_times.auto_location_success'.tr(args: ['${result.city ?? ''}, ${result.country ?? ''}'])),
            backgroundColor: const Color(0xFF27AE60),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage ?? 'تعذر تحديد الموقع'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlayAzan(String soundKey) async {
    if (soundKey == 'silent') {
      await _audioPlayer.stop();
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _playingAzanSound = null;
        });
      }
      return;
    }

    if (_isPlaying && _playingAzanSound == soundKey) {
      await _audioPlayer.stop();
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _playingAzanSound = null;
        });
      }
      return;
    }

    await _audioPlayer.stop();
    if (mounted) {
      setState(() {
        _isPlaying = true;
        _playingAzanSound = soundKey;
      });
    }

    try {
      String assetPath;
      switch (soundKey) {
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
          assetPath = 'audio/adhan_takbeerat.mp3';
          break;
        case 'notification_only':
        default:
          assetPath = 'audio/notification_sound.mp3';
          break;
      }
      await _audioPlayer.play(AssetSource(assetPath));
    } catch (_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _playingAzanSound = null;
        });
      }
    }
  }

  void _showCityDialog(BuildContext context) {
    final cubit = context.read<IslamicSettingsCubit>();
    final prayerCubit = context.read<PrayerTimesCubit>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final allCities = [
      // 🇪🇬 محافظات مصر (27 محافظة)
      {'city': 'Cairo', 'country': 'Egypt', 'name': 'القاهرة', 'badge': 'مصر 🇪🇬'},
      {'city': 'Alexandria', 'country': 'Egypt', 'name': 'الإسكندرية', 'badge': 'مصر 🇪🇬'},
      {'city': 'Giza', 'country': 'Egypt', 'name': 'الجيزة', 'badge': 'مصر 🇪🇬'},
      {'city': 'Kafr El Sheikh', 'country': 'Egypt', 'name': 'كفر الشيخ', 'badge': 'مصر 🇪🇬'},
      {'city': 'Tanta', 'country': 'Egypt', 'name': 'طنطا (الغربية)', 'badge': 'مصر 🇪🇬'},
      {'city': 'Mansoura', 'country': 'Egypt', 'name': 'المنصورة (الدقهلية)', 'badge': 'مصر 🇪🇬'},
      {'city': 'Zagazig', 'country': 'Egypt', 'name': 'الزقازيق (الشرقية)', 'badge': 'مصر 🇪🇬'},
      {'city': 'Shibin El Kom', 'country': 'Egypt', 'name': 'شبين الكوم (المنوفية)', 'badge': 'مصر 🇪🇬'},
      {'city': 'Banha', 'country': 'Egypt', 'name': 'بنها (القليوبية)', 'badge': 'مصر 🇪🇬'},
      {'city': 'Damanhour', 'country': 'Egypt', 'name': 'دمنهور (البحيرة)', 'badge': 'مصر 🇪🇬'},
      {'city': 'Damietta', 'country': 'Egypt', 'name': 'دمياط', 'badge': 'مصر 🇪🇬'},
      {'city': 'Port Said', 'country': 'Egypt', 'name': 'بورسعيد', 'badge': 'مصر 🇪🇬'},
      {'city': 'Ismailia', 'country': 'Egypt', 'name': 'الإسماعيلية', 'badge': 'مصر 🇪🇬'},
      {'city': 'Suez', 'country': 'Egypt', 'name': 'السويس', 'badge': 'مصر 🇪🇬'},
      {'city': 'Faiyum', 'country': 'Egypt', 'name': 'الفيوم', 'badge': 'مصر 🇪🇬'},
      {'city': 'Beni Suef', 'country': 'Egypt', 'name': 'بني سويف', 'badge': 'مصر 🇪🇬'},
      {'city': 'Minya', 'country': 'Egypt', 'name': 'المنيا', 'badge': 'مصر 🇪🇬'},
      {'city': 'Asyut', 'country': 'Egypt', 'name': 'أسيوط', 'badge': 'مصر 🇪🇬'},
      {'city': 'Sohag', 'country': 'Egypt', 'name': 'سوهاج', 'badge': 'مصر 🇪🇬'},
      {'city': 'Qena', 'country': 'Egypt', 'name': 'قنا', 'badge': 'مصر 🇪🇬'},
      {'city': 'Luxor', 'country': 'Egypt', 'name': 'الأقصر', 'badge': 'مصر 🇪🇬'},
      {'city': 'Aswan', 'country': 'Egypt', 'name': 'أسوان', 'badge': 'مصر 🇪🇬'},
      {'city': 'Hurghada', 'country': 'Egypt', 'name': 'الغردقة (البحر الأحمر)', 'badge': 'مصر 🇪🇬'},
      {'city': 'Sharm El Sheikh', 'country': 'Egypt', 'name': 'شرم الشيخ (جنوب سيناء)', 'badge': 'مصر 🇪🇬'},
      {'city': 'Arish', 'country': 'Egypt', 'name': 'العريش (شمال سيناء)', 'badge': 'مصر 🇪🇬'},
      {'city': 'Marsa Matruh', 'country': 'Egypt', 'name': 'مرسى مطروح', 'badge': 'مصر 🇪🇬'},
      {'city': 'Kharga', 'country': 'Egypt', 'name': 'الخارجة (الوادي الجديد)', 'badge': 'مصر 🇪🇬'},

      // 🇸🇦 السعودية والخليج
      {'city': 'Makkah', 'country': 'Saudi Arabia', 'name': 'مكة المكرمة', 'badge': 'السعودية 🇸🇦'},
      {'city': 'Madinah', 'country': 'Saudi Arabia', 'name': 'المدينة المنورة', 'badge': 'السعودية 🇸🇦'},
      {'city': 'Riyadh', 'country': 'Saudi Arabia', 'name': 'الرياض', 'badge': 'السعودية 🇸🇦'},
      {'city': 'Jeddah', 'country': 'Saudi Arabia', 'name': 'جدة', 'badge': 'السعودية 🇸🇦'},
      {'city': 'Dammam', 'country': 'Saudi Arabia', 'name': 'الدمام', 'badge': 'السعودية 🇸🇦'},
      {'city': 'Khobar', 'country': 'Saudi Arabia', 'name': 'الخبر', 'badge': 'السعودية 🇸🇦'},
      {'city': 'Taif', 'country': 'Saudi Arabia', 'name': 'الطائف', 'badge': 'السعودية 🇸🇦'},
      {'city': 'Tabuk', 'country': 'Saudi Arabia', 'name': 'تبوك', 'badge': 'السعودية 🇸🇦'},
      {'city': 'Abha', 'country': 'Saudi Arabia', 'name': 'أبها', 'badge': 'السعودية 🇸🇦'},
      {'city': 'Dubai', 'country': 'United Arab Emirates', 'name': 'دبي', 'badge': 'الإمارات 🇦🇪'},
      {'city': 'Abu Dhabi', 'country': 'United Arab Emirates', 'name': 'أبوظبي', 'badge': 'الإمارات 🇦🇪'},
      {'city': 'Sharjah', 'country': 'United Arab Emirates', 'name': 'الشارقة', 'badge': 'الإمارات 🇦🇪'},
      {'city': 'Doha', 'country': 'Qatar', 'name': 'الدوحة', 'badge': 'قطر 🇶🇦'},
      {'city': 'Kuwait', 'country': 'Kuwait', 'name': 'الكويت', 'badge': 'الكويت 🇰🇼'},
      {'city': 'Manama', 'country': 'Bahrain', 'name': 'المنامة', 'badge': 'البحرين 🇧🇭'},
      {'city': 'Muscat', 'country': 'Oman', 'name': 'مسقط', 'badge': 'عمان 🇴🇲'},

      // 🌍 بلاد الشام والمغرب العربي والعالم
      {'city': 'Amman', 'country': 'Jordan', 'name': 'عمان', 'badge': 'الأردن 🇯🇴'},
      {'city': 'Jerusalem', 'country': 'Palestine', 'name': 'القدس الشريف', 'badge': 'فلسطين 🇵🇸'},
      {'city': 'Gaza', 'country': 'Palestine', 'name': 'غزة', 'badge': 'فلسطين 🇵🇸'},
      {'city': 'Baghdad', 'country': 'Iraq', 'name': 'بغداد', 'badge': 'العراق 🇮🇶'},
      {'city': 'Beirut', 'country': 'Lebanon', 'name': 'بيروت', 'badge': 'لبنان 🇱🇧'},
      {'city': 'Damascus', 'country': 'Syria', 'name': 'دمشق', 'badge': 'سوريا 🇸🇾'},
      {'city': 'Tripoli', 'country': 'Libya', 'name': 'طرابلس', 'badge': 'ليبيا 🇱🇾'},
      {'city': 'Tunis', 'country': 'Tunisia', 'name': 'تونس', 'badge': 'تونس 🇹🇳'},
      {'city': 'Algiers', 'country': 'Algeria', 'name': 'الجزائر', 'badge': 'الجزائر 🇩🇿'},
      {'city': 'Rabat', 'country': 'Morocco', 'name': 'الرباط', 'badge': 'المغرب 🇲🇦'},
      {'city': 'Casablanca', 'country': 'Morocco', 'name': 'الدار البيضاء', 'badge': 'المغرب 🇲🇦'},
      {'city': 'Khartoum', 'country': 'Sudan', 'name': 'الخرطوم', 'badge': 'السودان 🇸🇩'},
      {'city': 'Istanbul', 'country': 'Turkey', 'name': 'إسطنبول', 'badge': 'تركيا 🇹🇷'},
      {'city': 'London', 'country': 'United Kingdom', 'name': 'لندن', 'badge': 'بريطانيا 🇬🇧'},
    ];

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF181E2E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
      builder: (ctx) {
        String searchQuery = '';

        return StatefulBuilder(
          builder: (context, setSheetState) {
            final query = searchQuery.trim().toLowerCase();
            final filteredCities = allCities.where((c) {
              if (query.isEmpty) return true;
              final name = c['name']!.toLowerCase();
              final city = c['city']!.toLowerCase();
              final country = c['country']!.toLowerCase();
              return name.contains(query) || city.contains(query) || country.contains(query);
            }).toList();

            return Container(
              height: 0.82.sh,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16.h,
                top: 16.h,
                left: 16.w,
                right: 16.w,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.black12,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Row(
                    children: [
                      Icon(IconsaxPlusBold.location, color: const Color(0xFF3551AE), size: 22.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'اختر المحافظة أو المدينة',
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),

                  // GPS Auto-detect Button
                  InkWell(
                    onTap: () async {
                      Navigator.of(ctx).pop();
                      await _handleAutoLocation(showFeedback: true);
                    },
                    borderRadius: BorderRadius.circular(16.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3551AE).withValues(alpha: isDark ? 0.2 : 0.08),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: const Color(0xFF3551AE).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.r),
                            decoration: const BoxDecoration(
                              color: Color(0xFF3551AE),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(IconsaxPlusBold.radar_2, color: Colors.white, size: 16.sp),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'islamic.prayer_times.auto_location'.tr(),
                                  style: TextStyle(
                                    fontSize: 13.5.sp,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF3551AE),
                                  ),
                                ),
                                Text(
                                  'تحديد إحداثيات موقعك الحي تلقائياً',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios_rounded, size: 13.sp, color: const Color(0xFF3551AE)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // Search Field
                  TextField(
                    autofocus: false,
                    style: TextStyle(fontSize: 14.sp, color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      hintText: 'islamic.prayer_times.city_search_hint'.tr(),
                      hintStyle: TextStyle(fontSize: 13.sp, color: Colors.grey),
                      prefixIcon: const Icon(IconsaxPlusLinear.search_normal, color: Color(0xFF3551AE)),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () => setSheetState(() => searchQuery = ''),
                            )
                          : null,
                      filled: true,
                      fillColor: isDark ? const Color(0xFF22283A) : const Color(0xFFF4F6F9),
                      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (val) {
                      setSheetState(() {
                        searchQuery = val;
                      });
                    },
                    onSubmitted: (val) {
                      if (val.trim().isNotEmpty) {
                        cubit.updateLocation(city: val.trim(), country: 'Egypt');
                        prayerCubit.loadPrayerTimes();
                        Navigator.of(ctx).pop();
                      }
                    },
                  ),

                  SizedBox(height: 12.h),

                  // Results Count / Status
                  Text(
                    searchQuery.isEmpty ? 'islamic.prayer_times.common_cities'.tr() : 'islamic.prayer_times.search_results'.tr(args: [filteredCities.length.toString()]),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),

                  SizedBox(height: 8.h),

                  // Cities List
                  Expanded(
                    child: filteredCities.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(IconsaxPlusLinear.location_slash, size: 40.sp, color: Colors.grey),
                                SizedBox(height: 10.h),
                                Text(
                                  'لم يتم العثور على "$searchQuery"',
                                  style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                                ),
                                SizedBox(height: 12.h),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    cubit.updateLocation(city: searchQuery.trim(), country: 'Custom');
                                    prayerCubit.loadPrayerTimes();
                                    Navigator.of(ctx).pop();
                                  },
                                  icon: const Icon(Icons.check_circle_outline, size: 18),
                                  label: Text('islamic.prayer_times.use_city'.tr(args: [searchQuery])),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF3551AE),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: filteredCities.length,
                            separatorBuilder: (_, __) => Divider(
                              height: 1,
                              color: isDark ? Colors.white10 : Colors.black12.withValues(alpha: 0.05),
                            ),
                            itemBuilder: (context, index) {
                              final item = filteredCities[index];
                              final isCurrent = cubit.state.settings.selectedCity.toLowerCase() == item['city']!.toLowerCase();

                              return ListTile(
                                contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                                leading: Container(
                                  padding: EdgeInsets.all(8.r),
                                  decoration: BoxDecoration(
                                    color: isCurrent
                                        ? const Color(0xFF3551AE).withValues(alpha: 0.2)
                                        : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04)),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isCurrent ? IconsaxPlusBold.location_tick : IconsaxPlusLinear.location,
                                    color: isCurrent ? const Color(0xFF3551AE) : Colors.grey,
                                    size: 20.sp,
                                  ),
                                ),
                                title: Text(
                                  item['name']!,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                                    color: isCurrent
                                        ? const Color(0xFF3551AE)
                                        : (isDark ? Colors.white : Colors.black87),
                                  ),
                                ),
                                subtitle: Text(
                                  '${item['city']}, ${item['country']}',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: Colors.grey,
                                  ),
                                ),
                                trailing: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF22283A) : const Color(0xFFEAEFF8),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Text(
                                    item['badge']!,
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white70 : const Color(0xFF3551AE),
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  cubit.updateLocation(
                                    city: item['city']!,
                                    country: item['country']!,
                                  );
                                  prayerCubit.loadPrayerTimes();
                                  Navigator.of(ctx).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('تم ضبط مواقيت الصلاة على ${item['name']}'),
                                      duration: const Duration(seconds: 2),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppTopBar(
        title: 'islamic.prayer_times.title'.tr(),
        isTransparent: true,
      ),
      body: PremiumBackground(
        child: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 880),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                // Top Info & City Selector Bar
                BlocBuilder<IslamicSettingsCubit, IslamicSettingsState>(
                  builder: (context, settingsState) {
                    return Container(
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF161B2B) : Colors.white,
                        borderRadius: BorderRadius.circular(18.r),
                        border: Border.all(
                          color: isDark ? Colors.white12 : Colors.black12,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Icon(IconsaxPlusBold.location, color: const Color(0xFF3551AE), size: 20.sp),
                                SizedBox(width: 8.w),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              '${settingsState.settings.selectedCity}, ${settingsState.settings.selectedCountry}',
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.bold,
                                                color: isDark ? Colors.white : Colors.black87,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (settingsState.settings.isAutoLocationEnabled) ...[
                                            SizedBox(width: 6.w),
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF27AE60).withValues(alpha: 0.15),
                                                borderRadius: BorderRadius.circular(6.r),
                                              ),
                                              child: Text(
                                                'islamic.prayer_times.auto_badge'.tr(),
                                                style: TextStyle(
                                                  fontSize: 9.5.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: const Color(0xFF27AE60),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'islamic.prayer_times.auto_location'.tr(),
                                icon: _isDetectingLocation || settingsState.isLoading
                                    ? SizedBox(
                                        width: 16.w,
                                        height: 16.w,
                                        child: const CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : Icon(IconsaxPlusBold.radar_2, color: const Color(0xFF3551AE), size: 18.sp),
                                onPressed: () => _handleAutoLocation(showFeedback: true),
                              ),
                              TextButton.icon(
                                onPressed: () => _showCityDialog(context),
                                icon: Icon(IconsaxPlusLinear.edit_2, size: 14.sp),
                                label: Text('islamic.prayer_times.change_city'.tr()),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),

                SizedBox(height: 16.h),

                // Prayers List
                BlocBuilder<PrayerTimesCubit, PrayerTimesState>(
                  builder: (context, prayerState) {
                    final dayTimes = prayerState.dayPrayerTimes;
                    if (dayTimes == null || dayTimes.prayers.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.w),
                          child: const CircularProgressIndicator(),
                        ),
                      );
                    }

                    final now = DateTime.now();

                    return Column(
                      children: dayTimes.prayers.map((prayer) {
                        final isCompleted = prayerState.isPrayerCompleted(prayer.nameEnglish);
                        final isOnTime = prayerState.isPrayerOnTime(prayer.nameEnglish);
                        final isNext = prayerState.nextPrayer?.type == prayer.type;
                        final isFuture = prayer.time.isAfter(now);
                        final timeStr = DateFormat('hh:mm a', 'ar').format(prayer.time);

                        return Container(
                          margin: EdgeInsets.only(bottom: 10.h),
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                          decoration: BoxDecoration(
                            color: isNext
                                ? const Color(0xFF3551AE).withValues(alpha: isDark ? 0.3 : 0.1)
                                : (isDark ? const Color(0xFF161B2B) : Colors.white),
                            borderRadius: BorderRadius.circular(18.r),
                            border: Border.all(
                              color: isNext
                                  ? const Color(0xFF3551AE)
                                  : (isDark ? Colors.white10 : Colors.black12),
                              width: isNext ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(
                                  color: isCompleted
                                      ? const Color(0xFF27AE60).withValues(alpha: 0.15)
                                      : (isNext
                                          ? const Color(0xFF3551AE).withValues(alpha: 0.15)
                                          : Colors.grey.withValues(alpha: 0.1)),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isCompleted
                                      ? IconsaxPlusBold.tick_circle
                                      : (prayer.type == PrayerType.sunrise
                                          ? IconsaxPlusBold.sun_1
                                          : IconsaxPlusBold.clock),
                                  color: isCompleted
                                      ? const Color(0xFF27AE60)
                                      : (isNext ? const Color(0xFF3551AE) : Colors.grey),
                                  size: 20.sp,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      prayer.nameArabic,
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                    if (isCompleted) ...[
                                       Text(
                                         (isOnTime ?? false) ? 'islamic.prayer_times.on_time_reward'.tr() : 'islamic.prayer_times.late_reward'.tr(),
                                         style: TextStyle(
                                           fontSize: 11.sp,
                                           color: const Color(0xFF27AE60),
                                           fontWeight: FontWeight.w600,
                                         ),
                                       ),
                                       SizedBox(height: 4.h),
                                       InkWell(
                                         onTap: () => context.push('/islamic-hub/azkar/reader/after_prayer'),
                                         borderRadius: BorderRadius.circular(6.r),
                                         child: Container(
                                           padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                           decoration: BoxDecoration(
                                             color: const Color(0xFF3551AE).withValues(alpha: isDark ? 0.25 : 0.1),
                                             borderRadius: BorderRadius.circular(6.r),
                                           ),
                                           child: Text(
                                             'islamic.prayer_times.after_prayer_azkar'.tr(),
                                             style: TextStyle(
                                               fontSize: 9.5.sp,
                                               fontWeight: FontWeight.bold,
                                               color: isDark ? Colors.white : const Color(0xFF3551AE),
                                             ),
                                           ),
                                         ),
                                       ),
                                     ]
                                     else if (isFuture)
                                       Text(
                                         'islamic.prayer_times.not_time_yet'.tr(),
                                         style: TextStyle(
                                           fontSize: 11.sp,
                                           color: Colors.grey,
                                           fontWeight: FontWeight.w500,
                                         ),
                                       ),
                                  ],
                                ),
                              ),
                              Text(
                                timeStr,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: isNext
                                      ? const Color(0xFF3551AE)
                                      : (isDark ? Colors.white70 : Colors.black87),
                                ),
                              ),
                              if (prayer.type != PrayerType.sunrise) ...[
                                SizedBox(width: 8.w),
                                IconButton(
                                  tooltip: isCompleted
                                      ? 'islamic.prayer_times.already_logged'.tr()
                                      : (isFuture ? 'islamic.prayer_times.not_time_yet'.tr() : 'islamic.prayer_times.log_prayer'.tr()),
                                  icon: Icon(
                                    isCompleted
                                        ? IconsaxPlusBold.tick_square
                                        : (isFuture ? IconsaxPlusLinear.clock : IconsaxPlusLinear.tick_square),
                                    color: isCompleted
                                        ? const Color(0xFF27AE60)
                                        : (isFuture ? Colors.grey.withValues(alpha: 0.4) : const Color(0xFF3551AE)),
                                  ),
                                  onPressed: () {
                                    if (isCompleted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('islamic.prayer_times.already_logged_named'.tr(args: [prayer.nameArabic])),
                                          action: SnackBarAction(
                                            label: 'islamic.prayer_times.after_prayer_azkar'.tr(),
                                            textColor: Colors.amber,
                                            onPressed: () => context.push('/islamic-hub/azkar/reader/after_prayer'),
                                          ),
                                          duration: const Duration(seconds: 3),
                                        ),
                                      );
                                      return;
                                    }
                                    if (isFuture) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('islamic.prayer_times.not_yet_named'.tr(args: [prayer.nameArabic])),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                      return;
                                    }

                                    PrayerCheckinDialog.showCheckinFlow(
                                      context,
                                      prayer,
                                    );
                                  },
                                ),
                              ],
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),

                SizedBox(height: 24.h),

                // Azan Settings Card
                Text(
                  'islamic.azan_settings'.tr(),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),

                SizedBox(height: 10.h),

                BlocBuilder<IslamicSettingsCubit, IslamicSettingsState>(
                  builder: (context, settingsState) {
                    final settings = settingsState.settings;
                    final isThisSoundPlaying = _isPlaying;

                    return Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF161B2B) : Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: isDark ? Colors.white12 : Colors.black12,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Azan Sound Selector with Audio Preview Button
                          // Azan Sound Selector
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  InkWell(
                                    onTap: () => _togglePlayAzan(settings.azanSound),
                                    borderRadius: BorderRadius.circular(50.r),
                                    child: Container(
                                      padding: EdgeInsets.all(8.r),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0xFF3551AE).withValues(alpha: isThisSoundPlaying ? 0.25 : 0.1),
                                      ),
                                      child: Icon(
                                        isThisSoundPlaying ? Icons.stop_circle_rounded : IconsaxPlusBold.volume_high,
                                        color: isThisSoundPlaying ? const Color(0xFF27AE60) : const Color(0xFF3551AE),
                                        size: 20.sp,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                  Expanded(
                                    child: Text(
                                      'islamic.azan_sound'.tr(),
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () => _togglePlayAzan(settings.azanSound),
                                    borderRadius: BorderRadius.circular(8.r),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                      decoration: BoxDecoration(
                                        color: isThisSoundPlaying
                                            ? const Color(0xFF27AE60).withValues(alpha: 0.15)
                                            : const Color(0xFF3551AE).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8.r),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            isThisSoundPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
                                            size: 16.sp,
                                            color: isThisSoundPlaying ? const Color(0xFF27AE60) : const Color(0xFF3551AE),
                                          ),
                                          SizedBox(width: 4.w),
                                          Text(
                                            isThisSoundPlaying ? 'إيقاف' : 'استماع',
                                            style: TextStyle(
                                              fontSize: 11.sp,
                                              fontWeight: FontWeight.bold,
                                              color: isThisSoundPlaying ? const Color(0xFF27AE60) : const Color(0xFF3551AE),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E2438) : const Color(0xFFF4F6F9),
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                    color: isDark ? Colors.white10 : Colors.black12,
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: settings.azanSound,
                                    isExpanded: true,
                                    dropdownColor: isDark ? const Color(0xFF1E2438) : Colors.white,
                                    items: [
                                      DropdownMenuItem(value: 'makkah', child: Text('islamic.makkah'.tr())),
                                      DropdownMenuItem(value: 'madinah', child: Text('islamic.madinah'.tr())),
                                      DropdownMenuItem(value: 'egypt', child: Text('islamic.egypt'.tr())),
                                      DropdownMenuItem(value: 'takbeerat_only', child: Text('islamic.takbeerat_only'.tr())),
                                      DropdownMenuItem(value: 'notification_only', child: Text('islamic.notification_only'.tr())),
                                      DropdownMenuItem(value: 'silent', child: Text('islamic.silent'.tr())),
                                    ],
                                    onChanged: (val) {
                                      if (val != null) {
                                        context.read<IslamicSettingsCubit>().updateAzanSound(val);
                                        _togglePlayAzan(val);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 14.h),
                          const Divider(),
                          SizedBox(height: 10.h),

                          // Calculation Method
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8.r),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFF3551AE).withValues(alpha: 0.1),
                                    ),
                                    child: Icon(
                                      IconsaxPlusBold.calendar_search,
                                      color: const Color(0xFF3551AE),
                                      size: 20.sp,
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                  Expanded(
                                    child: Text(
                                      'islamic.location_method'.tr(),
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E2438) : const Color(0xFFF4F6F9),
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                    color: isDark ? Colors.white10 : Colors.black12,
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: settings.calculationMethod,
                                    isExpanded: true,
                                    dropdownColor: isDark ? const Color(0xFF1E2438) : Colors.white,
                                    items: [
                                      DropdownMenuItem(value: 'Egyptian', child: Text('islamic.egyptian_authority'.tr())),
                                      DropdownMenuItem(value: 'UmmAlQura', child: Text('islamic.umm_al_qura'.tr())),
                                      DropdownMenuItem(value: 'MuslimWorldLeague', child: Text('islamic.muslim_world_league'.tr())),
                                    ],
                                    onChanged: (val) {
                                      if (val != null) {
                                        context.read<IslamicSettingsCubit>().updateCalculationMethod(val);
                                        context.read<PrayerTimesCubit>().loadPrayerTimes();
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),

                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    ),
  ),
);
}
}

