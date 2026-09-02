import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/entities/prayer_time_entity.dart';

class PrayerCountdownHeader extends StatelessWidget {
  final DayPrayerTimes? dayPrayerTimes;
  final PrayerTimeItem? nextPrayer;
  final Duration remainingTime;
  final VoidCallback? onLocationTap;
  final void Function(PrayerTimeItem)? onPrayerTap;

  const PrayerCountdownHeader({
    super.key,
    required this.dayPrayerTimes,
    required this.nextPrayer,
    required this.remainingTime,
    this.onLocationTap,
    this.onPrayerTap,
  });

  String _formatDuration(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final nextName = nextPrayer?.nameArabic ?? 'الفجر';
    final nextTimeStr = nextPrayer != null ? DateFormat('hh:mm a', 'ar').format(nextPrayer!.time) : '--:--';
    final location = dayPrayerTimes?.locationName ?? 'Cairo, Egypt';
    final hijri = (dayPrayerTimes?.hijriDay.isNotEmpty ?? false)
        ? '${dayPrayerTimes!.hijriDay} ${dayPrayerTimes!.hijriMonth} ${dayPrayerTimes!.hijriYear} هـ'
        : 'اليوم';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E2640), const Color(0xFF131828)]
              : [const Color(0xFF3551AE), const Color(0xFF223A8C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : const Color(0xFF3551AE)).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Hijri Date & Location
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(IconsaxPlusLinear.calendar_1, color: Colors.white, size: 14.sp),
                    SizedBox(width: 6.w),
                    Text(
                      hijri,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: onLocationTap,
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(IconsaxPlusLinear.location, color: Colors.white, size: 14.sp),
                      SizedBox(width: 4.w),
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 120.w),
                        child: Text(
                          location,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),

          // Center Next Prayer & Countdown
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'islamic.next_prayer'.tr(),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 13.sp,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1C40F),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            nextName,
                            style: TextStyle(
                              color: const Color(0xFF7F6000),
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      nextTimeStr,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Countdown badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(
                  children: [
                    Text(
                      'islamic.time_remaining'.tr(),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 11.sp,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      _formatDuration(remainingTime),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                  .shimmer(duration: 2000.ms, color: Colors.white24),
            ],
          ),

          SizedBox(height: 20.h),

          // Daily 5 Prayers Check Mini-Bubbles
          if (dayPrayerTimes != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: dayPrayerTimes!.prayers
                  .where((p) => p.type != PrayerType.sunrise)
                  .map((p) {
                final isNext = nextPrayer?.type == p.type;
                final isDone = p.isCompleted;

                return InkWell(
                  onTap: () => onPrayerTap?.call(p),
                  borderRadius: BorderRadius.circular(12.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: isDone
                          ? const Color(0xFF27AE60)
                          : isNext
                              ? Colors.white.withValues(alpha: 0.25)
                              : Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12.r),
                      border: isNext
                          ? Border.all(color: const Color(0xFFF1C40F), width: 1.5)
                          : null,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          isDone
                              ? IconsaxPlusBold.tick_circle
                              : isNext
                                  ? IconsaxPlusBold.clock
                                  : IconsaxPlusLinear.clock,
                          color: isDone ? Colors.white : (isNext ? const Color(0xFFF1C40F) : Colors.white70),
                          size: 16.sp,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          p.nameArabic,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.sp,
                            fontWeight: isNext ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
