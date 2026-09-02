import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/sound_effects_service.dart';
import '../cubits/prayer_times_cubit.dart';
import '../../domain/entities/prayer_time_entity.dart';

class PrayerCheckinDialog extends StatefulWidget {
  final PrayerTimeItem prayer;
  final void Function(bool isOnTime) onCheckin;
  final VoidCallback onDismiss;

  const PrayerCheckinDialog({
    super.key,
    required this.prayer,
    required this.onCheckin,
    required this.onDismiss,
  });

  static bool _isShowing = false;

  static Future<void> showCheckinFlow(
    BuildContext context,
    PrayerTimeItem prayer,
  ) async {
    const userId = 'local_user';
    final prayerCubit = context.read<PrayerTimesCubit>();

    await show(
      context,
      prayer: prayer,
      onCheckin: (isOnTime) async {
        await prayerCubit.recordPrayer(
          userId: userId,
          prayer: prayer,
          isOnTime: isOnTime,
        );
        if (context.mounted) {
          SoundEffectsService.instance.playSuccess();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isOnTime
                  ? '✨ تقبل الله طاعتكم، تم تسجيل صلاة ${prayer.nameArabic} في وقتها'
                  : '✨ تقبل الله طاعتكم، تم تسجيل صلاة ${prayer.nameArabic}'),
              duration: const Duration(seconds: 3),
              backgroundColor: const Color(0xFF3551AE),
            ),
          );
        }
      },
      onDismiss: () {
        prayerCubit.dismissPendingCheckin();
      },
    );
  }

  static Future<void> show(
    BuildContext context, {
    required PrayerTimeItem prayer,
    required void Function(bool isOnTime) onCheckin,
    required VoidCallback onDismiss,
  }) async {
    if (_isShowing) return;
    _isShowing = true;
    bool hasCheckedIn = false;
    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (ctx) => PrayerCheckinDialog(
          prayer: prayer,
          onCheckin: (isOnTime) {
            hasCheckedIn = true;
            onCheckin(isOnTime);
          },
          onDismiss: onDismiss,
        ),
      );
    } finally {
      _isShowing = false;
      if (!hasCheckedIn) {
        onDismiss();
      }
    }
  }

  @override
  State<PrayerCheckinDialog> createState() => _PrayerCheckinDialogState();
}

class _PrayerCheckinDialogState extends State<PrayerCheckinDialog> {
  int _step = 0; // 0 = Prayer checkin, 1 = Azkar question
  bool _isOnTime = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      backgroundColor: isDark ? const Color(0xFF161928) : Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 12,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: Padding(
        padding: EdgeInsets.all(22.w),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.05, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: _step == 0
              ? _buildPrayerStep(context, theme, cs, isDark)
              : _buildAzkarStep(context, theme, cs, isDark),
        ),
      ),
    );
  }

  Widget _buildPrayerStep(BuildContext context, ThemeData theme, ColorScheme cs, bool isDark) {
    return Column(
      key: const ValueKey('step_prayer'),
      mainAxisSize: MainAxisSize.min,
      children: [
        // Top glowing mosque icon
        Container(
          width: 64.w,
          height: 64.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF3551AE), Color(0xFF6C5CE7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3551AE).withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedMosque01,
              color: Colors.white,
              size: 32.sp,
            ),
          ),
        ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),

        SizedBox(height: 16.h),

        // Title
        Text(
          'islamic.checkin_dialog_title'.tr(args: [widget.prayer.nameArabic]),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 8.h),

        // Subtitle
        Text(
          'islamic.checkin_dialog_desc'.tr(),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.65),
            fontSize: 13.sp,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 24.h),

        // Option 1: Yes, on time (+5 coins)
        InkWell(
          onTap: () {
            widget.onCheckin(true);
            setState(() {
              _isOnTime = true;
              _step = 1;
            });
          },
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF27AE60), Color(0xFF2ECC71)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF27AE60).withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white24,
                  ),
                  child: Icon(
                    IconsaxPlusBold.tick_circle,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'islamic.prayed_on_time'.tr(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'islamic.prayed_on_time_desc'.tr(),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1C40F),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(IconsaxPlusBold.coin, color: const Color(0xFF7F6000), size: 14.sp),
                      SizedBox(width: 4.w),
                      Text(
                        '+5',
                        style: TextStyle(
                          color: const Color(0xFF7F6000),
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 10.h),

        // Option 2: Yes, late (+1 coin)
        InkWell(
          onTap: () {
            widget.onCheckin(false);
            setState(() {
              _isOnTime = false;
              _step = 1;
            });
          },
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2235) : const Color(0xFFF1F4F9),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isDark ? Colors.white12 : Colors.black12,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
                  ),
                  child: Icon(
                    IconsaxPlusLinear.clock,
                    color: isDark ? Colors.white70 : Colors.black87,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'islamic.prayed_late'.tr(),
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'islamic.prayed_late_desc'.tr(),
                        style: TextStyle(
                          color: isDark ? Colors.white60 : const Color(0xFF64748B),
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(IconsaxPlusBold.coin, color: const Color(0xFFF39C12), size: 14.sp),
                      SizedBox(width: 4.w),
                      Text(
                        '+1',
                        style: TextStyle(
                          color: cs.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ).animate().slideY(begin: 0.2, delay: 50.ms, duration: 300.ms),

        SizedBox(height: 12.h),

        // Option 3: Not yet / Dismiss
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            widget.onDismiss();
          },
          child: Text(
            'islamic.not_prayed_yet'.tr(),
            style: TextStyle(
              color: cs.onSurface.withValues(alpha: 0.5),
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAzkarStep(BuildContext context, ThemeData theme, ColorScheme cs, bool isDark) {
    final coinsText = _isOnTime ? '+5 كوينز' : '+1 كوين';

    return Column(
      key: const ValueKey('step_azkar'),
      mainAxisSize: MainAxisSize.min,
      children: [
        // Glowing Tasbih celebration icon
        Container(
          width: 64.w,
          height: 64.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF00B894), Color(0xFF00CEC9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00B894).withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              IconsaxPlusBold.tick_circle,
              color: Colors.white,
              size: 32.sp,
            ),
          ),
        ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),

        SizedBox(height: 16.h),

        // Title
        Text(
          'تقبّل الله طاعتك! 🤲',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 8.h),

        // Subtitle
        Text(
          'تم تسجيل صلاة ${widget.prayer.nameArabic} وحصلت على $coinsText 🌟\nهل قرأت أذكار ما بعد الصلاة أم تريد قراءتها الآن؟',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.75),
            fontSize: 13.sp,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 22.h),

        // Option 1: Yes, open After-Prayer Azkar Reader
        InkWell(
          onTap: () {
            Navigator.of(context).pop();
            context.push('/islamic-hub/azkar/reader/after_prayer');
          },
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3551AE), Color(0xFF4C6EF5)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3551AE).withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  IconsaxPlusBold.book_saved,
                  color: Colors.white,
                  size: 20.sp,
                ),
                SizedBox(width: 10.w),
                Text(
                  'قراءة أذكار بعد الصلاة 📿',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ).animate().slideY(begin: 0.2, duration: 300.ms),

        SizedBox(height: 10.h),

        // Option 2: Done already / Not now
        InkWell(
          onTap: () {
            Navigator.of(context).pop();
          },
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2235) : const Color(0xFFF1F4F9),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isDark ? Colors.white12 : Colors.black12,
              ),
            ),
            child: Center(
              child: Text(
                'قرأتها بالفعل / ليس الآن',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black87,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
