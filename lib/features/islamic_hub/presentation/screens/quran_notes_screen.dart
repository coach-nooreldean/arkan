import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/ayah_note_entity.dart';
import '../../domain/entities/ayah_entity.dart';
import '../../domain/entities/surah_entity.dart';
import '../../domain/repositories/islamic_hub_repository.dart';
import '../../data/repositories/islamic_hub_repository_impl.dart';

class QuranNotesScreen extends StatefulWidget {
  final void Function(int page)? onPageSelected;

  const QuranNotesScreen({super.key, this.onPageSelected});

  static IslamicHubRepository _getRepo(BuildContext ctx) {
    try {
      return ctx.read<IslamicHubRepository>();
    } catch (_) {
      return IslamicHubRepositoryImpl();
    }
  }

  static Future<void> showAddNoteDialog(
    BuildContext context,
    AyahEntity ayah, {
    AyahNoteEntity? existingNote,
  }) async {
    final textController = TextEditingController(text: existingNote?.noteText ?? '');
    final repo = _getRepo(context);

    await showDialog<void>(
      context: context,
      useRootNavigator: true,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E2433) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          title: Row(
            children: [
              Icon(Icons.edit_note_rounded, color: const Color(0xFF3551AE), size: 24.r),
              SizedBox(width: 8.w),
              Text(
                existingNote != null ? 'تعديل الخاطرة' : 'إضافة تدبر / خاطرة',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF141824) : const Color(0xFFF4F6FB),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${ayah.surahName} - الآية ${ayah.numberInSurah}',
                      style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: const Color(0xFF3551AE), fontFamily: 'Cairo'),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      ayah.text,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(fontSize: 13.sp, fontFamily: 'Amiri'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: textController,
                maxLines: 4,
                autofocus: true,
                style: TextStyle(fontSize: 13.sp, fontFamily: 'Cairo'),
                decoration: InputDecoration(
                  hintText: 'islamic.quran_notes.hint'.tr(),
                  hintStyle: TextStyle(fontSize: 12.sp, color: Colors.grey, fontFamily: 'Cairo'),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF141824) : const Color(0xFFF9FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('common.cancel'.tr(), style: const TextStyle(fontFamily: 'Cairo')),
            ),
            ElevatedButton(
              onPressed: () async {
                final text = textController.text.trim();
                if (text.isNotEmpty) {
                  final note = AyahNoteEntity(
                    id: existingNote?.id ?? const Uuid().v4(),
                    surahNumber: ayah.surahNumber,
                    surahName: ayah.surahName,
                    numberInSurah: ayah.numberInSurah,
                    ayahNumber: ayah.number,
                    ayahText: ayah.text,
                    page: ayah.page,
                    noteText: text,
                    createdAt: existingNote?.createdAt ?? DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                  await repo.saveAyahNote(note);
                  if (ctx.mounted) Navigator.pop(ctx);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3551AE),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              child: Text('common.save'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
            ),
          ],
        );
      },
    );
  }

  @override
  State<QuranNotesScreen> createState() => _QuranNotesScreenState();
}

class _QuranNotesScreenState extends State<QuranNotesScreen> {
  List<AyahNoteEntity> _notes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() => _isLoading = true);
    try {
      final repo = QuranNotesScreen._getRepo(context);
      final list = await repo.getAyahNotes();
      if (mounted) {
        setState(() {
          _notes = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _notes = [];
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteNote(String id) async {
    try {
      final repo = QuranNotesScreen._getRepo(context);
      await repo.deleteAyahNote(id);
      await _loadNotes();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const primaryColor = Color(0xFF3551AE);

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: EdgeInsetsDirectional.only(start: 12.w),
          child: Center(
            child: InkWell(
              onTap: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/');
                }
              },
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: Icon(Icons.arrow_forward_ios_rounded, size: 18.sp),
                ),
              ),
            ),
          ),
        ),
        title: Text('islamic.quran_notes.title'.tr(), style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            tooltip: 'islamic.quran_notes.add_new'.tr(),
            onPressed: () => _openCreateNoteDialog(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreateNoteDialog(),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'islamic.quran_notes.add_new'.tr(),
          style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : _notes.isEmpty
              ? _buildEmptyState(context, isDark, primaryColor)
              : ListView.separated(
                  padding: EdgeInsets.fromLTRB(16.r, 16.r, 16.r, 80.h),
                  itemCount: _notes.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final note = _notes[index];
                    return _buildNoteCard(context, note, isDark, primaryColor);
                  },
                ),
    );
  }

