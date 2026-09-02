import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../cubits/arkan_coins_cubit.dart';
import '../cubits/arkan_coins_state.dart';

class ArkanCoinBadge extends StatelessWidget {
  final bool compact;

  const ArkanCoinBadge({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ArkanCoinsCubit, ArkanCoinsState>(
      builder: (context, state) {
        return InkWell(
          onTap: () => context.push('/rewards'),
          borderRadius: BorderRadius.circular(20.r),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 8.w : 12.w,
              vertical: 5.h,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFFF3CD),
                  Color(0xFFFFE082),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: const Color(0xFFFFB300),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFB300).withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  IconsaxPlusBold.coin,
                  color: const Color(0xFFB78103),
                  size: 16.sp,
                ),
                SizedBox(width: 5.w),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                  child: Text(
                    '${state.totalCoins}',
                    key: ValueKey<int>(state.totalCoins),
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF7F6000),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
