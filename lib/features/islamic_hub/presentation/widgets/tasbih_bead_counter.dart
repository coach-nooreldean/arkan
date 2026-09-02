import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TasbihBeadCounter extends StatelessWidget {
  final String phraseText;
  final String? rewardText;
  final int currentCount;
  final int targetCount;
  final int totalCount;
  final VoidCallback onTap;
  final VoidCallback onReset;

  const TasbihBeadCounter({
    super.key,
    required this.phraseText,
    this.rewardText,
    required this.currentCount,
    required this.targetCount,
    required this.totalCount,
    required this.onTap,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final progress = targetCount > 0 ? (currentCount % targetCount) / targetCount : 0.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Phrase Display Card
        Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 24.w),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1B2032) : Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: isDark ? const Color(0xFF2E3856) : const Color(0xFFE2E8F0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                phraseText,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              if (rewardText != null && rewardText!.isNotEmpty) ...[
                SizedBox(height: 8.h),
                Text(
                  rewardText!,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),

        SizedBox(height: 36.h),

        // Interactive Big Ring Button
        GestureDetector(
          onTap: onTap,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer Progress Ring
              SizedBox(
                width: 220.w,
                height: 220.w,
                child: CircularProgressIndicator(
                  value: progress == 0 && currentCount > 0 ? 1.0 : progress,
                  strokeWidth: 8.w,
                  backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3551AE)),
                ),
              ),

              // Glowing Circle Tap Button
              Container(
                width: 190.w,
                height: 190.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF253358), const Color(0xFF161F36)]
                        : [const Color(0xFF3551AE), const Color(0xFF233984)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3551AE).withValues(alpha: 0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$currentCount',
                        style: TextStyle(
                          fontSize: 48.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      Text(
                        'الهدف: $targetCount',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.white.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ).animate(target: currentCount > 0 ? 1 : 0).scale(
              begin: const Offset(1, 1),
              end: const Offset(0.96, 0.96),
              duration: 100.ms,
              curve: Curves.easeInOut,
            ),

        SizedBox(height: 36.h),

        // Bottom Controls: Reset & Total stats
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Reset Button
            InkWell(
              onTap: onReset,
              borderRadius: BorderRadius.circular(16.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: isDark ? Colors.white12 : Colors.black12,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      IconsaxPlusLinear.refresh,
                      size: 16.sp,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'إعادة ضبط',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(width: 16.w),

            // Total Count Badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: const Color(0xFF3551AE).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  Icon(
                    IconsaxPlusBold.award,
                    size: 16.sp,
                    color: const Color(0xFF3551AE),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'الإجمالي: $totalCount',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF3551AE),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