  void _openCreateNoteDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => _CreateQuranNoteDialog(
        onSaved: _loadNotes,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark, Color primaryColor) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(24.r),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedNoteEdit,
                color: primaryColor,
                size: 48.r,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'لا توجد تدبرات مسجلة بعد',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
            ),
            SizedBox(height: 8.h),
            Text(
              'يمكنك تدوين خواطرك وتدبراتك على آيات القرآن الكريم لتكون مرجعاً إيمانياً دائماً لك.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey, height: 1.6, fontFamily: 'Cairo'),
            ),
            SizedBox(height: 20.h),
            ElevatedButton.icon(
              onPressed: () => _openCreateNoteDialog(),
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text(
                'تدوين أول تدبر الآن',
                style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteCard(
    BuildContext context,
    AyahNoteEntity note,
    bool isDark,
    Color primaryColor,
  ) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2433) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark ? const Color(0xFF2E394E) : const Color(0xFFE8EEF8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '${note.surahName} • الآية ${note.numberInSurah}',
                  style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: primaryColor, fontFamily: 'Cairo'),
                ),
              ),
              const Spacer(),
              if (widget.onPageSelected != null)
                IconButton(
                  icon: const Icon(Icons.open_in_new_rounded, size: 18),
                  tooltip: 'الانتقال لصفحة المصحف',
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onPageSelected!(note.page);
                  },
                ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                tooltip: 'حذف الخاطرة',
                onPressed: () => _deleteNote(note.id),
              ),
            ],
          ),
          SizedBox(height: 8.h),

          // Ayah Text snippet
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF141824) : const Color(0xFFF8FAFD),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              '﴿ ${note.ayahText} ﴾',
              textDirection: TextDirection.rtl,
              style: TextStyle(fontSize: 13.sp, fontFamily: 'Amiri', color: isDark ? Colors.white70 : Colors.black87),
            ),
          ),
          SizedBox(height: 10.h),

          // Note text
          Text(
            note.noteText,
            style: TextStyle(
              fontSize: 13.sp,
              fontFamily: 'Cairo',
              height: 1.6,
              color: isDark ? Colors.white : const Color(0xFF1B2030),
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateQuranNoteDialog extends StatefulWidget {
  final void Function()? onSaved;

  const _CreateQuranNoteDialog({this.onSaved});

  @override
  State<_CreateQuranNoteDialog> createState() => _CreateQuranNoteDialogState();
}

class _CreateQuranNoteDialogState extends State<_CreateQuranNoteDialog> {
  List<SurahEntity> _surahs = [];
  SurahEntity? _selectedSurah;
  final TextEditingController _ayahNumberController = TextEditingController(text: '1');
  final TextEditingController _ayahSnippetController = TextEditingController();
  final TextEditingController _noteTextController = TextEditingController();
  bool _isLoadingSurahs = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSurahs();
  }

  @override
  void dispose() {
    _ayahNumberController.dispose();
    _ayahSnippetController.dispose();
    _noteTextController.dispose();
    super.dispose();
  }

  Future<void> _loadSurahs() async {
    try {
      final repo = QuranNotesScreen._getRepo(context);
      final list = await repo.getAllSurahs();
      if (mounted) {
        setState(() {
          _surahs = list;
          _selectedSurah = list.isNotEmpty ? list.first : null;
          _isLoadingSurahs = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingSurahs = false);
      }
    }
  }

  Future<void> _save() async {
    final noteText = _noteTextController.text.trim();
    if (noteText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('islamic.quran_notes.empty_prompt'.tr(), style: const TextStyle(fontFamily: 'Cairo')),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_selectedSurah == null) return;

    final ayahNumInSurah = int.tryParse(_ayahNumberController.text.trim()) ?? 1;
    final validAyahNum = ayahNumInSurah.clamp(1, _selectedSurah!.numberOfAyahs);

    final surah = _selectedSurah!;
    final approxPage = (surah.startPage +
            ((validAyahNum - 1) / (surah.numberOfAyahs > 0 ? surah.numberOfAyahs : 1) *
                    (surah.endPage - surah.startPage))
                .floor())
        .clamp(surah.startPage, surah.endPage);

    setState(() => _isSaving = true);

    try {
      final repo = QuranNotesScreen._getRepo(context);
      final snippet = _ayahSnippetController.text.trim().isNotEmpty
          ? _ayahSnippetController.text.trim()
          : 'سورة ${surah.name} — الآية $validAyahNum';

      final note = AyahNoteEntity(
        id: const Uuid().v4(),
        surahNumber: surah.number,
        surahName: 'سورة ${surah.name}',
        numberInSurah: validAyahNum,
        ayahNumber: validAyahNum,
        ayahText: snippet,
        page: approxPage,
        noteText: noteText,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repo.saveAyahNote(note);

      if (mounted) {
        Navigator.pop(context);
        widget.onSaved?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF059669),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 8.w),
                const Text(
                  'تم حفظ التدبر بنجاح 🌿',
                  style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const primaryColor = Color(0xFF3551AE);
    final bgColor = isDark ? const Color(0xFF1E2433) : Colors.white;
    final fieldBg = isDark ? const Color(0xFF141824) : const Color(0xFFF6F8FC);

    return AlertDialog(
      backgroundColor: bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.edit_note_rounded, color: primaryColor, size: 22.r),
          ),
          SizedBox(width: 10.w),
          Text(
            'تدوين تدبر جديد',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
              color: isDark ? Colors.white : const Color(0xFF1E2438),
            ),
          ),
        ],
      ),
      content: _isLoadingSurahs
          ? SizedBox(
              height: 120.h,
              child: const Center(child: CircularProgressIndicator(color: Color(0xFF3551AE))),
            )
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Surah selector & Ayah number in a Row
                  Row(
                    children: [
                      // Surah Dropdown
                      Expanded(
                        flex: 3,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          decoration: BoxDecoration(
                            color: fieldBg,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<SurahEntity>(
                              value: _selectedSurah,
                              isExpanded: true,
                              dropdownColor: bgColor,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontFamily: 'Cairo',
                                color: isDark ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                              items: _surahs.map((s) {
                                return DropdownMenuItem<SurahEntity>(
                                  value: s,
                                  child: Text('سورة ${s.name} (${s.numberOfAyahs} آية)'),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _selectedSurah = val;
                                    _ayahNumberController.text = '1';
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      // Ayah Number Field
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: _ayahNumberController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13.sp, fontFamily: 'Cairo', fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            labelText: 'islamic.quran_notes.ayah_label'.tr(),
                            labelStyle: TextStyle(fontSize: 11.sp, fontFamily: 'Cairo'),
                            filled: true,
                            fillColor: fieldBg,
                            contentPadding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),

                  // Optional Ayah Text / Phrase snippet
                  TextField(
                    controller: _ayahSnippetController,
                    style: TextStyle(fontSize: 12.sp, fontFamily: 'Amiri'),
                    decoration: InputDecoration(
                      hintText: 'islamic.quran_notes.ayah_hint'.tr(),
                      hintStyle: TextStyle(fontSize: 11.sp, color: Colors.grey, fontFamily: 'Cairo'),
                      filled: true,
                      fillColor: fieldBg,
                      contentPadding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
                    ),
                  ),
                  SizedBox(height: 10.h),

                  // Reflection text
                  TextField(
                    controller: _noteTextController,
                    maxLines: 4,
                    autofocus: true,
                    style: TextStyle(fontSize: 13.sp, fontFamily: 'Cairo', height: 1.5),
                    decoration: InputDecoration(
                      hintText: 'islamic.quran_notes.hint'.tr(),
                      hintStyle: TextStyle(fontSize: 12.sp, color: Colors.grey, fontFamily: 'Cairo'),
                      filled: true,
                      fillColor: fieldBg,
                      contentPadding: EdgeInsets.all(12.r),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide.none),
                    ),
                  ),
                ],
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('common.cancel'.tr(), style: const TextStyle(fontFamily: 'Cairo', color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          ),
          child: _isSaving
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text('islamic.quran_notes.save_note'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
        ),
      ],
    );
  }
}
