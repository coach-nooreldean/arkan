import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/islamic_hub_repository.dart';
import '../cubits/islamic_settings_cubit.dart';
import '../cubits/prayer_times_cubit.dart';

class IslamicActivationPromptDialog extends StatefulWidget {
  const IslamicActivationPromptDialog({super.key});

  static bool _isShowing = false;

  /// Checks if the user has already seen the onboarding prompt.
  /// If not, displays this dialog once and saves their choice permanently across all devices.
  static Future<bool> maybeShow(BuildContext context) async {
    if (_isShowing) return false;

    try {
      final repo = context.read<IslamicHubRepository>();
      final islamicCubit = context.read<IslamicSettingsCubit>();

      // 1. Check in-memory state
      if (islamicCubit.state.settings.hasSeenOnboardingPrompt) {
        return false;
      }

      // 2. Fetch authoritative settings to avoid race condition on launch
      final settings = await repo.getSettings();
      if (settings.hasSeenOnboardingPrompt) {
        return false;
      }

      _isShowing = true;

      if (!context.mounted) {
        _isShowing = false;
        return false;
      }

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop && !islamicCubit.state.settings.hasSeenOnboardingPrompt) {
              islamicCubit.setOnboardingPromptSeen(false);
            }
          },
          child: const IslamicActivationPromptDialog(),
        ),
      );

      return true;
    } catch (_) {
      return false;
    } finally {
      _isShowing = false;
    }
  }

  @override
  State<IslamicActivationPromptDialog> createState() =>
      _IslamicActivationPromptDialogState();
}

class _IslamicActivationPromptDialogState
    extends State<IslamicActivationPromptDialog> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26.r)),
      backgroundColor: isDark ? const Color(0xFF161928) : Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 16,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: Padding(
        padding: EdgeInsets.all(22.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Glowing top dome icon
            Container(
              width: 68.w,
              height: 68.w,
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
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedMosque01,
                  color: Colors.white,
                  size: 34.sp,
                ),
              ),
            ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),

            SizedBox(height: 18.h),

            // Title
            Text(
              'islamic.activation_dialog_title'.tr(),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 10.h),

            // Description
            Text(
              'islamic.activation_dialog_desc'.tr(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.75),
                fontSize: 13.sp,
                height: 1.45,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 18.h),

            // Feature Highlights
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E2235) : const Color(0xFFF4F6FC),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: isDark ? Colors.white10 : Colors.black12,
                ),
              ),
              child: Column(
                children: [
                  _buildFeatureRow(
                    icon: HugeIcons.strokeRoundedClock01,
                    text: 'islamic.feature_prayers'.tr(),
                    isDark: isDark,
                  ),
                  SizedBox(height: 8.h),
                  _buildFeatureRow(
                    icon: HugeIcons.strokeRoundedBookOpen01,
                    text: 'islamic.feature_quran'.tr(),
                    isDark: isDark,
                  ),
                  SizedBox(height: 8.h),
                  _buildFeatureRow(
                    icon: IconsaxPlusBold.coin,
                    iconColor: const Color(0xFFF1C40F),
                    text: 'islamic.feature_coins'.tr(),
                    isDark: isDark,
                  ),
                ],
              ),
            ),

            SizedBox(height: 22.h),

            // Primary: Yes, activate
            InkWell(
              onTap: () async {
                final settingsCubit = context.read<IslamicSettingsCubit>();
                final prayerCubit = context.read<PrayerTimesCubit>();
                await settingsCubit.setOnboardingPromptSeen(true);
                prayerCubit.loadPrayerTimes();
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              borderRadius: BorderRadius.circular(16.r),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3551AE), Color(0xFF4C6EF5)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3551AE).withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      IconsaxPlusBold.tick_circle,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'islamic.activation_enable_btn'.tr(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 10.h),

            // Secondary: Skip / Not now
            TextButton(
              onPressed: () async {
                final settingsCubit = context.read<IslamicSettingsCubit>();
                await settingsCubit.setOnboardingPromptSeen(false);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: Text(
                'islamic.activation_skip_btn'.tr(),
                style: TextStyle(
                  color: cs.onSurface.withValues(alpha: 0.55),
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow({
    required dynamic icon,
    Color? iconColor,
    required String text,
    required bool isDark,
  }) {
    return Row(
      children: [
        if (icon is IconData)
          Icon(icon, size: 16.sp, color: iconColor ?? const Color(0xFF3551AE))
        else if (icon is List<List<dynamic>>)
          HugeIcon(
            icon: icon,
            size: 16.sp,
            color: iconColor ?? const Color(0xFF3551AE),
          ),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12.5.sp,
              color: isDark ? Colors.white70 : const Color(0xFF334155),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
