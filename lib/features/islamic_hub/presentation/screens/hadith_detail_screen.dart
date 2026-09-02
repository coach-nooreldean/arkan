import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../../../shared/widgets/premium_background.dart';
import '../../domain/entities/hadith_entity.dart';
import '../cubits/hadith_cubit.dart';

class HadithDetailScreen extends StatelessWidget {
  final HadithEntity? hadith;
  final int? hadithId;

  const HadithDetailScreen({
    super.key,
    this.hadith,
    this.hadithId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<HadithCubit, HadithState>(
      builder: (context, state) {
        final currentHadith = hadith ??
            (hadithId != null
                ? state.hadiths.where((h) => h.id == hadithId).firstOrNull
                : state.selectedHadith);

        if (currentHadith == null) {
          return Scaffold(
            appBar: AppTopBar(title: 'islamic.nawawi_hadiths_title'.tr(), isTransparent: true),
            body: Center(child: Text('islamic.hadith.not_found'.tr())),
          );
        }

        final isFav = state.favoriteIds.contains(currentHadith.id);

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppTopBar(
            title: 'islamic.hadith.hadith_num'.tr(args: [currentHadith.id.toString()]),
            isTransparent: true,
            actions: [
              IconButton(
                icon: Icon(
                  isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: isFav ? const Color(0xFFFF5252) : (isDark ? Colors.white : Colors.black87),
                ),
                onPressed: () {
                  context.read<HadithCubit>().toggleFavorite(currentHadith.id);
                },
              ),
              Builder(
                builder: (btnContext) {
                  return IconButton(
                    icon: const Icon(Icons.share_outlined),
                    tooltip: 'islamic.hadith.share_tooltip'.tr(),
                    onPressed: () async {
                      HapticFeedback.lightImpact();
                      final shareContent = '✨ ${currentHadith.title} (${'islamic.hadith.hadith_num'.tr(args: [currentHadith.id.toString()])})\n'
                          'عن ${currentHadith.narrator}:\n\n'
                          '${currentHadith.hadithText}\n\n'
                          '📍 [${currentHadith.reference}]\n\n'
                          '📖 الشرح: ${currentHadith.explanation}\n\n'
                          '#الأربعين_النووية #تطبيق_نورالدين';

                      final box = btnContext.findRenderObject() as RenderBox?;
                      final origin = box != null ? box.localToGlobal(Offset.zero) & box.size : null;

                      try {
                        final result = await Share.share(
                          shareContent,
                          subject: currentHadith.title,
                          sharePositionOrigin: origin,
                        );
                        if (result.status == ShareResultStatus.unavailable) {
                          throw Exception('Share unavailable');
                        }
                      } catch (_) {
                        await Clipboard.setData(ClipboardData(text: shareContent));
                        if (btnContext.mounted) {
                          ScaffoldMessenger.of(btnContext).clearSnackBars();
                          ScaffoldMessenger.of(btnContext).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                                  const SizedBox(width: 8),
                                  Text('islamic.hadith.copied_toast'.tr(),
                                      style: const TextStyle(fontFamily: 'Cairo')),
                                ],
                              ),
                              backgroundColor: const Color(0xFF3551AE),
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        }
                      }
                    },
                  );
                },
              ),
              SizedBox(width: 8.w),
            ],
          ),
          body: PremiumBackground(
            child: SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 880),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                    // Top Title Card
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF3551AE),
                            Color(0xFF1E2E62),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF3551AE).withValues(alpha: 0.3),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Text(
                                  'الحديث رقم ${currentHadith.id}',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Text(
                                currentHadith.reference,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: const Color(0xFFF1C40F),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            currentHadith.title,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'عن: ${currentHadith.narrator}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Matn (Hadith Text in Calligraphy)
                    Container(
                      padding: EdgeInsets.all(18.w),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF161B2B) : const Color(0xFFFBFBFD),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: isDark ? const Color(0xFF283452) : const Color(0xFFE2E8F0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Icon(IconsaxPlusBold.quote_down, color: const Color(0xFF3551AE), size: 20.sp),
                              SizedBox(width: 8.w),
                              Text(
                                'متن الحديث الشريف',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          SelectableText(
                            currentHadith.hadithText,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 16.5.sp,
                              fontFamily: 'Amiri',
                              height: 1.8,
                              fontWeight: FontWeight.w600,
                              color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Explanation / Sharh
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF161B2B) : Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: isDark ? const Color(0xFF283452) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(IconsaxPlusBold.book_1, color: const Color(0xFF16A085), size: 20.sp),
                              SizedBox(width: 8.w),
                              Text(
                                'الشرح والبيان الميسر',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            currentHadith.explanation,
                            style: TextStyle(
                              fontSize: 13.5.sp,
                              height: 1.7,
                              color: isDark ? Colors.white70 : const Color(0xFF334155),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Extracted Benefits
                    if (currentHadith.benefits.isNotEmpty) ...[
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF161B2B) : Colors.white,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: isDark ? const Color(0xFF283452) : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(IconsaxPlusBold.lamp_charge, color: const Color(0xFFE67E22), size: 20.sp),
                                SizedBox(width: 8.w),
                                Text(
                                  'الفوائد والدروس المستفادة',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            ...currentHadith.benefits.map((benefit) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: 8.h),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(top: 5.h),
                                      width: 6.w,
                                      height: 6.w,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFFE67E22),
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    Expanded(
                                      child: Text(
                                        benefit,
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          height: 1.6,
                                          color: isDark ? Colors.white70 : const Color(0xFF334155),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h),
                    ],

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              final text = '${'islamic.hadith.hadith_num'.tr(args: [currentHadith.id.toString()])}: ${currentHadith.title}\n\n${currentHadith.hadithText}\n\n[${currentHadith.reference}]';
                              Clipboard.setData(ClipboardData(text: text));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('islamic.hadith.copied_toast'.tr())),
                              );
                            },
                            icon: const Icon(Icons.copy_rounded, size: 18),
                            label: Text('islamic.hadith.copy_text'.tr()),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Builder(
                            builder: (btnContext) {
                              return ElevatedButton.icon(
                                onPressed: () async {
                                  HapticFeedback.lightImpact();
                                  final shareContent = '✨ ${currentHadith.title} (${'islamic.hadith.hadith_num'.tr(args: [currentHadith.id.toString()])})\n'
                                      'عن ${currentHadith.narrator}:\n\n'
                                      '${currentHadith.hadithText}\n\n'
                                      '📍 [${currentHadith.reference}]\n\n'
                                      '#الأربعين_النووية #تطبيق_نورالدين';

                                  final box = btnContext.findRenderObject() as RenderBox?;
                                  final origin = box != null ? box.localToGlobal(Offset.zero) & box.size : null;

                                  try {
                                    final result = await Share.share(
                                      shareContent,
                                      subject: currentHadith.title,
                                      sharePositionOrigin: origin,
                                    );
                                    if (result.status == ShareResultStatus.unavailable) {
                                      throw Exception('Share unavailable');
                                    }
                                  } catch (_) {
                                    await Clipboard.setData(ClipboardData(text: shareContent));
                                    if (btnContext.mounted) {
                                      ScaffoldMessenger.of(btnContext).clearSnackBars();
                                      ScaffoldMessenger.of(btnContext).showSnackBar(
                                        SnackBar(
                                          content: Row(
                                            children: [
                                              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                                              const SizedBox(width: 8),
                                              Text('islamic.hadith.copied_toast'.tr(),
                                                  style: const TextStyle(fontFamily: 'Cairo')),
                                            ],
                                          ),
                                          backgroundColor: const Color(0xFF3551AE),
                                          behavior: SnackBarBehavior.floating,
                                          duration: const Duration(seconds: 2),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                      );
                                    }
                                  }
                                },
                                icon: const Icon(Icons.share_outlined, size: 18),
                                label: const Text('مشاركة الحديث'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3551AE),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  },
);
}
}
