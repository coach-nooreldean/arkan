import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/services/backup_service.dart';
import '../../../rewards/presentation/cubits/arkan_coins_cubit.dart';
import '../cubits/islamic_settings_cubit.dart';
import '../cubits/khatmah_cubit.dart';
import '../cubits/prayer_times_cubit.dart';
import '../cubits/quran_cubit.dart';
import '../cubits/tasbih_cubit.dart';
import '../cubits/worship_tracker_cubit.dart';

class BackupRestoreSheet extends StatefulWidget {
  const BackupRestoreSheet({super.key});

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
      builder: (_) => const BackupRestoreSheet(),
    );
  }

  @override
  State<BackupRestoreSheet> createState() => _BackupRestoreSheetState();
}

class _BackupRestoreSheetState extends State<BackupRestoreSheet> {
  final TextEditingController _importController = TextEditingController();
  bool _isBusy = false;
  String? _statusMessage;
  bool _isError = false;

  @override
  void dispose() {
    _importController.dispose();
    super.dispose();
  }

  Future<void> _exportAndShare() async {
    setState(() {
      _isBusy = true;
      _statusMessage = null;
      _isError = false;
    });
    try {
      final file = await BackupService.writeBackupToTempFile();
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'نسخة احتياطية - تطبيق أركان',
      );
      if (mounted) {
        setState(() {
          _statusMessage = 'تم تجهيز ومشاركة ملف النسخة الاحتياطية بنجاح.';
          _isError = false;
        });
      }
    } catch (_) {
      try {
        final json = await BackupService.exportBackupJson();
        await Clipboard.setData(ClipboardData(text: json));
        if (mounted) {
          setState(() {
            _statusMessage = 'تم نسخ بيانات النسخة الاحتياطية للحافظة بنجاح.';
            _isError = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _statusMessage = 'تعذر تصدير النسخة الاحتياطية: $e';
            _isError = true;
          });
        }
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _copyBackupJson() async {
    setState(() {
      _isBusy = true;
      _statusMessage = null;
      _isError = false;
    });
    try {
      final json = await BackupService.exportBackupJson();
      await Clipboard.setData(ClipboardData(text: json));
      if (mounted) {
        setState(() {
          _statusMessage = 'تم نسخ نص النسخة الاحتياطية إلى الحافظة.';
          _isError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = 'حدث خطأ أثناء النسخ: $e';
          _isError = true;
        });
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text ?? '';
    if (text.trim().isEmpty) {
      if (mounted) {
        setState(() {
          _statusMessage = 'الحافظة فارغة، انسخ نص النسخة الاحتياطية أولاً.';
          _isError = true;
        });
      }
      return;
    }
    _importController.text = text;
  }

  Future<void> _restoreFromInput() async {
    final raw = _importController.text.trim();
    if (raw.isEmpty) {
      setState(() {
        _statusMessage = 'يرجى لصق نص النسخة الاحتياطية JSON أولاً.';
        _isError = true;
      });
      return;
    }

    setState(() {
      _isBusy = true;
      _statusMessage = null;
      _isError = false;
    });

    try {
      final restoredCount = await BackupService.importBackupJson(raw);
      if (!mounted) return;

      // Refresh active Cubits from restored SharedPreferences
      try {
        await context.read<IslamicSettingsCubit>().loadSettings();
      } catch (_) {}
      if (!mounted) return;
      try {
        await context.read<PrayerTimesCubit>().loadPrayerTimes();
      } catch (_) {}
      if (!mounted) return;
      try {
        await context.read<WorshipTrackerCubit>().loadLogForDate(DateTime.now());
      } catch (_) {}
      if (!mounted) return;
      try {
        await context.read<KhatmahCubit>().loadKhatmahs();
      } catch (_) {}
      if (!mounted) return;
      try {
        await context.read<TasbihCubit>().loadTasbih();
      } catch (_) {}
      if (!mounted) return;
      try {
        await context.read<ArkanCoinsCubit>().loadCoinsData();
      } catch (_) {}
      if (!mounted) return;
      try {
        await context.read<QuranCubit>().refreshOfflineStatus();
      } catch (_) {}

      if (mounted) {
        setState(() {
          _statusMessage =
              'تمت استعادة البيانات بنجاح ($restoredCount عنصر محفوظ).';
          _isError = false;
        });
      }
    } on FormatException catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = 'صيغة النسخة الاحتياطية غير صالحة: ${e.message}';
          _isError = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = 'تعذر استعادة البيانات: $e';
          _isError = true;
        });
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3551AE).withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      IconsaxPlusBold.cloud_add,
                      color: const Color(0xFF3551AE),
                      size: 22.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'النسخ الاحتياطي والاستعادة',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'احفظ عباداتك، ختماتك، ملاحظاتك، وإعداداتك في ملف JSON',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 18.h),

              if (_statusMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: (_isError
                            ? const Color(0xFFE74C3C)
                            : const Color(0xFF10B981))
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: (_isError
                              ? const Color(0xFFE74C3C)
                              : const Color(0xFF10B981))
                          .withValues(alpha: 0.35),
                    ),
                  ),
                  child: Text(
                    _statusMessage!,
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w600,
                      color: _isError
                          ? const Color(0xFFE74C3C)
                          : const Color(0xFF10B981),
                    ),
                  ),
                ),
                SizedBox(height: 14.h),
              ],

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isBusy ? null : _exportAndShare,
                      icon: const Icon(IconsaxPlusBold.export_1, size: 18),
                      label: const Text('تصدير ومشاركة JSON'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3551AE),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isBusy ? null : _copyBackupJson,
                      icon: const Icon(IconsaxPlusLinear.copy, size: 18),
                      label: const Text('نسخ للحافظة'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20.h),
              const Divider(),
              SizedBox(height: 12.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'استعادة من نسخة احتياطية',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _isBusy ? null : _pasteFromClipboard,
                    icon: const Icon(IconsaxPlusLinear.clipboard_import, size: 16),
                    label: const Text('لصق من الحافظة'),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: _importController,
                maxLines: 4,
                minLines: 3,
                style: TextStyle(fontSize: 12.sp, fontFamily: 'monospace'),
                decoration: InputDecoration(
                  hintText: 'الصق محتوى ملف النسخة الاحتياطية JSON هنا...',
                  filled: true,
                  fillColor:
                      isDark ? const Color(0xFF161B2B) : const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isBusy ? null : _restoreFromInput,
                  icon: _isBusy
                      ? SizedBox(
                          width: 16.w,
                          height: 16.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(IconsaxPlusBold.import_1, size: 18),
                  label: const Text('استعادة البيانات الآن'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
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
      ),
    );
  }
}
