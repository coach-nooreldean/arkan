import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../cubits/islamic_settings_cubit.dart';
import '../cubits/prayer_times_cubit.dart';

class IslamicHomeCard extends StatelessWidget {
  const IslamicHomeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const userId = 'local_user';

    return BlocBuilder<IslamicSettingsCubit, IslamicSettingsState>(
      builder: (context, settingsState) {
        // Only display if user has enabled the feature
        if (!settingsState.settings.isEnabled) {
          return const SizedBox.shrink();
        }

        return BlocBuilder<PrayerTimesCubit, PrayerTimesState>(
          builder: (context, prayerState) {
            if (prayerState.dayPrayerTimes == null && prayerState.status != PrayerTimesStatus.loading) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  context.read<PrayerTimesCubit>().loadPrayerTimes(userId: userId);
                }
              });
            }

            final next = prayerState.nextPrayer;
            final remaining = prayerState.remainingTimeToNext;
            final nextName = next?.nameArabic ?? 'الفجر';
            final nextTimeStr = next != null
                ? DateFormat('hh:mm a', 'ar').format(next.time)
                : '--:--';

            String formatRemaining(Duration d) {
              final h = d.inHours;
              final m = d.inMinutes % 60;
              if (h > 0) return 'متبقي $h س و $m د';
              return 'متبقي $m دقيقة';
            }

            return Container(
              margin: EdgeInsets.only(bottom: 16.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22.r),
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF161B2B), const Color(0xFF0F1320)]
                      : [const Color(0xFF3551AE), const Color(0xFF263D8C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: isDark ? const Color(0xFF2E3958) : Colors.white24,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3551AE).withValues(alpha: isDark ? 0.2 : 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => context.push('/islamic-hub'),
                  borderRadius: BorderRadius.circular(22.r),
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Row
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: HugeIcon(
                                icon: HugeIcons.strokeRoundedMosque01,
                                color: Colors.white,
                                size: 18.sp,
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'islamic.hub_title'.tr(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'الصلاة القادمة: $nextName ($nextTimeStr)',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.8),
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1C40F),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text(
                                formatRemaining(remaining),
                                style: TextStyle(
                                  color: const Color(0xFF5D4037),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11.sp,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 14.h),

                        // Quick Action Buttons Grid
                        Row(
                          children: [
                            _buildQuickAction(
                              context,
                              icon: IconsaxPlusLinear.book_1,
                              label: 'المصحف',
                              onTap: () => context.push('/islamic-hub/quran'),
                            ),
                            SizedBox(width: 8.w),
                            _buildQuickAction(
                              context,
                              icon: IconsaxPlusLinear.clock,
                              label: 'المواقيت',
                              onTap: () => context.push('/islamic-hub/prayer-times'),
                            ),
                            SizedBox(width: 8.w),
                            _buildQuickAction(
                              context,
                              icon: IconsaxPlusLinear.heart,
                              label: 'الأذكار',
                              onTap: () => context.push('/islamic-hub/azkar'),
                            ),
                            SizedBox(width: 8.w),
                            _buildQuickAction(
                              context,
                              icon: IconsaxPlusLinear.refresh_circle,
                              label: 'السبحة',
                              onTap: () => context.push('/islamic-hub/tasbih'),
                            ),
                            SizedBox(width: 8.w),
                            _buildQuickAction(
                              context,
                              icon: IconsaxPlusLinear.location,
                              label: 'القبلة',
                              onTap: () => context.push('/islamic-hub/qibla'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1);
          },
        );
      },
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 16.sp),
              SizedBox(height: 4.h),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
