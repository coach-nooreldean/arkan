import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../../../shared/widgets/premium_background.dart';
import '../cubits/prayer_times_cubit.dart';
import '../cubits/quran_cubit.dart';
import '../../domain/entities/prayer_time_entity.dart';
import '../widgets/prayer_countdown_header.dart';
import '../widgets/prayer_checkin_dialog.dart';

class IslamicHubScreen extends StatefulWidget {
  const IslamicHubScreen({super.key});

  @override
  State<IslamicHubScreen> createState() => _IslamicHubScreenState();
}

class _IslamicHubScreenState extends State<IslamicHubScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PrayerTimesCubit>().loadPrayerTimes(userId: 'local_user');
  }

  void _showPrayerCheckin(BuildContext context, PrayerTimeItem prayer) {
    final prayerCubit = context.read<PrayerTimesCubit>();
    final isCompleted = prayerCubit.state.isPrayerCompleted(prayer.nameEnglish);
    final now = DateTime.now();

    if (isCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('islamic.prayer_times.already_logged_named'.tr(args: [prayer.nameArabic])),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    if (prayer.time.isAfter(now)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('islamic.prayer_times.not_yet_named'.tr(args: [prayer.nameArabic])),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    PrayerCheckinDialog.showCheckinFlow(context, prayer);
  }

  static const List<Map<String, String>> _dailyInspirations = [
    {
      'ayah': '﴿أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ﴾',
      'surah': 'سورة الرعد: 28',
      'reflection': 'الطمأنينة الحقيقية وسكينة الروح تنبع من كثرة ذكر الله وتلاوة كتابه.',
    },
    {
      'ayah': '﴿وَإِذَا سَأَلَكَ عِبَادِي عَنِّي فَإِنِّي قَرِيبٌ أُجِيبُ دَعْوَةَ الدَّاعِ إِذَا دَعَانِ﴾',
      'surah': 'سورة البقرة: 186',
      'reflection': 'الله أقرب إليك من حبل الوريد، يسمع نجواك ويستجيب دعاءك إذا أخلصت.',
    },
    {
      'ayah': '﴿وَمَن يَتَّقِ اللَّهَ يَجْعَل لَّهُ مَخْرَجًا * وَيَرْزُقْهُ مِنْ حَيْثُ لَا يَحْتَسِبُ﴾',
      'surah': 'سورة الطلاق: 2-3',
      'reflection': 'تقوى الله مفتاح كل فرج وباب واسع للرزق المبارك الذي لا يُتوقع.',
    },
    {
      'ayah': '﴿فَإِنَّ مَعَ الْعُسْرِ يُسْرًا * إِنَّ مَعَ الْعُسْرِ يُسْرًا﴾',
      'surah': 'سورة الشرح: 5-6',
      'reflection': 'لن يغلب عسر يسرين، فمع كل شدة يتنزل اللطف والفرج من الله.',
    },
    {
      'ayah': '﴿وَتَوَكَّلْ عَلَى الْحَيِّ الَّذِي لَا يَمُوتُ وَسَبِّحْ بِحَمْدِهِ﴾',
      'surah': 'سورة الفرقان: 58',
      'reflection': 'التوكل على الحي القيوم يملأ القلب شجاعة وثقة ورضا.',
    },
  ];

  Map<String, String> get _todayInspiration {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return _dailyInspirations[dayOfYear % _dailyInspirations.length];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final inspiration = _todayInspiration;

    final screenWidth = MediaQuery.sizeOf(context).width;
    final gridCrossAxisCount = screenWidth >= 1000 ? 4 : (screenWidth >= 650 ? 3 : 2);
    final gridAspectRatio = screenWidth >= 1000 ? 1.45 : (screenWidth >= 650 ? 1.35 : 1.25);

    return BlocListener<PrayerTimesCubit, PrayerTimesState>(
      listenWhen: (prev, current) =>
          current.pendingCheckinPrayer != null && prev.pendingCheckinPrayer != current.pendingCheckinPrayer,
      listener: (context, state) {
        if (state.pendingCheckinPrayer != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              _showPrayerCheckin(context, state.pendingCheckinPrayer!);
            }
          });
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppTopBar(
          title: 'islamic.hub_title'.tr(),
          isTransparent: true,
          showBackButton: false,
          actions: [
            IconButton(
              icon: Icon(IconsaxPlusLinear.setting_2, color: isDark ? Colors.white : cs.primary),
              onPressed: () => context.push('/islamic-hub/prayer-times'),
            ),
            SizedBox(width: 8.w),
          ],
        ),
        body: PremiumBackground(
          child: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                await context.read<PrayerTimesCubit>().loadPrayerTimes(userId: 'local_user');
              },
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1080),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Prayer Countdown Hero Header
                        BlocBuilder<PrayerTimesCubit, PrayerTimesState>(
                          builder: (context, state) {
                            return PrayerCountdownHeader(
                              dayPrayerTimes: state.dayPrayerTimes,
                              nextPrayer: state.nextPrayer,
                              remainingTime: state.remainingTimeToNext,
                              onLocationTap: () => context.push('/prayer-times'),
                              onPrayerTap: (prayer) => _showPrayerCheckin(context, prayer),
                            );
                          },
                        ),

                      SizedBox(height: 18.h),

                      // Daily Inspiration Card (قبس اليوم)
                      _buildInspirationCard(context, inspiration, isDark),

                      SizedBox(height: 22.h),

                      // Section 1: Main Core Modules Grid
                      Text(
                        'islamic.hub.section_core'.tr(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),

                      SizedBox(height: 12.h),

                      // Islamic Core Modules Responsive Grid
                      GridView.count(
                        crossAxisCount: gridCrossAxisCount,
                        crossAxisSpacing: 12.w,
                        mainAxisSpacing: 12.h,
                        childAspectRatio: gridAspectRatio,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildModuleCard(
                            context,
                            title: 'islamic.quran_title'.tr(),
                            subtitle: 'islamic.hub.quran_sub'.tr(),
                            icon: IconsaxPlusBold.book_1,
                            color: const Color(0xFF16A085),
                            route: '/quran',
                          ),
                          _buildModuleCard(
                            context,
                            title: 'islamic.azkar_title'.tr(),
                            subtitle: 'islamic.hub.azkar_sub'.tr(),
                            icon: IconsaxPlusBold.heart,
                            color: const Color(0xFFE67E22),
                            route: '/azkar',
                          ),
                          _buildModuleCard(
                            context,
                            title: 'islamic.smart_tasbih'.tr(),
                            subtitle: 'islamic.hub.tasbih_sub'.tr(),
                            icon: IconsaxPlusBold.refresh_circle,
                            color: const Color(0xFF8E44AD),
                            route: '/tasbih',
                          ),
                          _buildModuleCard(
                            context,
                            title: 'islamic.qibla_title'.tr(),
                            subtitle: 'islamic.hub.qibla_sub'.tr(),
                            icon: IconsaxPlusBold.location,
                            color: const Color(0xFF2980B9),
                            route: '/qibla',
                          ),
                        ],
                      ),

                      SizedBox(height: 22.h),

                      // Section 2: Extended Spiritual Features
                      Text(
                        'islamic.hub.section_extended'.tr(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),

                      SizedBox(height: 12.h),

                      // Responsive Grid for Extended Features
                      GridView.count(
                        crossAxisCount: gridCrossAxisCount,
                        crossAxisSpacing: 12.w,
                        mainAxisSpacing: 12.h,
                        childAspectRatio: gridAspectRatio,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildModuleCard(
                            context,
                            title: 'islamic.names_of_allah_title'.tr(),
                            subtitle: 'islamic.hub.names_of_allah_sub'.tr(),
                            icon: IconsaxPlusBold.star_1,
                            color: const Color(0xFF00897B),
                            route: '/islamic-hub/names-of-allah',
                          ),
                          _buildModuleCard(
                            context,
                            title: 'islamic.nawawi_hadiths_title'.tr(),
                            subtitle: 'islamic.hub.hadith_sub'.tr(),
                            icon: IconsaxPlusBold.book,
                            color: const Color(0xFF3551AE),
                            route: '/islamic-hub/hadith',
                          ),
                          _buildModuleCard(
                            context,
                            title: 'islamic.khatm_dua_title'.tr(),
                            subtitle: 'islamic.hub.khatm_dua_sub'.tr(),
                            icon: IconsaxPlusBold.book_saved,
                            color: const Color(0xFFD35400),
                            route: '/islamic-hub/khatm-dua',
                          ),
                          _buildModuleCard(
                            context,
                            title: 'islamic.worship_tracker.title'.tr(),
                            subtitle: 'islamic.hub.worship_tracker_sub'.tr(),
                            icon: IconsaxPlusBold.task_square,
                            color: const Color(0xFF27AE60),
                            route: '/islamic-hub/worship-tracker',
                          ),
                        ],
                      ),

                      SizedBox(height: 20.h),

                      // Continue Reading Quran Banner
                      BlocBuilder<QuranCubit, QuranState>(
                        builder: (context, quranState) {
                          final page = quranState.currentPage;
                          final surah = quranState.currentSurah?.name ?? 'الفاتحة';
                          return InkWell(
                            onTap: () => context.push('/islamic-hub/quran'),
                            borderRadius: BorderRadius.circular(20.r),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isDark
                                      ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                                      : [const Color(0xFFF8FAFC), const Color(0xFFE2E8F0)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(
                                  color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(10.w),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF16A085).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(14.r),
                                    ),
                                    child: Icon(
                                      IconsaxPlusBold.book_saved,
                                      color: const Color(0xFF16A085),
                                      size: 24.sp,
                                    ),
                                  ),
                                  SizedBox(width: 14.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'islamic.continue_reading'.tr(),
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.bold,
                                            color: isDark ? Colors.white : Colors.black87,
                                          ),
                                        ),
                                        SizedBox(height: 2.h),
                                        Text(
                                          'islamic.hub.surah_page_format'.tr(args: [surah, page.toString()]),
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: isDark ? Colors.white70 : Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 16.sp,
                                    color: isDark ? Colors.white60 : Colors.black45,
                                  ),
                                ],
                              ),
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
      ),
    ),
  );
}

  Widget _buildInspirationCard(
    BuildContext context,
    Map<String, String> inspiration,
    bool isDark,
  ) {
    final ayah = inspiration['ayah'] ?? '';
    final surah = inspiration['surah'] ?? '';
    final reflection = inspiration['reflection'] ?? '';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E2638), const Color(0xFF131826)]
              : [const Color(0xFFEFF6FF), const Color(0xFFE0E7FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark ? const Color(0xFF2D3748) : const Color(0xFFBFDBFE),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(IconsaxPlusBold.lamp_charge, color: Color(0xFFF59E0B), size: 20),
                  SizedBox(width: 8.w),
                  Text(
                    'قبس اليوم الإيماني',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFF59E0B),
                    ),
                  ),
                ],
              ),
              Builder(
                builder: (btnContext) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.copy_rounded, size: 18),
                        tooltip: 'نسخ الآية',
                        onPressed: () async {
                          HapticFeedback.lightImpact();
                          final shareText = '$ayah\n📍 $surah\n💡 $reflection\n\n#قبس_اليوم #تطبيق_نورالدين';
                          await Clipboard.setData(ClipboardData(text: shareText));
                          if (btnContext.mounted) {
                            ScaffoldMessenger.of(btnContext).clearSnackBars();
                            ScaffoldMessenger.of(btnContext).showSnackBar(
                              SnackBar(
                                content: const Row(
                                  children: [
                                    Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                                    SizedBox(width: 8),
                                    Text('تم نسخ القبس إلى الحافظة بنجاح 📋',
                                        style: TextStyle(fontFamily: 'Cairo')),
                                  ],
                                ),
                                backgroundColor: const Color(0xFF3551AE),
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 2),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            );
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.share_outlined, size: 18),
                        tooltip: 'مشاركة',
                        onPressed: () async {
                          HapticFeedback.lightImpact();
                          final shareText = '$ayah\n📍 $surah\n💡 $reflection\n\n#قبس_اليوم #تطبيق_نورالدين';
                          final box = btnContext.findRenderObject() as RenderBox?;
                          final origin = box != null ? box.localToGlobal(Offset.zero) & box.size : null;

                          try {
                            final result = await Share.share(
                              shareText,
                              subject: 'قبس اليوم الإيماني',
                              sharePositionOrigin: origin,
                            );
                            if (result.status == ShareResultStatus.unavailable) {
                              throw Exception('Share unavailable');
                            }
                          } catch (_) {
                            await Clipboard.setData(ClipboardData(text: shareText));
                            if (btnContext.mounted) {
                              ScaffoldMessenger.of(btnContext).clearSnackBars();
                              ScaffoldMessenger.of(btnContext).showSnackBar(
                                SnackBar(
                                  content: const Row(
                                    children: [
                                      Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                                      SizedBox(width: 8),
                                      Text('تم نسخ القبس إلى الحافظة بنجاح 📋',
                                          style: TextStyle(fontFamily: 'Cairo')),
                                    ],
                                  ),
                                  backgroundColor: const Color(0xFF3551AE),
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 2),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            ayah,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 15.sp,
              fontFamily: 'Amiri',
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
              height: 1.6,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            surah,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF3551AE),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            reflection,
            style: TextStyle(
              fontSize: 12.sp,
              color: isDark ? Colors.white70 : const Color(0xFF475569),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(route),
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF181E2E) : Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: isDark ? const Color(0xFF2B3650) : const Color(0xFFE2E8F0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: color, size: 20.sp),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10.5.sp,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
