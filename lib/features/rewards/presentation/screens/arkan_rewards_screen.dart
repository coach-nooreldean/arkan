import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:intl/intl.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../../../shared/widgets/premium_background.dart';
import '../../domain/entities/arkan_coin_transaction.dart';
import '../../domain/entities/arkan_achievement.dart';
import '../cubits/arkan_coins_cubit.dart';
import '../cubits/arkan_coins_state.dart';

class ArkanRewardsScreen extends StatelessWidget {
  const ArkanRewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const AppTopBar(
        title: 'مكافآت وإنجازات أركان',
        isTransparent: true,
        showBackButton: true,
      ),
      body: PremiumBackground(
        child: SafeArea(
          child: BlocBuilder<ArkanCoinsCubit, ArkanCoinsState>(
            builder: (context, state) {
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Golden Wallet & Rank Card
                        _buildWalletCard(context, state, isDark),
                        SizedBox(height: 24.h),

                        // 2. Achievements Section Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'الشارات الإيمانية 🏆',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF1E293B),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3551AE).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text(
                                '${state.unlockedAchievementsCount} من ${state.achievements.length} شارات',
                                style: TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF3551AE),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),

                        // Achievements Grid
                        _buildAchievementsGrid(context, state.achievements, isDark),
                        SizedBox(height: 28.h),

                        // 3. Transactions Log Section Header
                        Text(
                          'سجل الطاعات والمكافآت 📜',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                          ),
                        ),
                        SizedBox(height: 12.h),

                        // Transactions List
                        _buildTransactionsList(context, state.transactions, isDark),
                        SizedBox(height: 32.h),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWalletCard(BuildContext context, ArkanCoinsState state, bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1B243B),
            Color(0xFF0F172A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28.r),
        border: Border.all(
          color: const Color(0xFFFFD54F).withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFF9C4), Color(0xFFFFB300)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFB300).withValues(alpha: 0.4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        IconsaxPlusBold.coin,
                        color: const Color(0xFF7F6000),
                        size: 24.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'رصيد كوينز أركان',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12.sp,
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        '${state.totalCoins}',
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFFFFD54F),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Rank Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD54F).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: const Color(0xFFFFD54F).withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  state.rankTitle,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFFE082),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: Color(0xFF93C5FD), size: 18),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'اكسب كوينز عند المحافظة على الصلاة في وقتها (+5)، قراءة القرآن (+10)، وأذكار اليوم (+3) لتفتح شارات إيمانية جديدة.',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11.sp,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsGrid(
    BuildContext context,
    List<ArkanAchievement> achievements,
    bool isDark,
  ) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 650;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 2 : 1,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        mainAxisExtent: 105.h,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final a = achievements[index];
        return _buildAchievementCard(context, a, isDark);
      },
    );
  }

  Widget _buildAchievementCard(BuildContext context, ArkanAchievement a, bool isDark) {
    final isUnlocked = a.isUnlocked;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark
            ? (isUnlocked ? const Color(0xFF1E293B) : const Color(0xFF131826))
            : (isUnlocked ? Colors.white : const Color(0xFFF8FAFC)),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isUnlocked
              ? const Color(0xFFFFB300).withValues(alpha: 0.45)
              : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06)),
          width: isUnlocked ? 1.4 : 1.0,
        ),
        boxShadow: isUnlocked
            ? [
                BoxShadow(
                  color: const Color(0xFFFFB300).withValues(alpha: 0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          // Emoji Avatar
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isUnlocked
                  ? const Color(0xFFFFF9C4).withValues(alpha: isDark ? 0.2 : 0.8)
                  : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04)),
            ),
            child: Center(
              child: Text(
                a.iconEmoji,
                style: TextStyle(fontSize: 24.sp),
              ),
            ),
          ),
          SizedBox(width: 12.w),

          // Title & Progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      a.title,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                    if (isUnlocked)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF27AE60).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          'محققة ✅',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF27AE60),
                          ),
                        ),
                      )
                    else
                      Text(
                        '+${a.rewardCoins} 🪙',
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFB78103),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 3.h),
                Text(
                  a.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10.5.sp,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
                SizedBox(height: 6.h),
                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(6.r),
                  child: LinearProgressIndicator(
                    value: a.progressPercentage,
                    minHeight: 5.h,
                    backgroundColor: isDark ? Colors.white12 : Colors.black12,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isUnlocked ? const Color(0xFF27AE60) : const Color(0xFF3551AE),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(
    BuildContext context,
    List<ArkanCoinTransaction> transactions,
    bool isDark,
  ) {
    if (transactions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
          ),
        ),
        child: Column(
          children: [
            Icon(IconsaxPlusLinear.empty_wallet, size: 40.sp, color: Colors.grey),
            SizedBox(height: 8.h),
            Text(
              'لا توجد حركات كوينز مسجلة بعد',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'سجّل صلواتك في وقتها واقرأ أذكارك لتبدأ بجمع الكوينز ✨',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11.sp,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      separatorBuilder: (_, __) => SizedBox(height: 8.h),
      itemBuilder: (context, index) {
        final tx = transactions[index];
        final dateStr = DateFormat('d MMMM yyyy - hh:mm a', 'ar').format(tx.timestamp);

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFB300).withValues(alpha: 0.15),
                ),
                child: Center(
                  child: Icon(
                    IconsaxPlusBold.coin,
                    color: const Color(0xFFB78103),
                    size: 18.sp,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.title,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                    if (tx.subtitle != null && tx.subtitle!.isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Text(
                        tx.subtitle!,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 10.5.sp,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                    SizedBox(height: 2.h),
                    Text(
                      dateStr,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 9.5.sp,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '+${tx.amount} 🪙',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF27AE60),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
