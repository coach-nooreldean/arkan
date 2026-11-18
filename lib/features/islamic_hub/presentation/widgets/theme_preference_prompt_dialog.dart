import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../domain/repositories/islamic_hub_repository.dart';
import '../cubits/islamic_settings_cubit.dart';

class ThemePreferencePromptDialog extends StatefulWidget {
  const ThemePreferencePromptDialog({super.key});

  static bool _isShowing = false;

  /// Displays the first-launch Light/Dark/System theme selection dialog once
  /// and persists the user's choice across launches.
  static Future<bool> maybeShow(BuildContext context) async {
    if (_isShowing) return false;

    try {
      final repo = context.read<IslamicHubRepository>();
      final settingsCubit = context.read<IslamicSettingsCubit>();

      if (settingsCubit.state.settings.hasChosenThemeOnStartup) {
        return false;
      }

      final settings = await repo.getSettings();
      if (settings.hasChosenThemeOnStartup) {
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
            if (didPop && !settingsCubit.state.settings.hasChosenThemeOnStartup) {
              settingsCubit.updateAppThemeMode(
                settingsCubit.state.settings.appThemeMode,
                markStartupChosen: true,
              );
            }
          },
          child: const ThemePreferencePromptDialog(),
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
  State<ThemePreferencePromptDialog> createState() =>
      _ThemePreferencePromptDialogState();
}

class _ThemePreferencePromptDialogState
    extends State<ThemePreferencePromptDialog> {
  late String _selectedMode;

  @override
  void initState() {
    super.initState();
    _selectedMode = context.read<IslamicSettingsCubit>().state.settings.appThemeMode;
  }

  void _selectMode(String mode) {
    setState(() {
      _selectedMode = mode;
    });
    context.read<IslamicSettingsCubit>().updateAppThemeMode(
          mode,
          markStartupChosen: false,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final deviceIsDark =
        MediaQuery.platformBrightnessOf(context) == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26.r)),
      backgroundColor: isDark ? const Color(0xFF161B2B) : Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 16,
      insetPadding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 24.h),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: EdgeInsets.all(22.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 62.w,
                height: 62.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3551AE), Color(0xFF6C5CE7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3551AE).withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    isDark ? IconsaxPlusBold.moon : IconsaxPlusBold.sun_1,
                    color: Colors.white,
                    size: 30.sp,
                  ),
                ),
              ).animate().scale(duration: 350.ms, curve: Curves.easeOutBack),
              SizedBox(height: 16.h),
              Text(
                'theme.prompt_title'.tr(),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                'theme.prompt_desc'.tr(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.72),
                  fontSize: 12.5.sp,
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 18.h),

              // Light vs Dark Side-by-Side Preview Cards
              Row(
                children: [
                  Expanded(
                    child: _buildModeCard(
                      mode: 'light',
                      title: 'theme.light'.tr(),
                      icon: IconsaxPlusBold.sun_1,
                      previewBg: const Color(0xFFF8FAFC),
                      previewBar: Colors.white,
                      previewAccent: const Color(0xFFF59E0B),
                      previewTextColor: const Color(0xFF1E293B),
                      isDarkDialog: isDark,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildModeCard(
                      mode: 'dark',
                      title: 'theme.dark'.tr(),
                      icon: IconsaxPlusBold.moon,
                      previewBg: const Color(0xFF0B0F19),
                      previewBar: const Color(0xFF1E293B),
                      previewAccent: const Color(0xFF818CF8),
                      previewTextColor: Colors.white,
                      isDarkDialog: isDark,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),

              // Automatic System Theme Option
              InkWell(
                onTap: () => _selectMode('system'),
                borderRadius: BorderRadius.circular(16.r),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: _selectedMode == 'system'
                        ? const Color(0xFF3551AE).withValues(alpha: 0.14)
                        : (isDark
                            ? const Color(0xFF1E2438)
                            : const Color(0xFFF4F6FC)),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: _selectedMode == 'system'
                          ? const Color(0xFF3551AE)
                          : (isDark ? Colors.white12 : Colors.black12),
                      width: _selectedMode == 'system' ? 1.8 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3551AE).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(
                          IconsaxPlusBold.mobile,
                          color: const Color(0xFF3551AE),
                          size: 18.sp,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'theme.system'.tr(),
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF1E293B),
                              ),
                            ),
                            Text(
                              deviceIsDark
                                  ? 'theme.device_current_dark'.tr()
                                  : 'theme.device_current_light'.tr(),
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        _selectedMode == 'system'
                            ? IconsaxPlusBold.tick_circle
                            : Icons.radio_button_unchecked_rounded,
                        color: _selectedMode == 'system'
                            ? const Color(0xFF3551AE)
                            : (isDark ? Colors.white30 : Colors.black26),
                        size: 20.sp,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              // Confirm CTA
              InkWell(
                onTap: () async {
                  final cubit = context.read<IslamicSettingsCubit>();
                  await cubit.updateAppThemeMode(
                    _selectedMode,
                    markStartupChosen: true,
                  );
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
                        'theme.confirm_btn'.tr(),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeCard({
    required String mode,
    required String title,
    required IconData icon,
    required Color previewBg,
    required Color previewBar,
    required Color previewAccent,
    required Color previewTextColor,
    required bool isDarkDialog,
  }) {
    final isSelected = _selectedMode == mode;

    return InkWell(
      onTap: () => _selectMode(mode),
      borderRadius: BorderRadius.circular(18.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: previewBg,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF3551AE)
                : (isDarkDialog ? Colors.white12 : Colors.black12),
            width: isSelected ? 2.2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF3551AE).withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: previewAccent, size: 22.sp),
                Icon(
                  isSelected
                      ? IconsaxPlusBold.tick_circle
                      : Icons.radio_button_unchecked_rounded,
                  color: isSelected
                      ? const Color(0xFF3551AE)
                      : previewTextColor.withValues(alpha: 0.35),
                  size: 18.sp,
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Container(
              height: 22.h,
              decoration: BoxDecoration(
                color: previewBar,
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              title,
              style: TextStyle(
                color: previewTextColor,
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
