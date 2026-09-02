import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../../../shared/widgets/premium_background.dart';
import '../cubits/worship_tracker_cubit.dart';

class WorshipTrackerScreen extends StatelessWidget {
  const WorshipTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppTopBar(
        title: 'islamic.worship_tracker.title'.tr(),
        isTransparent: true,
        actions: [
          IconButton(
            icon: const Icon(IconsaxPlusLinear.calendar_1),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: context.read<WorshipTrackerCubit>().state.selectedDate,
                firstDate: DateTime(2024),
                lastDate: DateTime.now().add(const Duration(days: 1)),
              );
              if (picked != null && context.mounted) {
                context.read<WorshipTrackerCubit>().loadLogForDate(picked);
              }
            },
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: PremiumBackground(
        child: SafeArea(
          child: BlocBuilder<WorshipTrackerCubit, WorshipTrackerState>(
            builder: (context, state) {
              final log = state.currentLog;
              const totalActs = 18; // 5 Fard + 5 Sunan + 2 Nawafil + 6 Wirds
              final completedActs = log.totalCompletedCount;
              final progressPct = (completedActs / totalActs).clamp(0.0, 1.0);
              final fardCount = log.totalFardCount;
              final rawatibRakats = log.totalSunanRawatibCount;

              final isToday = _isSameDay(state.selectedDate, DateTime.now());
              final dateLabel = isToday
                  ? 'اليوم (${DateFormat('d MMMM yyyy', 'ar').format(state.selectedDate)})'
                  : DateFormat('EEEE d MMMM yyyy', 'ar').format(state.selectedDate);

              return Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 880),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                    // Date Navigation Banner
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF181E2E) : Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: isDark ? const Color(0xFF2B3650) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_rounded, size: 16),
                            onPressed: () {
                              final prev = state.selectedDate.subtract(const Duration(days: 1));
                              context.read<WorshipTrackerCubit>().loadLogForDate(prev);
                            },
                          ),
                          Text(
                            dateLabel,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                            onPressed: isToday
                                ? null
                                : () {
                                    final next = state.selectedDate.add(const Duration(days: 1));
                                    context.read<WorshipTrackerCubit>().loadLogForDate(next);
                                  },
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 14.h),

                    // Progress Overview Card
                    Container(
                      padding: EdgeInsets.all(18.w),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF3551AE),
                            Color(0xFF1B2A5E),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24.r),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF3551AE).withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'مستوى إنجاز الطاعات اليومية',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    '$completedActs من $totalActs عملاً',
                                    style: TextStyle(
                                      fontSize: 22.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                width: 56.w,
                                height: 56.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.15),
                                ),
                                child: Center(
                                  child: Text(
                                    '${(progressPct * 100).toInt()}%',
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFFF1C40F),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 14.h),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.r),
                            child: LinearProgressIndicator(
                              value: progressPct,
                              backgroundColor: Colors.white24,
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2ECC71)),
                              minHeight: 8.h,
                            ),
                          ),
                          SizedBox(height: 14.h),
                          // Dual Badges: Fard + Sunan
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: fardCount == 5 ? const Color(0xFF2ECC71) : Colors.white24,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        fardCount == 5 ? Icons.check_circle_rounded : IconsaxPlusBold.shield_tick,
                                        color: fardCount == 5 ? const Color(0xFF2ECC71) : const Color(0xFFF1C40F),
                                        size: 16.sp,
                                      ),
                                      SizedBox(width: 6.w),
                                      Expanded(
                                        child: Text(
                                          'الفروض: $fardCount من 5',
                                          style: TextStyle(
                                            fontSize: 11.5.sp,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: rawatibRakats == 12 ? const Color(0xFF2ECC71) : Colors.white24,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        IconsaxPlusBold.crown,
                                        color: rawatibRakats == 12 ? const Color(0xFF2ECC71) : const Color(0xFFF1C40F),
                                        size: 16.sp,
                                      ),
                                      SizedBox(width: 6.w),
                                      Expanded(
                                        child: Text(
                                          'السنن: $rawatibRakats من 12 ركعة',
                                          style: TextStyle(
                                            fontSize: 11.5.sp,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // Section 1: الصلوات الخمس المفروضة
                    _buildSectionHeader('islamic.worship_tracker.section_fard'.tr(), IconsaxPlusBold.shield_tick, const Color(0xFF2980B9), isDark),
                    SizedBox(height: 8.h),
                    _buildWorshipCard(
                      context,
                      title: 'islamic.worship_tracker.fajr_title'.tr(),
                      subtitle: 'islamic.worship_tracker.fajr_sub'.tr(),
                      isChecked: log.fajrFard,
                      onToggle: () => _toggle(context, 'fajr_fard'),
                      isDark: isDark,
                      accentColor: const Color(0xFF2980B9),
                    ),
                    _buildWorshipCard(
                      context,
                      title: 'islamic.worship_tracker.dhuhr_title'.tr(),
                      subtitle: 'islamic.worship_tracker.dhuhr_sub'.tr(),
                      isChecked: log.dhuhrFard,
                      onToggle: () => _toggle(context, 'dhuhr_fard'),
                      isDark: isDark,
                      accentColor: const Color(0xFF2980B9),
                    ),
                    _buildWorshipCard(
                      context,
                      title: 'islamic.worship_tracker.asr_title'.tr(),
                      subtitle: 'islamic.worship_tracker.asr_sub'.tr(),
                      isChecked: log.asrFard,
                      onToggle: () => _toggle(context, 'asr_fard'),
                      isDark: isDark,
                      accentColor: const Color(0xFF2980B9),
                    ),
                    _buildWorshipCard(
                      context,
                      title: 'islamic.worship_tracker.maghrib_title'.tr(),
                      subtitle: 'islamic.worship_tracker.maghrib_sub'.tr(),
                      isChecked: log.maghribFard,
                      onToggle: () => _toggle(context, 'maghrib_fard'),
                      isDark: isDark,
                      accentColor: const Color(0xFF2980B9),
                    ),
                    _buildWorshipCard(
                      context,
                      title: 'islamic.worship_tracker.isha_title'.tr(),
                      subtitle: 'islamic.worship_tracker.isha_sub'.tr(),
                      isChecked: log.ishaFard,
                      onToggle: () => _toggle(context, 'isha_fard'),
                      isDark: isDark,
                      accentColor: const Color(0xFF2980B9),
                    ),

                    SizedBox(height: 18.h),

                    // Section 2: السنن الرواتب المؤكدة (12 ركعة)
                    _buildSectionHeader('islamic.worship_tracker.section_sunnah'.tr(), IconsaxPlusBold.star_1, const Color(0xFFE67E22), isDark),
                    SizedBox(height: 8.h),
                    _buildWorshipCard(
                      context,
                      title: 'islamic.worship_tracker.sunnah_fajr_title'.tr(),
                      subtitle: 'islamic.worship_tracker.sunnah_fajr_sub'.tr(),
                      isChecked: log.fajrSunnah,
                      onToggle: () => _toggle(context, 'fajr_sunnah'),
                      isDark: isDark,
                    ),
                    _buildWorshipCard(
                      context,
                      title: 'islamic.worship_tracker.sunnah_dhuhr_before_title'.tr(),
                      subtitle: 'islamic.worship_tracker.sunnah_dhuhr_before_sub'.tr(),
                      isChecked: log.dhuhrSunnahBefore,
                      onToggle: () => _toggle(context, 'dhuhr_sunnah_before'),
                      isDark: isDark,
                    ),
                    _buildWorshipCard(
                      context,
                      title: 'islamic.worship_tracker.sunnah_dhuhr_after_title'.tr(),
                      subtitle: 'islamic.worship_tracker.sunnah_dhuhr_after_sub'.tr(),
                      isChecked: log.dhuhrSunnahAfter,
                      onToggle: () => _toggle(context, 'dhuhr_sunnah_after'),
                      isDark: isDark,
                    ),
                    _buildWorshipCard(
                      context,
                      title: 'islamic.worship_tracker.sunnah_maghrib_title'.tr(),
                      subtitle: 'islamic.worship_tracker.sunnah_maghrib_sub'.tr(),
                      isChecked: log.maghribSunnah,
                      onToggle: () => _toggle(context, 'maghrib_sunnah'),
                      isDark: isDark,
                    ),
                    _buildWorshipCard(
                      context,
                      title: 'islamic.worship_tracker.sunnah_isha_title'.tr(),
                      subtitle: 'islamic.worship_tracker.sunnah_isha_sub'.tr(),
                      isChecked: log.ishaSunnah,
                      onToggle: () => _toggle(context, 'isha_sunnah'),
                      isDark: isDark,
                    ),

                    SizedBox(height: 18.h),

                    // Section 3: الصلوات والنوافل المستحبة
                    _buildSectionHeader('islamic.worship_tracker.section_nawafil'.tr(), IconsaxPlusBold.moon, const Color(0xFF8E44AD), isDark),
                    SizedBox(height: 8.h),
                    _buildWorshipCard(
                      context,
                      title: 'islamic.worship_tracker.duha_title'.tr(),
                      subtitle: 'islamic.worship_tracker.duha_sub'.tr(),
                      isChecked: log.duhaPrayer,
                      onToggle: () => _toggle(context, 'duha_prayer'),
                      isDark: isDark,
                      accentColor: const Color(0xFF8E44AD),
                    ),
                    _buildWorshipCard(
                      context,
                      title: 'islamic.worship_tracker.qiyam_title'.tr(),
                      subtitle: 'islamic.worship_tracker.qiyam_sub'.tr(),
                      isChecked: log.qiyamAndWitr,
                      onToggle: () => _toggle(context, 'qiyam_witr'),
                      isDark: isDark,
                      accentColor: const Color(0xFF8E44AD),
                    ),

                    SizedBox(height: 18.h),

                    // Section 4: الأوراد والفضائل اليومية
                    _buildSectionHeader('islamic.worship_tracker.section_daily_deeds'.tr(), IconsaxPlusBold.heart, const Color(0xFF16A085), isDark),
                    SizedBox(height: 8.h),
                    _buildWorshipCard(
                      context,
                      title: 'islamic.worship_tracker.azkar_title'.tr(),
                      subtitle: 'islamic.worship_tracker.azkar_sub'.tr(),
                      isChecked: log.morningEveningAzkar,
                      onToggle: () => _toggle(context, 'morning_evening_azkar'),
                      isDark: isDark,
                      accentColor: const Color(0xFF16A085),
                    ),
                    _buildWorshipCard(
                      context,
                      title: 'islamic.worship_tracker.quran_wird_title'.tr(),
                      subtitle: 'islamic.worship_tracker.quran_wird_sub'.tr(),
                      isChecked: log.quranWird,
                      onToggle: () => _toggle(context, 'quran_wird'),
                      isDark: isDark,
                      accentColor: const Color(0xFF16A085),
                    ),
                    _buildWorshipCard(
                      context,
                      title: 'islamic.worship_tracker.surah_mulk_title'.tr(),
                      subtitle: 'islamic.worship_tracker.surah_mulk_sub'.tr(),
                      isChecked: log.surahMulk,
                      onToggle: () => _toggle(context, 'surah_mulk'),
                      isDark: isDark,
                      accentColor: const Color(0xFF16A085),
                    ),
                    _buildWorshipCard(
                      context,
                      title: 'islamic.worship_tracker.surah_kahf_title'.tr(),
                      subtitle: 'islamic.worship_tracker.surah_kahf_sub'.tr(),
                      isChecked: log.surahKahf,
                      onToggle: () => _toggle(context, 'surah_kahf'),
                      isDark: isDark,
                      accentColor: const Color(0xFF16A085),
                    ),
                    _buildWorshipCard(
                      context,
                      title: 'islamic.worship_tracker.fasting_title'.tr(),
                      subtitle: 'islamic.worship_tracker.fasting_sub'.tr(),
                      isChecked: log.fastingSunnah,
                      onToggle: () => _toggle(context, 'fasting_sunnah'),
                      isDark: isDark,
                      accentColor: const Color(0xFF16A085),
                    ),
                    _buildWorshipCard(
                      context,
                      title: 'islamic.worship_tracker.sadaqah_title'.tr(),
                      subtitle: 'islamic.worship_tracker.sadaqah_sub'.tr(),
                      isChecked: log.dailyCharity,
                      onToggle: () => _toggle(context, 'daily_charity'),
                      isDark: isDark,
                      accentColor: const Color(0xFF16A085),
                    ),

                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          );
        },
          ),
        ),
      ),
    );
  }

  void _toggle(BuildContext context, String key) {
    HapticFeedback.lightImpact();
    context.read<WorshipTrackerCubit>().toggleItem(key);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color, bool isDark) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18.sp),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildWorshipCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool isChecked,
    required VoidCallback onToggle,
    required bool isDark,
    Color? accentColor,
  }) {
    final activeColor = accentColor ?? const Color(0xFF27AE60);

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF181E2E) : Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isChecked
                    ? activeColor
                    : (isDark ? const Color(0xFF2B3650) : const Color(0xFFE2E8F0)),
                width: isChecked ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 26.w,
                  height: 26.w,
                  decoration: BoxDecoration(
                    color: isChecked
                        ? activeColor
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isChecked
                          ? activeColor
                          : (isDark ? Colors.white38 : Colors.black26),
                      width: 2,
                    ),
                  ),
                  child: isChecked
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          fontWeight: isChecked ? FontWeight.bold : FontWeight.w600,
                          color: isChecked
                              ? activeColor
                              : (isDark ? Colors.white : const Color(0xFF1E293B)),
                          decoration: isChecked ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
