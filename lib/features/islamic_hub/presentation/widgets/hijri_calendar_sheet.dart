import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/hijri_calendar_helper.dart';

class HijriCalendarSheet extends StatelessWidget {
  const HijriCalendarSheet({super.key});

  static Future<void> show(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1B2030) : Colors.white,
      constraints: const BoxConstraints(maxWidth: 580),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (_) => const HijriCalendarSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final now = DateTime.now();
    final todayHijri = HijriCalendarHelper.fromGregorian(now);
    final todayTags = HijriCalendarHelper.getRecommendedFastingTags(now);
    final todayOccasion = HijriCalendarHelper.getIslamicOccasion(todayHijri);

    final upcomingSpecialDays = <({
      DateTime date,
      HijriDate hijri,
      List<String> tags,
      String? occasion,
    })>[];

    for (int offset = 0; offset < 32; offset++) {
      final d = now.add(Duration(days: offset));
      final h = HijriCalendarHelper.fromGregorian(d);
      final tags = HijriCalendarHelper.getRecommendedFastingTags(d);
      final occ = HijriCalendarHelper.getIslamicOccasion(h);
      if (tags.isNotEmpty || occ != null) {
        upcomingSpecialDays.add((date: d, hijri: h, tags: tags, occasion: occ));
      }
    }

    return SafeArea(
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.8),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    IconsaxPlusBold.moon,
                    color: const Color(0xFF10B981),
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'التقويم الهجري وأيام الصيام المستحبة',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        'اليوم: ${todayHijri.formattedAr}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (todayTags.isNotEmpty || todayOccasion != null) ...[
              SizedBox(height: 12.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.35),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (todayOccasion != null)
                      Text(
                        '✨ $todayOccasion',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                    if (todayTags.isNotEmpty)
                      Text(
                        'مُستحب اليوم: ${todayTags.join(' • ')}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xFF065F46),
                        ),
                      ),
                  ],
                ),
              ),
            ],

            SizedBox(height: 14.h),
            Text(
              'المناسبات والأيام الفاضلة خلال الشهر القادم:',
              style: TextStyle(
                fontSize: 12.5.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            SizedBox(height: 10.h),

            Expanded(
              child: ListView.separated(
                itemCount: upcomingSpecialDays.length,
                separatorBuilder: (_, __) => SizedBox(height: 8.h),
                itemBuilder: (context, index) {
                  final item = upcomingSpecialDays[index];
                  final gregorianLabel =
                      DateFormat('EEEE d MMMM', 'ar').format(item.date);
                  final isWhiteDay = HijriCalendarHelper.isWhiteDay(item.hijri);

                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF141826) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: isWhiteDay
                            ? const Color(0xFFF59E0B).withValues(alpha: 0.45)
                            : (isDark ? Colors.white10 : Colors.black12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44.w,
                          height: 44.w,
                          decoration: BoxDecoration(
                            color: (isWhiteDay
                                    ? const Color(0xFFF59E0B)
                                    : const Color(0xFF3551AE))
                                .withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Center(
                            child: Text(
                              '${item.hijri.day}',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color: isWhiteDay
                                    ? const Color(0xFFF59E0B)
                                    : const Color(0xFF3551AE),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.hijri.formattedAr,
                                style: TextStyle(
                                  fontSize: 13.5.sp,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                                ),
                              ),
                              Text(
                                gregorianLabel,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: isDark ? Colors.white60 : Colors.black54,
                                ),
                              ),
                              if (item.occasion != null || item.tags.isNotEmpty)
                                Padding(
                                  padding: EdgeInsets.only(top: 4.h),
                                  child: Text(
                                    [
                                      if (item.occasion != null) item.occasion!,
                                      ...item.tags,
                                    ].join(' • '),
                                    style: TextStyle(
                                      fontSize: 11.5.sp,
                                      fontWeight: FontWeight.w600,
                                      color: isWhiteDay
                                          ? const Color(0xFFD97706)
                                          : const Color(0xFF10B981),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
