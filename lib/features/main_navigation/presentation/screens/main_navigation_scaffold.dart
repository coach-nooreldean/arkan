import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../../../core/utils/haptic_feedback_helper.dart';
import '../../../islamic_hub/presentation/screens/islamic_hub_screen.dart';
import '../../../islamic_hub/presentation/screens/surah_index_screen.dart';
import '../../../islamic_hub/presentation/screens/azkar_category_screen.dart';
import '../../../islamic_hub/presentation/screens/worship_tracker_screen.dart';
import '../../../islamic_hub/presentation/screens/more_screen.dart';

class MainNavigationScaffold extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScaffold({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationScaffold> createState() => _MainNavigationScaffoldState();
}

class _MainNavigationScaffoldState extends State<MainNavigationScaffold> {
  late int _currentIndex;

  final List<Widget> _screens = const [
    IslamicHubScreen(),
    SurahIndexScreen(),
    AzkarCategoryScreen(),
    WorshipTrackerScreen(),
    MoreScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabSelected(int index) {
    if (index == _currentIndex) return;
    HapticHelper.light();
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          child: Align(
            alignment: Alignment.bottomCenter,
            heightFactor: 1.0,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 580),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28.r),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    height: 68.h,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xDE111827)
                          : const Color(0xE6FFFFFF),
                      borderRadius: BorderRadius.circular(28.r),
                      border: Border.all(
                        color: isDark
                            ? const Color(0x2EFFFFFF)
                            : const Color(0x333551AE),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildNavItem(
                          index: 0,
                          label: 'nav.home'.tr(),
                          activeIcon: IconsaxPlusBold.home_2,
                          inactiveIcon: IconsaxPlusLinear.home_2,
                          isDark: isDark,
                        ),
                        _buildNavItem(
                          index: 1,
                          label: 'nav.quran'.tr(),
                          activeIcon: IconsaxPlusBold.book_1,
                          inactiveIcon: IconsaxPlusLinear.book_1,
                          isDark: isDark,
                        ),
                        _buildNavItem(
                          index: 2,
                          label: 'nav.azkar'.tr(),
                          activeIcon: IconsaxPlusBold.heart,
                          inactiveIcon: IconsaxPlusLinear.heart,
                          isDark: isDark,
                        ),
                        _buildNavItem(
                          index: 3,
                          label: 'nav.worship'.tr(),
                          activeIcon: IconsaxPlusBold.task_square,
                          inactiveIcon: IconsaxPlusLinear.task_square,
                          isDark: isDark,
                        ),
                        _buildNavItem(
                          index: 4,
                          label: 'nav.more'.tr(),
                          activeIcon: IconsaxPlusBold.more,
                          inactiveIcon: IconsaxPlusLinear.more,
                          isDark: isDark,
                        ),
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

  Widget _buildNavItem({
    required int index,
    required String label,
    required IconData activeIcon,
    required IconData inactiveIcon,
    required bool isDark,
  }) {
    final isSelected = _currentIndex == index;
    const activeColor = Color(0xFF3551AE);
    final inactiveColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onTabSelected(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(vertical: 6.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                padding: EdgeInsets.symmetric(
                  horizontal: isSelected ? 14.w : 0,
                  vertical: 4.h,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? activeColor.withValues(alpha: isDark ? 0.22 : 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(
                  isSelected ? activeIcon : inactiveIcon,
                  size: 22.sp,
                  color: isSelected ? (isDark ? const Color(0xFF818CF8) : activeColor) : inactiveColor,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.5.sp,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? (isDark ? const Color(0xFF818CF8) : activeColor) : inactiveColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
