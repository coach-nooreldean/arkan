import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../../../shared/widgets/premium_background.dart';
import '../cubits/qibla_cubit.dart';

class QiblaCompassScreen extends StatefulWidget {
  const QiblaCompassScreen({super.key});

  @override
  State<QiblaCompassScreen> createState() => _QiblaCompassScreenState();
}

class _QiblaCompassScreenState extends State<QiblaCompassScreen> {
  late final QiblaCubit _qiblaCubit;

  @override
  void initState() {
    super.initState();
    _qiblaCubit = context.read<QiblaCubit>();
    _qiblaCubit.initQibla();
    _qiblaCubit.startCompass();
  }

  @override
  void dispose() {
    _qiblaCubit.stopCompass();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocListener<QiblaCubit, QiblaState>(
      listenWhen: (prev, curr) => !prev.isFacingQibla && curr.isFacingQibla,
      listener: (context, state) {
        HapticFeedback.mediumImpact();
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppTopBar(
          title: 'islamic.qibla_title'.tr(),
          isTransparent: true,
        ),
        body: PremiumBackground(
          child: SafeArea(
            child: BlocBuilder<QiblaCubit, QiblaState>(
              builder: (context, state) {
                final angleRad = state.needleAngle * (math.pi / 180.0);
                final dialAngleRad = state.hasCompassSensor
                    ? -(state.currentHeading * (math.pi / 180.0))
                    : 0.0;
                final isFacing = state.hasCompassSensor && state.isFacingQibla;

                return Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Location & Degree Card
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF161B2B) : Colors.white,
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: isDark ? Colors.white10 : Colors.black12,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(
                                        IconsaxPlusBold.location,
                                        color: const Color(0xFF2980B9),
                                        size: 20.sp,
                                      ),
                                      SizedBox(width: 8.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              state.locationLabel,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.bold,
                                                color: isDark ? Colors.white : Colors.black87,
                                              ),
                                            ),
                                            Text(
                                              state.hasCompassSensor
                                                  ? 'القبلة: ${state.qiblaAngle.toStringAsFixed(1)}° • الهاتف: ${state.currentHeading.round()}°'
                                                  : 'زاوية القبلة: ${state.qiblaAngle.toStringAsFixed(1)}° من الشمال',
                                              style: TextStyle(
                                                fontSize: 11.sp,
                                                color: isDark ? Colors.white60 : Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                                  decoration: BoxDecoration(
                                    color: isFacing
                                        ? const Color(0xFF27AE60).withValues(alpha: 0.15)
                                        : const Color(0xFF2980B9).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Text(
                                    isFacing ? 'مواجه للقبلة ✓' : '${state.qiblaAngle.toInt()}°',
                                    style: TextStyle(
                                      color: isFacing
                                          ? const Color(0xFF27AE60)
                                          : const Color(0xFF2980B9),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // No-sensor fallback warning banner
                          if (!state.hasCompassSensor)
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B).withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(14.r),
                                border: Border.all(
                                  color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    IconsaxPlusBold.warning_2,
                                    color: const Color(0xFFF59E0B),
                                    size: 18.sp,
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(
                                      'islamic.qibla_no_sensor'.tr(
                                        args: [state.qiblaAngle.toStringAsFixed(1)],
                                      ),
                                      style: TextStyle(
                                        fontSize: 11.5.sp,
                                        color: isDark ? Colors.white : const Color(0xFF78350F),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Center Interactive Compass Dial
                          Center(
                            child: SizedBox(
                              width: 280.w,
                              height: 296.w,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Fixed top phone-heading pointer
                                  Positioned(
                                    top: 0,
                                    child: Icon(
                                      Icons.arrow_drop_down_rounded,
                                      size: 26.sp,
                                      color: isFacing
                                          ? const Color(0xFF27AE60)
                                          : const Color(0xFF2980B9),
                                    ),
                                  ),

                                  // Rotating Compass Outer Ring + Cardinal Points (N, E, S, W)
                                  Transform.rotate(
                                    angle: dialAngleRad,
                                    child: SizedBox(
                                      width: 272.w,
                                      height: 272.w,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Container(
                                            width: 272.w,
                                            height: 272.w,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: isDark
                                                  ? const Color(0xFF131826)
                                                  : Colors.white,
                                              border: Border.all(
                                                color: isFacing
                                                    ? const Color(0xFF27AE60)
                                                    : (isDark
                                                        ? const Color(0xFF283452)
                                                        : const Color(0xFFE2E8F0)),
                                                width: isFacing ? 3 : 2,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: isFacing
                                                      ? const Color(0xFF27AE60)
                                                          .withValues(alpha: 0.3)
                                                      : Colors.black.withValues(alpha: 0.08),
                                                  blurRadius: 24,
                                                  offset: const Offset(0, 8),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Positioned(
                                            top: 14.w,
                                            child: Text(
                                              'N',
                                              style: TextStyle(
                                                color: const Color(0xFFE74C3C),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16.sp,
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 14.w,
                                            child: Text(
                                              'S',
                                              style: TextStyle(
                                                color: isDark ? Colors.white60 : Colors.black54,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16.sp,
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            right: 16.w,
                                            child: Text(
                                              'E',
                                              style: TextStyle(
                                                color: isDark ? Colors.white60 : Colors.black54,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16.sp,
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: 16.w,
                                            child: Text(
                                              'W',
                                              style: TextStyle(
                                                color: isDark ? Colors.white60 : Colors.black54,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16.sp,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Rotating Needle pointed to Kaaba
                                  Transform.rotate(
                                    angle: angleRad,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Kaaba Icon on Needle Tip
                                        Container(
                                          padding: EdgeInsets.all(6.w),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isFacing
                                                ? const Color(0xFF27AE60)
                                                : const Color(0xFF2980B9),
                                            boxShadow: [
                                              BoxShadow(
                                                color: (isFacing
                                                        ? const Color(0xFF27AE60)
                                                        : const Color(0xFF2980B9))
                                                    .withValues(alpha: 0.5),
                                                blurRadius: 10,
                                              ),
                                            ],
                                          ),
                                          child: HugeIcon(
                                            icon: HugeIcons.strokeRoundedMosque01,
                                            color: Colors.white,
                                            size: 18.sp,
                                          ),
                                        ),
                                        Container(
                                          width: 4.w,
                                          height: 82.w,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                if (isFacing)
                                                  const Color(0xFF27AE60)
                                                else
                                                  const Color(0xFF2980B9),
                                                Colors.transparent,
                                              ],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                            ),
                                            borderRadius: BorderRadius.circular(2.r),
                                          ),
                                        ),
                                        SizedBox(height: 82.w),
                                      ],
                                    ),
                                  ),

                                  // Center Pivot
                                  Container(
                                    width: 16.w,
                                    height: 16.w,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Calibration Advice Tip
                          Container(
                            padding: EdgeInsets.all(14.w),
                            decoration: BoxDecoration(
                              color: state.needsCalibration
                                  ? const Color(0xFFF59E0B).withValues(alpha: 0.14)
                                  : (isDark ? const Color(0xFF161B2B) : const Color(0xFFF8FAFC)),
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: state.needsCalibration
                                    ? const Color(0xFFF59E0B).withValues(alpha: 0.45)
                                    : (isDark ? Colors.white10 : Colors.black12),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  IconsaxPlusLinear.info_circle,
                                  color: state.needsCalibration
                                      ? const Color(0xFFF59E0B)
                                      : const Color(0xFF2980B9),
                                  size: 20.sp,
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: Text(
                                    'islamic.qibla_accuracy_tip'.tr(),
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: isDark ? Colors.white70 : Colors.black87,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
