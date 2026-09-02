import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../domain/entities/quran_khatmah_entity.dart';
import '../cubits/khatmah_cubit.dart';

class QuranKhatmahSheet extends StatefulWidget {
  final void Function(int page) onPageSelected;

  const QuranKhatmahSheet({super.key, required this.onPageSelected});

  static Future<void> show(BuildContext context, {required void Function(int page) onPageSelected}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(maxWidth: 640),
      builder: (ctx) => BlocProvider.value(
        value: context.read<KhatmahCubit>(),
        child: QuranKhatmahSheet(onPageSelected: onPageSelected),
      ),
    );
  }

  @override
  State<QuranKhatmahSheet> createState() => _QuranKhatmahSheetState();
}

class _QuranKhatmahSheetState extends State<QuranKhatmahSheet> {
  bool _isCreating = false;
  final TextEditingController _titleController = TextEditingController(text: 'ختمتي');
  final TextEditingController _numberInputController = TextEditingController();

  // Mode: 0 = By Days (بعدد الأيام), 1 = By Pages (بعدد الصفحات يومياً)
  int _planMode = 0;
  int _targetDays = 30;
  int _pagesPerDay = 20;

  @override
  void initState() {
    super.initState();
    _pagesPerDay = (604 / _targetDays).ceil();
    _numberInputController.text = '$_targetDays';
  }

  void _onDaysChanged(int days) {
    final clamped = days.clamp(1, 365);
    setState(() {
      _targetDays = clamped;
      _pagesPerDay = (604 / clamped).ceil();
      if (_planMode == 0) {
        _numberInputController.text = '$clamped';
      }
    });
  }

