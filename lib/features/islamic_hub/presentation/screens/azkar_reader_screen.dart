import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../../../shared/widgets/premium_background.dart';
import '../cubits/azkar_cubit.dart';
import '../../domain/entities/azkar_category_entity.dart';

class AzkarReaderScreen extends StatefulWidget {
  final String categoryId;

  const AzkarReaderScreen({super.key, required this.categoryId});

  @override
  State<AzkarReaderScreen> createState() => _AzkarReaderScreenState();
}

class _AzkarReaderScreenState extends State<AzkarReaderScreen> {
  late PageController _pageController;
  int _currentIndex = 0;
  bool _modalShownForCurrentCompletion = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    context.read<AzkarCubit>().selectCategory(widget.categoryId);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTap(AzkarItemEntity item) {
    const userId = 'local_user';
    context.read<AzkarCubit>().incrementItemCount(itemId: item.id, userId: userId);

    // Check if auto advance is desired when item is completed
    if (item.currentCount + 1 >= item.count) {
      final cat = context.read<AzkarCubit>().state.selectedCategory;
      if (cat != null) {
        if (_currentIndex < cat.items.length - 1) {
          Future.delayed(const Duration(milliseconds: 350), () {
            if (mounted && _pageController.hasClients) {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          });
        }
      }
    }
  }

  void _showCompletionModal(BuildContext context, AzkarCategoryEntity cat, int coins) {
    if (_modalShownForCurrentCompletion) return;
    _modalShownForCurrentCompletion = true;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: isDark ? const Color(0xFF161B2B) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      builder: (modalCtx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68.w,
                height: 68.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF27AE60).withValues(alpha: 0.15),
                  border: Border.all(color: const Color(0xFF27AE60), width: 2),
                ),
                child: Center(
                  child: Icon(Icons.check_rounded, color: const Color(0xFF27AE60), size: 36.sp),
                ),
              ),
              SizedBox(height: 14.h),
              Text(
                'تقبّل الله طاعتكم 🤲',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'أتممت قراءة ${cat.name} كاملة بنجاح وجعلها الله في ميزان حسناتك',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: isDark ? Colors.white70 : Colors.black54,
                  height: 1.4,
                ),
              ),
              if (coins > 0) ...[
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1C40F).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: const Color(0xFFF1C40F).withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(IconsaxPlusBold.crown, color: Color(0xFFF1C40F), size: 16),
                      SizedBox(width: 6.w),
                      Text(
                        '+$coins عملة إيمانية',
                        style: TextStyle(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFF1C40F),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: 22.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _modalShownForCurrentCompletion = false;
                        });
                        context.read<AzkarCubit>().resetCategoryProgress(cat.id);
                        if (_pageController.hasClients) {
                          _pageController.jumpToPage(0);
                        }
                        Navigator.of(modalCtx).pop();
                      },
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: Text('islamic.azkar_reader.replay_btn'.tr()),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 13.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(modalCtx).pop(); // Close modal
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop(); // Exit screen back to Azkar list
                        }
                      },
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: Text('islamic.azkar_reader.done_exit_btn'.tr()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF27AE60),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 13.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocConsumer<AzkarCubit, AzkarState>(
      listenWhen: (prev, current) =>
          prev.earnedCoinsLastAction != current.earnedCoinsLastAction &&
          current.earnedCoinsLastAction > 0,
      listener: (context, state) {
        if (state.earnedCoinsLastAction > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✨ تقبل الله طاعتكم وأثابكم خيراً على إتمام الأذكار'),
              backgroundColor: Color(0xFF3551AE),
            ),
          );
        }
      },
      builder: (context, state) {
        final cat = state.categories.where((c) => c.id == widget.categoryId).firstOrNull;

        if (cat == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final items = cat.items;
        final progress = cat.progressPercentage;
        final isCategoryDone = cat.isCompleted;

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppTopBar(
            title: cat.name,
            isTransparent: true,
            actions: [
              IconButton(
                icon: const Icon(IconsaxPlusLinear.refresh),
                tooltip: 'islamic.azkar_reader.reset_tooltip'.tr(),
                onPressed: () {
                  setState(() {
                    _modalShownForCurrentCompletion = false;
                  });
                  context.read<AzkarCubit>().resetCategoryProgress(cat.id);
                  if (_pageController.hasClients) {
                    _pageController.jumpToPage(0);
                  }
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
                  child: Column(
                    children: [
                      // Top Linear Progress Bar
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'الذكر ${_currentIndex + 1} من ${items.length}',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white70 : Colors.black54,
                                  ),
                                ),
                                Text(
                                  isCategoryDone ? 'مكتمل بنجاح ✓' : '${(progress * 100).toInt()}% مكتمل',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                    color: isCategoryDone ? const Color(0xFF2ECC71) : const Color(0xFF27AE60),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 6.h),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6.r),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 6.h,
                                backgroundColor: isDark ? const Color(0xFF1E2638) : const Color(0xFFE2E8F0),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isCategoryDone ? const Color(0xFF2ECC71) : const Color(0xFF27AE60),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Swiping Dhikr Cards PageView
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: items.length,
                          onPageChanged: (idx) => setState(() => _currentIndex = idx),
                          itemBuilder: (context, index) {
                            final item = items[index];
                            final isDone = item.isCompleted;
                            final remaining = (item.count - item.currentCount).clamp(0, item.count);

                            return SingleChildScrollView(
                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                              child: Column(
                                children: [
                                  // Main Dhikr Interactive Card
                                  GestureDetector(
                                    onTap: () => _onItemTap(item),
                                    child: Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(20.w),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF161B2B) : Colors.white,
                                        borderRadius: BorderRadius.circular(24.r),
                                        border: Border.all(
                                          color: isDone
                                              ? const Color(0xFF27AE60)
                                              : (isDark ? const Color(0xFF2B3650) : const Color(0xFFE2E8F0)),
                                          width: isDone ? 2 : 1,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: isDone
                                                ? const Color(0xFF27AE60).withValues(alpha: 0.15)
                                                : Colors.black.withValues(alpha: 0.04),
                                            blurRadius: 16,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        children: [
                                          // Top Share & Copy row
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                                decoration: BoxDecoration(
                                                  color: (isDone ? const Color(0xFF27AE60) : const Color(0xFF3551AE))
                                                      .withValues(alpha: 0.12),
                                                  borderRadius: BorderRadius.circular(10.r),
                                                ),
                                                child: Text(
                                                  isDone ? 'تم بنجاح ✓' : 'المتبقي: $remaining',
                                                  style: TextStyle(
                                                    color: isDone ? const Color(0xFF27AE60) : const Color(0xFF3551AE),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12.sp,
                                                  ),
                                                ),
                                              ),
                                              IconButton(
                                                icon: Icon(IconsaxPlusLinear.share, size: 18.sp),
                                                tooltip: 'مشاركة',
                                                onPressed: () {
                                                  Share.share('${item.text}\n\n${item.reward ?? ''}');
                                                },
                                              ),
                                            ],
                                          ),

                                          SizedBox(height: 16.h),

                                          // Main Arabic Dhikr Text
                                          Text(
                                            item.text,
                                            style: TextStyle(
                                              fontSize: 19.sp,
                                              fontWeight: FontWeight.w600,
                                              height: 1.8,
                                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                                            ),
                                            textAlign: TextAlign.center,
                                          ),

                                          SizedBox(height: 24.h),

                                          // Big Tap Counter Button
                                          Container(
                                            width: 140.w,
                                            height: 54.h,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(27.r),
                                              gradient: LinearGradient(
                                                colors: isDone
                                                    ? [const Color(0xFF27AE60), const Color(0xFF2ECC71)]
                                                    : [const Color(0xFF3551AE), const Color(0xFF4A69BD)],
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: (isDone ? const Color(0xFF27AE60) : const Color(0xFF3551AE))
                                                      .withValues(alpha: 0.35),
                                                  blurRadius: 12,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: Center(
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    isDone ? IconsaxPlusBold.tick_circle : IconsaxPlusBold.finger_cricle,
                                                    color: Colors.white,
                                                    size: 20.sp,
                                                  ),
                                                  SizedBox(width: 8.w),
                                                  Text(
                                                    '${item.currentCount} / ${item.count}',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16.sp,
                                                      fontFeatures: const [FontFeature.tabularFigures()],
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

                                  SizedBox(height: 14.h),

                                  // Reward / Reference Card
                                  if (item.reward != null || item.reference != null)
                                    Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(14.w),
                                      decoration: BoxDecoration(
                                        color: (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9))
                                            .withValues(alpha: 0.8),
                                        borderRadius: BorderRadius.circular(16.r),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if (item.reward != null) ...[
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Icon(IconsaxPlusBold.star_1, size: 16.sp, color: const Color(0xFFF39C12)),
                                                SizedBox(width: 8.w),
                                                Expanded(
                                                  child: Text(
                                                    'الفضل: ${item.reward!}',
                                                    style: TextStyle(
                                                      fontSize: 12.sp,
                                                      color: isDark ? Colors.white70 : Colors.black87,
                                                      height: 1.4,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (item.reference != null) SizedBox(height: 6.h),
                                          ],
                                          if (item.reference != null)
                                            Row(
                                              children: [
                                                Icon(IconsaxPlusLinear.book_saved, size: 14.sp, color: Colors.grey),
                                                SizedBox(width: 8.w),
                                                Text(
                                                  'المصدر: ${item.reference!}',
                                                  style: TextStyle(
                                                    fontSize: 11.sp,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      // Bottom Next/Previous & Completion Controls
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _currentIndex > 0
                                    ? () => _pageController.previousPage(
                                          duration: const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                        )
                                    : null,
                                icon: const Icon(Icons.arrow_back_ios_rounded, size: 14),
                                label: Text(
                                  'islamic.azkar_reader.previous_btn'.tr(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14.r),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            if (isCategoryDone || _currentIndex == items.length - 1)
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    _showCompletionModal(context, cat, state.earnedCoinsLastAction);
                                  },
                                  icon: const Icon(Icons.check_circle_rounded, size: 16),
                                  label: Text(
                                    'islamic.azkar_reader.finish_exit_btn'.tr(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF27AE60),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(vertical: 12.h),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14.r),
                                    ),
                                  ),
                                ),
                              )
                            else
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _currentIndex < items.length - 1
                                      ? () => _pageController.nextPage(
                                            duration: const Duration(milliseconds: 300),
                                            curve: Curves.easeInOut,
                                          )
                                      : null,
                                  icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                                  label: Text(
                                    'islamic.azkar_reader.next_btn'.tr(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(vertical: 12.h),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14.r),
                                    ),
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
            ),
          ),
        );
      },
    );
  }
}
