import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../cubits/islamic_settings_cubit.dart';

class SmartRemindersSheet extends StatelessWidget {
  const SmartRemindersSheet({super.key});

  static Future<void> show(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1B2030) : Colors.white,
      constraints: const BoxConstraints(maxWidth: 580),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (_) => const SmartRemindersSheet(),
    );
  }

  String _formatTime(int hour, int minute) {
    final period = hour >= 12 ? 'م' : 'ص';
    final h12 = hour % 12 == 0 ? 12 : hour % 12;
    return '${h12.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  Future<void> _pickTime(
    BuildContext context, {
    required int initialHour,
    required int initialMinute,
    required ValueChanged<TimeOfDay> onPicked,
  }) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialHour, minute: initialMinute),
    );
    if (picked != null) {
      onPicked(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      child: BlocBuilder<IslamicSettingsCubit, IslamicSettingsState>(
        builder: (context, state) {
          final s = state.settings;
          final cubit = context.read<IslamicSettingsCubit>();

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3551AE).withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          IconsaxPlusBold.notification_bing,
                          color: const Color(0xFF3551AE),
                          size: 20.sp,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'التذكيرات الإيمانية الذكية',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF1E293B),
                              ),
                            ),
                            Text(
                              'تذكير يومي للأذكار والورد وسورة الكهف يوم الجمعة',
                              style: TextStyle(
                                fontSize: 11.5.sp,
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  _buildReminderTile(
                    context,
                    isDark: isDark,
                    icon: IconsaxPlusBold.sun_1,
                    color: const Color(0xFFF59E0B),
                    title: 'أذكار الصباح',
                    timeLabel: _formatTime(s.morningAzkarHour, s.morningAzkarMinute),
                    enabled: s.morningAzkarReminderEnabled,
                    onToggle: (v) =>
                        cubit.updateSmartReminders(morningAzkarReminderEnabled: v),
                    onTapTime: () => _pickTime(
                      context,
                      initialHour: s.morningAzkarHour,
                      initialMinute: s.morningAzkarMinute,
                      onPicked: (t) => cubit.updateSmartReminders(
                        morningAzkarHour: t.hour,
                        morningAzkarMinute: t.minute,
                      ),
                    ),
                  ),
                  _buildReminderTile(
                    context,
                    isDark: isDark,
                    icon: IconsaxPlusBold.moon,
                    color: const Color(0xFF6366F1),
                    title: 'أذكار المساء',
                    timeLabel: _formatTime(s.eveningAzkarHour, s.eveningAzkarMinute),
                    enabled: s.eveningAzkarReminderEnabled,
                    onToggle: (v) =>
                        cubit.updateSmartReminders(eveningAzkarReminderEnabled: v),
                    onTapTime: () => _pickTime(
                      context,
                      initialHour: s.eveningAzkarHour,
                      initialMinute: s.eveningAzkarMinute,
                      onPicked: (t) => cubit.updateSmartReminders(
                        eveningAzkarHour: t.hour,
                        eveningAzkarMinute: t.minute,
                      ),
                    ),
                  ),
                  _buildReminderTile(
                    context,
                    isDark: isDark,
                    icon: IconsaxPlusBold.lamp_charge,
                    color: const Color(0xFF8B5CF6),
                    title: 'أذكار النوم وسورة الملك',
                    timeLabel: _formatTime(s.sleepAzkarHour, s.sleepAzkarMinute),
                    enabled: s.sleepAzkarReminderEnabled,
                    onToggle: (v) =>
                        cubit.updateSmartReminders(sleepAzkarReminderEnabled: v),
                    onTapTime: () => _pickTime(
                      context,
                      initialHour: s.sleepAzkarHour,
                      initialMinute: s.sleepAzkarMinute,
                      onPicked: (t) => cubit.updateSmartReminders(
                        sleepAzkarHour: t.hour,
                        sleepAzkarMinute: t.minute,
                      ),
                    ),
                  ),
                  _buildReminderTile(
                    context,
                    isDark: isDark,
                    icon: IconsaxPlusBold.book_1,
                    color: const Color(0xFF10B981),
                    title: 'الورد القرآني اليومي',
                    timeLabel: _formatTime(s.quranWirdHour, s.quranWirdMinute),
                    enabled: s.quranWirdReminderEnabled,
                    onToggle: (v) =>
                        cubit.updateSmartReminders(quranWirdReminderEnabled: v),
                    onTapTime: () => _pickTime(
                      context,
                      initialHour: s.quranWirdHour,
                      initialMinute: s.quranWirdMinute,
                      onPicked: (t) => cubit.updateSmartReminders(
                        quranWirdHour: t.hour,
                        quranWirdMinute: t.minute,
                      ),
                    ),
                  ),
                  _buildReminderTile(
                    context,
                    isDark: isDark,
                    icon: IconsaxPlusBold.star_1,
                    color: const Color(0xFF0EA5E9),
                    title: 'سورة الكهف يوم الجمعة',
                    timeLabel: 'كل جمعة • 10:30 ص',
                    enabled: s.fridayKahfReminderEnabled,
                    onToggle: (v) =>
                        cubit.updateSmartReminders(fridayKahfReminderEnabled: v),
                    onTapTime: null,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReminderTile(
    BuildContext context, {
    required bool isDark,
    required IconData icon,
    required Color color,
    required String title,
    required String timeLabel,
    required bool enabled,
    required ValueChanged<bool> onToggle,
    required VoidCallback? onTapTime,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141826) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: color, size: 18.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
                InkWell(
                  onTap: enabled ? onTapTime : null,
                  child: Padding(
                    padding: EdgeInsets.only(top: 2.h),
                    child: Text(
                      onTapTime != null && enabled ? '$timeLabel (تعديل)' : timeLabel,
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        color: enabled
                            ? const Color(0xFF3551AE)
                            : (isDark ? Colors.white38 : Colors.black38),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: enabled,
            onChanged: onToggle,
          ),
        ],
      ),
    );
  }
}
