import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../../../shared/widgets/premium_background.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../rewards/presentation/widgets/arkan_coin_badge.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppTopBar(
        title: 'nav.more'.tr(),
        showBackButton: false,
        actions: [
          const ArkanCoinBadge(),
          SizedBox(width: 12.w),
        ],
      ),
      body: PremiumBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Brand Banner
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                          : [const Color(0xFFEEF2FF), const Color(0xFFE0E7FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFC7D2FE),
                    ),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16.r),
                        child: Image.asset(
                          AppAssets.logo,
                          width: 64.w,
                          height: 64.w,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'أركان | Arkan',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : const Color(0xFF1E293B),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'تطبيق إسلامي شامل يعمل محلياً بالكامل 100% بدون إنترنت',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark ? Colors.white70 : const Color(0xFF64748B),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                // Section 1: Islamic Resources
                Text(
                  'الكنوز الروحانية',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                  ),
                ),
                SizedBox(height: 12.h),

                _buildSettingTile(
                  context,
                  title: 'مكافآت وإنجازات أركان',
                  subtitle: 'الشارات الإيمانية ورصيد كوينز الطاعات المكتسبة',
                  icon: IconsaxPlusBold.coin,
                  iconColor: const Color(0xFFFFB300),
                  onTap: () => context.push('/rewards'),
                ),
                _buildSettingTile(
                  context,
                  title: 'islamic.qibla_title'.tr(),
                  subtitle: 'تحديد دقيق لاتجاه الكعبة المشرفة عبر البوصلة',
                  icon: IconsaxPlusBold.location,
                  iconColor: const Color(0xFF0284C7),
                  onTap: () => context.push('/qibla'),
                ),
                _buildSettingTile(
                  context,
                  title: 'islamic.names_of_allah_title'.tr(),
                  subtitle: 'الأسماء التسعة والتسعون مع المعاني والفضائل',
                  icon: IconsaxPlusBold.star_1,
                  iconColor: const Color(0xFF0D9488),
                  onTap: () => context.push('/names-of-allah'),
                ),
                _buildSettingTile(
                  context,
                  title: 'islamic.nawawi_hadiths_title'.tr(),
                  subtitle: 'أحاديث المصطفى ﷺ الجامعة لأصول الدين مع الشرح',
                  icon: IconsaxPlusBold.book,
                  iconColor: const Color(0xFF6366F1),
                  onTap: () => context.push('/hadith'),
                ),
                _buildSettingTile(
                  context,
                  title: 'islamic.khatm_dua_title'.tr(),
                  subtitle: 'دعاء ختم القرآن الكريم برواية مأثورة وواضحة',
                  icon: IconsaxPlusBold.book_saved,
                  iconColor: const Color(0xFFD97706),
                  onTap: () => context.push('/khatm-dua'),
                ),

                SizedBox(height: 24.h),

                // Section 2: Settings & Preferences
                Text(
                  'الإعدادات والضبط',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                  ),
                ),
                SizedBox(height: 12.h),

                _buildSettingTile(
                  context,
                  title: 'مواقيت الصلاة والأذان',
                  subtitle: 'ضبط المدينة، هيئة الحساب، وصوت الأذان والتنبيهات',
                  icon: IconsaxPlusBold.clock,
                  iconColor: const Color(0xFF3551AE),
                  onTap: () => context.push('/prayer-times'),
                ),
                _buildSettingTile(
                  context,
                  title: 'ملاحظات وتدبر القرآن',
                  subtitle: 'سجل الخواطر والفوائد التي دونتها حول الآيات',
                  icon: IconsaxPlusBold.note_2,
                  iconColor: const Color(0xFF10B981),
                  onTap: () => context.push('/quran-notes'),
                ),

                SizedBox(height: 24.h),

                // Privacy and Offline Badge
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0x0FFFFFFF) : const Color(0x05000000),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: isDark ? const Color(0x1FFFFFFF) : const Color(0x15000000),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        IconsaxPlusBold.shield_tick,
                        color: const Color(0xFF10B981),
                        size: 24.sp,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          'بياناتك وعباداتك ووردك محفوظة بأمان تام على جهازك محلياً ولا تُرفع لأي خوادم خارجية.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      child: Material(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Icon(icon, color: iconColor, size: 22.sp),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          fontSize: 11.5.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  IconsaxPlusLinear.arrow_left_2,
                  color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                  size: 18.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