  void _onPagesChanged(int pages) {
    final clamped = pages.clamp(1, 604);
    setState(() {
      _pagesPerDay = clamped;
      _targetDays = (604 / clamped).ceil().clamp(1, 365);
      if (_planMode == 1) {
        _numberInputController.text = '$clamped';
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _numberInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E2433) : Colors.white;
    const primaryColor = Color(0xFF3551AE);

    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
              width: 44.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(Icons.bookmark_added_rounded, color: Colors.amber[800], size: 22.r),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'نظام الختمات والورد اليومي',
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                      ),
                      Text(
                        'خطط لختمتك وتابع وردك اليومي بسهولة واكسب مكافآت',
                        style: TextStyle(fontSize: 11.sp, color: Colors.grey, fontFamily: 'Cairo'),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: isDark ? Colors.white12 : Colors.black12),

          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.r),
              child: BlocBuilder<KhatmahCubit, KhatmahState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.r),
                        child: const CircularProgressIndicator(color: primaryColor),
                      ),
                    );
                  }

                  if (_isCreating || state.khatmahs.isEmpty) {
                    return _buildCreateKhatmahView(context, isDark, primaryColor);
                  }

                  final active = state.activeKhatmah;
                  if (active == null) {
                    return _buildCreateKhatmahView(context, isDark, primaryColor);
                  }

                  return _buildActiveKhatmahView(context, active, isDark, primaryColor);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveKhatmahView(
    BuildContext context,
    QuranKhatmahEntity khatmah,
    bool isDark,
    Color primaryColor,
  ) {
    final progress = khatmah.progressPercentage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Card of active Khatmah
        Container(
          padding: EdgeInsets.all(18.r),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF26324D), const Color(0xFF192133)]
                  : [const Color(0xFF3551AE), const Color(0xFF1E3275)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    khatmah.title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      'خطة ${khatmah.targetDays} يوم',
                      style: TextStyle(fontSize: 11.sp, color: Colors.white, fontWeight: FontWeight.w600, fontFamily: 'Cairo'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Progress Bar
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 10.h,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFD54F)),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    '${(progress * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFFD54F),
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Stats Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('الصفحة الحالية', '${khatmah.currentPage} / 604'),
                  _buildStatItem('ورد اليوم', '${khatmah.pagesPerDay} صفحة'),
                  _buildStatItem('الأيام المتبقية', '${khatmah.daysRemaining} يوم'),
                ],
              ),
            ],
          ),
        ),

        SizedBox(height: 14.h),

        // Today's Ward Reward Card
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: (khatmah.isRewardClaimedToday || khatmah.pagesReadToday >= khatmah.pagesPerDay)
                ? Colors.green.withValues(alpha: 0.12)
                : Colors.amber.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: (khatmah.isRewardClaimedToday || khatmah.pagesReadToday >= khatmah.pagesPerDay)
                  ? Colors.green.withValues(alpha: 0.3)
                  : Colors.amber.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                (khatmah.isRewardClaimedToday || khatmah.pagesReadToday >= khatmah.pagesPerDay)
                    ? Icons.check_circle_rounded
                    : Icons.stars_rounded,
                color: (khatmah.isRewardClaimedToday || khatmah.pagesReadToday >= khatmah.pagesPerDay)
                    ? Colors.green
                    : Colors.amber[800],
                size: 24.r,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (khatmah.isRewardClaimedToday || khatmah.pagesReadToday >= khatmah.pagesPerDay)
                          ? 'أحسنت! أتممت ورد اليوم (+5 كوينز 🪙)'
                          : 'قرأت اليوم: ${khatmah.pagesReadToday} من ${khatmah.pagesPerDay} صفحة',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                        color: (khatmah.isRewardClaimedToday || khatmah.pagesReadToday >= khatmah.pagesPerDay)
                            ? Colors.green
                            : (isDark ? Colors.amber[300] : Colors.amber[900]),
                      ),
                    ),
                    if (!khatmah.isRewardClaimedToday && khatmah.pagesReadToday < khatmah.pagesPerDay)
                      Text(
                        'متبقي ${khatmah.remainingPagesToday} صفحة لإتمام ورد اليوم وكسب 5 كوينز',
                        style: TextStyle(fontSize: 10.sp, color: Colors.grey, fontFamily: 'Cairo'),
                      ),
                  ],
                ),
              ),
              if (!khatmah.isRewardClaimedToday)
                TextButton(
                  onPressed: () {
                    context.read<KhatmahCubit>().claimManualWardReward();
                  },
                  child: Text(
                    'تأكيد الإتمام 🪙',
                    style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                  ),
                ),
            ],
          ),
        ),

        SizedBox(height: 14.h),

        // Action Buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onPageSelected(khatmah.currentPage);
                },
                icon: const Icon(Icons.menu_book_rounded, color: Colors.white),
                label: Text(
                  'متابعة القراءة (صفحة ${khatmah.currentPage})',
                  style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Cairo'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 12.h),

        // New Khatmah / Delete
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _isCreating = true;
                });
              },
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: Text(
                'islamic.khatmah.create_new'.tr(),
                style: TextStyle(fontSize: 12.sp, fontFamily: 'Cairo'),
              ),
            ),
            TextButton.icon(
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (dialogCtx) => AlertDialog(
                    title: Text('islamic.khatmah.delete_title'.tr(), style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                    content: Text('islamic.khatmah.delete_confirm'.tr(), style: const TextStyle(fontFamily: 'Cairo')),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogCtx),
                        child: Text('common.cancel'.tr(), style: const TextStyle(fontFamily: 'Cairo')),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(dialogCtx);
                          context.read<KhatmahCubit>().deleteKhatmah(khatmah.id);
                          setState(() {
                            _isCreating = false;
                          });
                        },
                        child: Text('common.delete'.tr(), style: const TextStyle(fontFamily: 'Cairo', color: Colors.redAccent)),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
              label: Text(
                'islamic.khatmah.delete_title'.tr(),
                style: TextStyle(fontSize: 12.sp, color: Colors.redAccent, fontFamily: 'Cairo'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Cairo',
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            color: Colors.white70,
            fontFamily: 'Cairo',
          ),
        ),
      ],
    );
  }

  Widget _buildCreateKhatmahView(BuildContext context, bool isDark, Color primaryColor) {
    final chipBg = isDark ? const Color(0xFF141824) : const Color(0xFFF4F6FB);
    final chipBorder = isDark ? Colors.white12 : Colors.black12;
    final textColor = isDark ? Colors.white : Colors.black87;
    final computedPagesPerDay = (604 / _targetDays).ceil();
    final computedDays = (604 / _pagesPerDay).ceil();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'تحديد خطة الختمة',
          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
        ),
        SizedBox(height: 12.h),

        // Title Field
        TextField(
          controller: _titleController,
          style: TextStyle(fontSize: 14.sp, fontFamily: 'Cairo'),
          decoration: InputDecoration(
            labelText: 'islamic.khatmah.title_label'.tr(),
            labelStyle: TextStyle(fontSize: 13.sp, fontFamily: 'Cairo'),
            filled: true,
            fillColor: chipBg,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
          ),
        ),
        SizedBox(height: 16.h),

        // Mode Toggle Tabs
        Container(
          decoration: BoxDecoration(
            color: chipBg,
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsets.all(3.r),
          child: Row(
            children: [
              _buildModeTab('بعدد الأيام', 0, primaryColor, isDark),
              _buildModeTab('بعدد الصفحات', 1, primaryColor, isDark),
            ],
          ),
        ),
        SizedBox(height: 14.h),

        if (_planMode == 0) ...[
          // ── BY DAYS MODE ──
          Text(
            'في كم يوماً تريد ختم القرآن؟',
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, fontFamily: 'Cairo'),
          ),
          SizedBox(height: 8.h),

          // Quick Preset Chips
          Row(
            children: [10, 15, 30, 60].map((days) {
              final isSelected = _targetDays == days;
              final ppd = (604 / days).ceil();
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3.w),
                  child: InkWell(
                    onTap: () => _onDaysChanged(days),
                    borderRadius: BorderRadius.circular(12.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryColor : chipBg,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: isSelected ? primaryColor : chipBorder),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '$days يوم',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : textColor,
                              fontFamily: 'Cairo',
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            '$ppd ص/يوم',
                            style: TextStyle(
                              fontSize: 9.5.sp,
                              color: isSelected ? Colors.white70 : Colors.grey,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 12.h),

          // Custom Days Stepper
          _buildCustomInputRow(
            label: 'أو حدد عدد الأيام يدوياً',
            value: _targetDays,
            suffix: 'يوم',
            onChanged: _onDaysChanged,
            isDark: isDark,
            primaryColor: primaryColor,
          ),
          SizedBox(height: 8.h),
          _buildSummaryChip('= $computedPagesPerDay صفحة يومياً', isDark, primaryColor),
        ] else ...[
          // ── BY PAGES MODE ──
          Text(
            'كم صفحة تريد أن تقرأ يومياً؟',
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, fontFamily: 'Cairo'),
          ),
          SizedBox(height: 8.h),

          // Quick Pages Presets
          Row(
            children: [5, 10, 20, 40].map((pages) {
              final isSelected = _pagesPerDay == pages;
              final daysNeeded = (604 / pages).ceil();
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3.w),
                  child: InkWell(
                    onTap: () => _onPagesChanged(pages),
                    borderRadius: BorderRadius.circular(12.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryColor : chipBg,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: isSelected ? primaryColor : chipBorder),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '$pages صفحة',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : textColor,
                              fontFamily: 'Cairo',
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            '$daysNeeded يوم',
                            style: TextStyle(
                              fontSize: 9.5.sp,
                              color: isSelected ? Colors.white70 : Colors.grey,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 12.h),

          // Custom Pages Stepper
          _buildCustomInputRow(
            label: 'أو حدد عدد الصفحات يدوياً',
            value: _pagesPerDay,
            suffix: 'صفحة/يوم',
            onChanged: _onPagesChanged,
            isDark: isDark,
            primaryColor: primaryColor,
          ),
          SizedBox(height: 8.h),
          _buildSummaryChip('= تنهي الختمة في $computedDays يوم إن شاء الله', isDark, primaryColor),
        ],

        SizedBox(height: 20.h),

        ElevatedButton(
          onPressed: () {
            context.read<KhatmahCubit>().createKhatmah(
                  title: _titleController.text,
                  targetDays: _targetDays,
                );
            setState(() {
              _isCreating = false;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            padding: EdgeInsets.symmetric(vertical: 14.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
          ),
          child: Text(
            'بدء الختمة 🚀',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Cairo'),
          ),
        ),
      ],
    );
  }

  Widget _buildModeTab(String title, int mode, Color primaryColor, bool isDark) {
    final isSelected = _planMode == mode;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _planMode = mode;
          });
        },
        borderRadius: BorderRadius.circular(10.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black54),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomInputRow({
    required String label,
    required int value,
    required String suffix,
    required void Function(int) onChanged,
    required bool isDark,
    required Color primaryColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11.sp, color: Colors.grey, fontFamily: 'Cairo')),
        SizedBox(height: 6.h),
        Row(
          children: [
            _buildStepperButton(Icons.remove_rounded, () => onChanged(value - 1), primaryColor),
            SizedBox(width: 10.w),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF141824) : const Color(0xFFF4F6FB),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$value',
                      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: primaryColor, fontFamily: 'Cairo'),
                    ),
                    SizedBox(width: 6.w),
                    Text(suffix, style: TextStyle(fontSize: 12.sp, color: Colors.grey, fontFamily: 'Cairo')),
                  ],
                ),
              ),
            ),
            SizedBox(width: 10.w),
            _buildStepperButton(Icons.add_rounded, () => onChanged(value + 1), primaryColor),
          ],
        ),
      ],
    );
  }

  Widget _buildStepperButton(IconData icon, VoidCallback onTap, Color primaryColor) {
    return Material(
      color: primaryColor.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(10.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.r),
        child: Padding(
          padding: EdgeInsets.all(10.r),
          child: Icon(icon, color: primaryColor, size: 20.sp),
        ),
      ),
    );
  }

  Widget _buildSummaryChip(String text, bool isDark, Color primaryColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline_rounded, size: 14.sp, color: primaryColor),
          SizedBox(width: 6.w),
          Text(
            text,
            style: TextStyle(fontFamily: 'Cairo', fontSize: 11.sp, fontWeight: FontWeight.w600, color: primaryColor),
          ),
        ],
      ),
    );
  }
}


