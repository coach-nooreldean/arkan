import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../../../shared/widgets/premium_background.dart';
import '../cubits/azkar_cubit.dart';
import '../../domain/entities/azkar_category_entity.dart';

class AzkarCategoryScreen extends StatelessWidget {
  const AzkarCategoryScreen({super.key});

  IconData _getCategoryIcon(String iconName) {
    switch (iconName) {
      case 'sun':
        return IconsaxPlusBold.sun_1;
      case 'moon':
        return IconsaxPlusBold.moon;
      case 'pray':
        return IconsaxPlusBold.clock;
      case 'bed':
        return IconsaxPlusBold.lamp_charge;
      case 'sunrise':
        return IconsaxPlusBold.sun_fog;
      case 'book-open':
        return IconsaxPlusBold.book_1;
      case 'shield-check':
        return IconsaxPlusBold.shield_tick;
      case 'car':
        return IconsaxPlusBold.car;
      case 'heart-circle':
        return IconsaxPlusBold.heart_circle;
      case 'trend-up':
        return IconsaxPlusBold.trend_up;
      case 'people':
        return IconsaxPlusBold.people;
      default:
        return IconsaxPlusBold.heart;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppTopBar(
        title: 'islamic.azkar_title'.tr(),
        isTransparent: true,
        showBackButton: false,
        actions: [
          TextButton.icon(
            onPressed: () => context.push('/tasbih'),
            icon: const Icon(IconsaxPlusBold.refresh_circle, size: 18, color: Color(0xFF8E44AD)),
            label: Text(
              'السبحة الذكية',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12.sp,
                color: const Color(0xFF8E44AD),
              ),
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: PremiumBackground(
        child: SafeArea(
          child: BlocBuilder<AzkarCubit, AzkarState>(
            builder: (context, state) {
              final categories = state.categories;

              if (state.isLoading && categories.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              final screenWidth = MediaQuery.sizeOf(context).width;
              final isWide = screenWidth >= 650;

              return Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: isWide
                      ? GridView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 440,
                            mainAxisExtent: 90,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: categories.length,
                          itemBuilder: (context, index) => _buildCategoryCard(context, categories[index], isDark),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                          itemCount: categories.length,
                          separatorBuilder: (_, __) => SizedBox(height: 12.h),
                          itemBuilder: (context, index) => _buildCategoryCard(context, categories[index], isDark),
                        ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, AzkarCategoryEntity cat, bool isDark) {
    final iconData = _getCategoryIcon(cat.icon);
    final color = Color(cat.colorValue);
    final isDone = cat.isFullyClaimedToday;

    return InkWell(
      onTap: () {
        context.read<AzkarCubit>().selectCategory(cat.id);
        context.push('/islamic-hub/azkar/reader/${cat.id}');
      },
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161B2B) : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isDone
                ? const Color(0xFF27AE60)
                : (isDark ? const Color(0xFF252E46) : const Color(0xFFE2E8F0)),
            width: isDone ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Center(
                child: Icon(iconData, color: color, size: 24.sp),
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    cat.name,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    '${cat.items.length} ذكر ودعاء',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            if (isDone)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF27AE60).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(IconsaxPlusBold.tick_circle, color: Color(0xFF27AE60), size: 14),
                    SizedBox(width: 4),
                    Text(
                      'مكتمل اليوم',
                      style: TextStyle(
                        color: Color(0xFF27AE60),
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              )
            else
              Icon(
                IconsaxPlusLinear.arrow_left_2,
                color: isDark ? Colors.white38 : Colors.black26,
                size: 18.sp,
              ),
          ],
        ),
      ),
    );
  }
}
