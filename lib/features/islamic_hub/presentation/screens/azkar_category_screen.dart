import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../../../shared/widgets/premium_background.dart';
import '../cubits/azkar_cubit.dart';

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
      ),
      body: PremiumBackground(
        child: SafeArea(
          child: BlocBuilder<AzkarCubit, AzkarState>(
            builder: (context, state) {
              final categories = state.categories;

              if (state.isLoading && categories.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              return Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 880),
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                  final cat = categories[index];
                  final iconData = _getCategoryIcon(cat.icon);
                  final color = Color(cat.colorValue);
                  final isDone = cat.isCompleted;

                  return InkWell(
                    onTap: () {
                      context.read<AzkarCubit>().selectCategory(cat.id);
                      context.push('/islamic-hub/azkar/reader/${cat.id}');
                    },
                    borderRadius: BorderRadius.circular(20.r),
                    child: Container(
                      padding: EdgeInsets.all(16.w),
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
                            width: 52.w,
                            height: 52.w,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Center(
                              child: Icon(iconData, color: color, size: 26.sp),
                            ),
                          ),
                          SizedBox(width: 14.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cat.name,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                                  ),
                                ),
                                SizedBox(height: 4.h),
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
                          if (cat.isFullyClaimedToday)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFF27AE60).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(IconsaxPlusBold.tick_circle, color: const Color(0xFF27AE60), size: 14.sp),
                                  SizedBox(width: 4.w),
                                  Text(
                                    cat.id == 'after_prayer' ? '5/5 مكتمل اليوم' : 'مكتمل اليوم',
                                    style: const TextStyle(
                                      color: Color(0xFF27AE60),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1C40F).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(IconsaxPlusBold.coin, color: const Color(0xFFB7950B), size: 14.sp),
                                  SizedBox(width: 4.w),
                                  Text(
                                    cat.id == 'after_prayer'
                                        ? '+${cat.rewardCoins} (${cat.dailyClaimsToday}/5)'
                                        : '+${cat.rewardCoins}',
                                    style: const TextStyle(
                                      color: Color(0xFFB7950B),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          SizedBox(width: 8.w),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14.sp,
                            color: isDark ? Colors.white38 : Colors.black26,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
          ),
        ),
      ),
    );
  }
}
