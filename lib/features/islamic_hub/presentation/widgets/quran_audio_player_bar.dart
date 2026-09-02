import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../cubits/quran_cubit.dart';
import '../screens/madani_quran_screen.dart';
import '../../domain/entities/ayah_entity.dart';
import '../../domain/entities/surah_entity.dart';
import 'ayah_share_card_dialog.dart';
import '../screens/quran_notes_screen.dart';

class QuranAudioPlayerBar extends StatelessWidget {
  const QuranAudioPlayerBar({super.key});

  static void _showReciterPicker(BuildContext context, String currentReciter) {
    final cubit = context.read<QuranCubit>();
    final isDark = cubit.state.readingMode == QuranReadingMode.dark ||
        Theme.of(context).brightness == Brightness.dark;
    final isSepia = cubit.state.readingMode == QuranReadingMode.sepia;

    final sheetBg = isDark
        ? const Color(0xFF1B2030)
        : (isSepia ? const Color(0xFFF3E5CA) : Colors.white);
    final titleColor = isDark
        ? Colors.white
        : (isSepia ? const Color(0xFF4E342E) : Colors.black87);

    final reciters = [
      {'id': 'alafasy', 'name': 'islamic.alafasy'.tr()},
      {'id': 'alhusary', 'name': 'islamic.alhusary'.tr()},
      {'id': 'abdulbasit', 'name': 'islamic.abdulbasit'.tr()},
      {'id': 'minshawi', 'name': 'islamic.minshawi'.tr()},
    ];

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: sheetBg,
      constraints: const BoxConstraints(maxWidth: 550),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'islamic.reciter'.tr(),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
              SizedBox(height: 12.h),
              ...reciters.map((r) {
                final isSelected = r['id'] == currentReciter;
                return ListTile(
                  title: Text(
                    r['name']!,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? const Color(0xFF3551AE)
                          : (isDark ? Colors.white70 : (isSepia ? const Color(0xFF5D4037) : Colors.black87)),
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(IconsaxPlusBold.tick_circle, color: Color(0xFF3551AE))
                      : null,
                  onTap: () {
                    cubit.setReciter(r['id']!);
                    Navigator.of(ctx).pop();
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // 1. DIRECT AYAH SELECTOR (قائمة اختيار وتشغيل أي آية مباشرة)
  static void showAyahPickerSheet(BuildContext context) {
    final cubit = context.read<QuranCubit>();
    final state = cubit.state;
    final isDark = state.readingMode == QuranReadingMode.dark ||
        Theme.of(context).brightness == Brightness.dark;
    final isSepia = state.readingMode == QuranReadingMode.sepia;

    final sheetBg = isDark
        ? const Color(0xFF1B2030)
        : (isSepia ? const Color(0xFFF3E5CA) : Colors.white);
    final titleColor = isDark
        ? Colors.white
        : (isSepia ? const Color(0xFF4E342E) : Colors.black87);
    final subtextColor = isDark
        ? Colors.white60
        : (isSepia ? const Color(0xFF795548) : Colors.black54);

    final currentSurah = state.currentSurah;
    int selectedTab = 0; // 0: Page Ayahs, 1: Surah Ayahs
    List<AyahEntity> surahAyahs = [];
    bool isLoadingSurah = false;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: sheetBg,
      constraints: const BoxConstraints(maxWidth: 640),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final pageAyahs = cubit.state.currentPageAyahs;

          void loadSurahAyahs() async {
            if (currentSurah == null || surahAyahs.isNotEmpty || isLoadingSurah) return;
            setModalState(() => isLoadingSurah = true);
            final fetched = await cubit.getAyahsForSurah(currentSurah.number);
            setModalState(() {
              surahAyahs = fetched;
              isLoadingSurah = false;
            });
          }

          if (selectedTab == 1 && surahAyahs.isEmpty && !isLoadingSurah) {
            loadSurahAyahs();
          }

          final listToDisplay = selectedTab == 0 ? pageAyahs : surahAyahs;

          return SafeArea(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.78,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(IconsaxPlusLinear.document_text, color: const Color(0xFF3551AE), size: 22.sp),
                          SizedBox(width: 8.w),
                          Text(
                            'اختيار آية للقراءة والاستماع',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: titleColor,
                            ),
                          ),
                        ],
                      ),
                      if (currentSurah != null)
                        Text(
                          currentSurah.name,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF3551AE),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 12.h),

                  // Tabs
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : Colors.black12,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.all(3.w),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => setModalState(() => selectedTab = 0),
                            borderRadius: BorderRadius.circular(10.r),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: selectedTab == 0 ? const Color(0xFF3551AE) : Colors.transparent,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Text(
                                'آيات الصفحة (${pageAyahs.length})',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: selectedTab == 0 ? FontWeight.bold : FontWeight.normal,
                                  color: selectedTab == 0 ? Colors.white : titleColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setModalState(() => selectedTab = 1);
                              loadSurahAyahs();
                            },
                            borderRadius: BorderRadius.circular(10.r),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: selectedTab == 1 ? const Color(0xFF3551AE) : Colors.transparent,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Text(
                                'كل آيات السورة (${currentSurah?.numberOfAyahs ?? 0})',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: selectedTab == 1 ? FontWeight.bold : FontWeight.normal,
                                  color: selectedTab == 1 ? Colors.white : titleColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 12.h),

                  Expanded(
                    child: (selectedTab == 1 && isLoadingSurah)
                        ? const Center(
                            child: CircularProgressIndicator(color: Color(0xFF3551AE)),
                          )
                        : listToDisplay.isEmpty
                            ? Center(
                                child: Text('islamic.audio_player.no_ayahs'.tr(), style: TextStyle(color: subtextColor)),
                              )
                            : ListView.separated(
                                itemCount: listToDisplay.length,
                                separatorBuilder: (_, __) => SizedBox(height: 6.h),
                                itemBuilder: (ctx, index) {
                                  final ayah = listToDisplay[index];
                                  final isPlaying = cubit.state.playingAyahNumber == ayah.number;

                                  return DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: isPlaying
                                          ? const Color(0xFF3551AE).withValues(alpha: 0.15)
                                          : (isDark
                                              ? Colors.white.withValues(alpha: 0.04)
                                              : Colors.black.withValues(alpha: 0.03)),
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(
                                        color: isPlaying ? const Color(0xFF3551AE) : Colors.transparent,
                                      ),
                                    ),
                                    child: ListTile(
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                                      leading: Container(
                                        width: 32.w,
                                        height: 32.w,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: isPlaying
                                              ? const Color(0xFF3551AE)
                                              : (isDark ? Colors.white12 : Colors.black12),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          '${ayah.numberInSurah}',
                                          style: TextStyle(
                                            fontSize: 11.sp,
                                            fontWeight: FontWeight.bold,
                                            color: isPlaying ? Colors.white : titleColor,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        ayah.text,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          fontFamily: 'AmiriQuran',
                                          fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
                                          color: isPlaying ? const Color(0xFF3551AE) : titleColor,
                                          height: 1.5,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'صفحة ${ayah.page}',
                                        style: TextStyle(fontSize: 10.sp, color: subtextColor),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              Icons.share_outlined,
                                              color: isDark ? Colors.white70 : Colors.black54,
                                              size: 18.sp,
                                            ),
                                            tooltip: 'islamic.audio_player.share_card'.tr(),
                                            onPressed: () {
                                              AyahShareCardDialog.show(context, ayah);
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.edit_note_rounded,
                                              color: isDark ? Colors.white70 : Colors.black54,
                                              size: 20.sp,
                                            ),
                                            tooltip: 'islamic.audio_player.take_note'.tr(),
                                            onPressed: () {
                                              QuranNotesScreen.showAddNoteDialog(context, ayah);
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              IconsaxPlusLinear.book_1,
                                              color: isDark ? Colors.white70 : Colors.black54,
                                              size: 18.sp,
                                            ),
                                            tooltip: 'islamic.audio_player.tafsir_btn'.tr(),
                                            onPressed: () {
                                              Navigator.of(ctx).pop();
                                              MadaniQuranScreen.showTafsirModal(
                                                context,
                                                ayahNumber: ayah.number,
                                                numberInSurah: ayah.numberInSurah,
                                                ayahText: ayah.text,
                                                surahName: ayah.surahName.isNotEmpty ? ayah.surahName : currentSurah?.name,
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              isPlaying ? IconsaxPlusBold.pause_circle : IconsaxPlusBold.play_circle,
                                              color: const Color(0xFF3551AE),
                                              size: 24.sp,
                                            ),
                                            tooltip: 'تشغيل',
                                            onPressed: () {
                                              if (cubit.state.currentPage != ayah.page) {
                                                cubit.setPage(ayah.page);
                                              }
                                              cubit.playAyah(ayah);
                                              Navigator.of(ctx).pop();
                                            },
                                          ),
                                        ],
                                      ),
                                      onTap: () {
                                        if (cubit.state.currentPage != ayah.page) {
                                          cubit.setPage(ayah.page);
                                        }
                                        cubit.playAyah(ayah);
                                        Navigator.of(ctx).pop();
                                      },
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 2. SURAH-WIDE REPEAT & RANGE MEMORIZATION SHEET (تكرار المقطع على مستوى السورة)
  static void showRepeatAndRangeSheet(BuildContext context) {
    final cubit = context.read<QuranCubit>();
    final state = cubit.state;
    final isDark = state.readingMode == QuranReadingMode.dark ||
        Theme.of(context).brightness == Brightness.dark;
    final isSepia = state.readingMode == QuranReadingMode.sepia;

    final sheetBg = isDark
        ? const Color(0xFF1B2030)
        : (isSepia ? const Color(0xFFF3E5CA) : Colors.white);
    final titleColor = isDark
        ? Colors.white
        : (isSepia ? const Color(0xFF4E342E) : Colors.black87);
    final subtextColor = isDark
        ? Colors.white60
        : (isSepia ? const Color(0xFF795548) : Colors.black54);

    final repeatOptions = [1, 2, 3, 5, 7, 10];
    SurahEntity selectedSurah = state.currentSurah ??
        (state.surahs.isNotEmpty ? state.surahs.first : const SurahEntity(number: 1, name: 'الفاتحة', englishName: 'Al-Faatiha', englishNameTranslation: 'The Opening', numberOfAyahs: 7, revelationType: 'Meccan', startPage: 1, endPage: 1, juz: 1));

    int startAyah = 1;
    int endAyah = selectedSurah.numberOfAyahs;
    int ayahRepeat = state.ayahRepeatCount;
    int rangeRepeat = state.rangeRepeatCount;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: sheetBg,
      constraints: const BoxConstraints(maxWidth: 640),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final totalAyahs = selectedSurah.numberOfAyahs;

          return SafeArea(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 14.h),

                  // Header
                  Row(
                    children: [
                      Icon(IconsaxPlusLinear.repeat, color: const Color(0xFF3551AE), size: 22.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'تكرار المقطع والتحفيظ (على مستوى السورة)',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: titleColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // 1. Select Surah
                  Text(
                    'السورة المستهدفة:',
                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: titleColor),
                  ),
                  SizedBox(height: 6.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<SurahEntity>(
                        value: state.surahs.where((s) => s.number == selectedSurah.number).firstOrNull ?? selectedSurah,
                        isExpanded: true,
                        dropdownColor: sheetBg,
                        items: state.surahs.map((s) {
                          return DropdownMenuItem<SurahEntity>(
                            value: s,
                            child: Text(
                              '${s.number}. ${s.name} (${s.numberOfAyahs} آية)',
                              style: TextStyle(fontSize: 13.sp, color: titleColor),
                            ),
                          );
                        }).toList(),
                        onChanged: (newSurah) {
                          if (newSurah != null) {
                            setModalState(() {
                              selectedSurah = newSurah;
                              startAyah = 1;
                              endAyah = newSurah.numberOfAyahs;
                            });
                          }
                        },
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // 2. Select Ayah Range (من آية ... إلى آية ...)
                  Text(
                    'نطاق التكرار في ${selectedSurah.name}:',
                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: titleColor),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      // Start Ayah
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('islamic.audio_player.from_ayah'.tr(), style: TextStyle(fontSize: 11.sp, color: subtextColor)),
                              DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  value: startAyah.clamp(1, totalAyahs),
                                  isExpanded: true,
                                  dropdownColor: sheetBg,
                                  items: List.generate(totalAyahs, (i) => i + 1).map((ayahNum) {
                                    return DropdownMenuItem<int>(
                                      value: ayahNum,
                                      child: Text('آية $ayahNum', style: TextStyle(fontSize: 13.sp, color: titleColor)),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setModalState(() {
                                        startAyah = val;
                                        if (endAyah < startAyah) endAyah = startAyah;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      // End Ayah
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('islamic.audio_player.to_ayah'.tr(), style: TextStyle(fontSize: 11.sp, color: subtextColor)),
                              DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  value: endAyah.clamp(startAyah, totalAyahs),
                                  isExpanded: true,
                                  dropdownColor: sheetBg,
                                  items: List.generate(totalAyahs - startAyah + 1, (i) => startAyah + i).map((ayahNum) {
                                    return DropdownMenuItem<int>(
                                      value: ayahNum,
                                      child: Text('آية $ayahNum', style: TextStyle(fontSize: 13.sp, color: titleColor)),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setModalState(() => endAyah = val);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 6.h),
                  Text(
                    'المقطع المحدد يشمل (${endAyah - startAyah + 1}) آية من ${selectedSurah.name}',
                    style: TextStyle(fontSize: 11.sp, color: const Color(0xFF3551AE), fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 16.h),

                  // 3. Single Ayah Repeat Count
                  Text(
                    'تكرار كل آية منفردة',
                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: titleColor),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'عدد مرات تكرار الآية قبل الانتقال للتي تليها',
                    style: TextStyle(fontSize: 11.sp, color: subtextColor),
                  ),
                  SizedBox(height: 6.h),
                  Wrap(
                    spacing: 8.w,
                    children: repeatOptions.map((count) {
                      final isSelected = ayahRepeat == count;
                      return ChoiceChip(
                        label: Text('$count×'),
                        selected: isSelected,
                        selectedColor: const Color(0xFF3551AE),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : titleColor,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12.sp,
                        ),
                        backgroundColor: isDark ? Colors.white10 : Colors.black12,
                        onSelected: (val) => setModalState(() => ayahRepeat = count),
                      );
                    }).toList(),
                  ),

                  SizedBox(height: 16.h),

                  // 4. Section / Range Repeat Count
                  Text(
                    'تكرار المقطع بالكامل',
                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: titleColor),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'عدد مرات إعادة المقطع كاملاً بعد الانتهاء من جميع آياته',
                    style: TextStyle(fontSize: 11.sp, color: subtextColor),
                  ),
                  SizedBox(height: 6.h),
                  Wrap(
                    spacing: 8.w,
                    children: repeatOptions.map((count) {
                      final isSelected = rangeRepeat == count;
                      return ChoiceChip(
                        label: Text('$count×'),
                        selected: isSelected,
                        selectedColor: const Color(0xFF3551AE),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : titleColor,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12.sp,
                        ),
                        backgroundColor: isDark ? Colors.white10 : Colors.black12,
                        onSelected: (val) => setModalState(() => rangeRepeat = count),
                      );
                    }).toList(),
                  ),

                  SizedBox(height: 22.h),

                  // 5. Start Range Button & Cancel Repeat Button
                  Row(
                    children: [
                      if (state.ayahRepeatCount > 1 || state.rangeRepeatCount > 1 || state.activeRangePlaylist.isNotEmpty) ...[
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 48.h,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.redAccent,
                                side: const BorderSide(color: Colors.redAccent),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                              ),
                              icon: const Icon(Icons.close_rounded, size: 18),
                              label: Text(
                                'إلغاء التكرار',
                                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
                              ),
                              onPressed: () {
                                cubit.cancelRepeat();
                                Navigator.of(ctx).pop();
                              },
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                      ],
                      Expanded(
                        flex: 3,
                        child: SizedBox(
                          height: 48.h,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3551AE),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                            ),
                            icon: const Icon(IconsaxPlusBold.play, color: Colors.white),
                            label: Text(
                              (ayahRepeat == 1 && rangeRepeat == 1)
                                  ? 'تشغيل المقطع'
                                  : 'بدء التكرار (${endAyah - startAyah + 1} آية)',
                              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            onPressed: () {
                              if (ayahRepeat == 1 && rangeRepeat == 1) {
                                cubit.setAyahRepeatCount(1);
                                cubit.setRangeRepeatCount(1);
                              }
                              cubit.playRange(
                                surahNumber: selectedSurah.number,
                                startAyahInSurah: startAyah,
                                endAyahInSurah: endAyah,
                                ayahRepeat: ayahRepeat,
                                rangeRepeat: rangeRepeat,
                              );
                              Navigator.of(ctx).pop();
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuranCubit, QuranState>(
      builder: (context, state) {
        final isDark = state.readingMode == QuranReadingMode.dark ||
            Theme.of(context).brightness == Brightness.dark;
        final isSepia = state.readingMode == QuranReadingMode.sepia;

        final ayahs = state.currentPageAyahs;
        final isPlaying = state.audioStatus == QuranAudioStatus.playing;
        final isLoading = state.audioStatus == QuranAudioStatus.loading;

        if (ayahs.isEmpty && !isPlaying && state.activeRangePlaylist.isEmpty) {
          return const SizedBox.shrink();
        }

        final barBgColor = isDark
            ? const Color(0xFF1B2030)
            : (isSepia ? const Color(0xFFF5E8CE) : Colors.white);
        final barBorderColor = isDark
            ? Colors.white12
            : (isSepia ? const Color(0xFFD7CCC8) : Colors.black12);
        final textColor = isDark ? Colors.white : (isSepia ? const Color(0xFF4E342E) : Colors.black87);
        final subtextColor = isDark ? Colors.white60 : (isSepia ? const Color(0xFF795548) : Colors.black54);

        final currentAyah = state.currentPlayingAyah;
        final surahName = currentAyah?.surahName.isNotEmpty ?? false
            ? currentAyah!.surahName
            : (state.currentSurah?.name ?? '');

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
            color: barBgColor,
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(
              color: barBorderColor,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.14),
                blurRadius: 18,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tier 1: Current Ayah details, Surah info, and Repeat indicators
              Row(
                children: [
                  // Reciter Chip Button
                  InkWell(
                    onTap: () => _showReciterPicker(context, state.selectedReciter),
                    borderRadius: BorderRadius.circular(10.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3551AE).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(IconsaxPlusLinear.voice_cricle, color: const Color(0xFF3551AE), size: 14.sp),
                          SizedBox(width: 4.w),
                          Text(
                            'islamic.${state.selectedReciter}'.tr(),
                            style: TextStyle(
                              color: const Color(0xFF3551AE),
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(width: 8.w),

                  // Ayah & Surah title
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            currentAyah != null
                                ? 'سورة $surahName • آية ${currentAyah.numberInSurah}'
                                : (isPlaying || isLoading ? 'جاري تشغيل التلاوة...' : 'استماع لآيات الصفحة (${ayahs.length} آية)'),
                            style: TextStyle(
                              fontSize: 12.5.sp,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Active Repeat Indicators with 1-Tap Cancel
                        if (state.ayahRepeatCount > 1 || state.rangeRepeatCount > 1 || state.activeRangePlaylist.isNotEmpty) ...[
                          SizedBox(width: 6.w),
                          InkWell(
                            onTap: () => context.read<QuranCubit>().cancelRepeat(),
                            borderRadius: BorderRadius.circular(6.r),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE67E22).withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(6.r),
                                border: Border.all(color: const Color(0xFFE67E22).withValues(alpha: 0.4)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    state.ayahRepeatCount > 1
                                        ? '🔁 ${state.currentAyahRepeatProgress}/${state.ayahRepeatCount}'
                                        : '🔁 مقطع: ${state.currentRangeRepeatProgress}/${state.rangeRepeatCount}',
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFFE67E22),
                                    ),
                                  ),
                                  SizedBox(width: 3.w),
                                  const Icon(Icons.close_rounded, size: 12, color: Color(0xFFE67E22)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 8.h),

              // Tier 2: Action Buttons & Playback Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Quick Actions (Left side in RTL)
                  Row(
                    children: [
                      // 1. Direct Ayah Selector Button
                      InkWell(
                        onTap: () => showAyahPickerSheet(context),
                        borderRadius: BorderRadius.circular(10.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(IconsaxPlusLinear.document_text, size: 16.sp, color: textColor),
                              SizedBox(width: 4.w),
                              Text(
                                'اختيار آية',
                                style: TextStyle(fontSize: 11.5.sp, color: textColor, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(width: 8.w),

                      // 2. Surah-wide Repeat & Range Button
                      InkWell(
                        onTap: () => showRepeatAndRangeSheet(context),
                        borderRadius: BorderRadius.circular(10.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: (state.ayahRepeatCount > 1 || state.rangeRepeatCount > 1 || state.activeRangePlaylist.isNotEmpty)
                                ? const Color(0xFF3551AE).withValues(alpha: 0.12)
                                : (isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04)),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: (state.ayahRepeatCount > 1 || state.rangeRepeatCount > 1 || state.activeRangePlaylist.isNotEmpty)
                                  ? const Color(0xFF3551AE)
                                  : (isDark ? Colors.white10 : Colors.black12),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                IconsaxPlusLinear.repeat,
                                size: 16.sp,
                                color: (state.ayahRepeatCount > 1 || state.rangeRepeatCount > 1 || state.activeRangePlaylist.isNotEmpty)
                                    ? const Color(0xFF3551AE)
                                    : textColor,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                'تكرار المقطع',
                                style: TextStyle(
                                  fontSize: 11.5.sp,
                                  color: (state.ayahRepeatCount > 1 || state.rangeRepeatCount > 1 || state.activeRangePlaylist.isNotEmpty)
                                      ? const Color(0xFF3551AE)
                                      : textColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Playback Controls (Right side in RTL)
                  Row(
                    children: [
                      // Stop Button
                      if (isPlaying || state.audioStatus == QuranAudioStatus.paused)
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(minWidth: 32.w, minHeight: 32.w),
                          icon: Icon(IconsaxPlusLinear.stop, color: subtextColor, size: 20.sp),
                          tooltip: 'إيقاف',
                          onPressed: () => context.read<QuranCubit>().stopAudio(),
                        ),

                      SizedBox(width: 4.w),

                      // Main Play/Pause Button
                      if (isLoading)
                        SizedBox(
                          width: 38.w,
                          height: 38.w,
                          child: const Center(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.2, color: Color(0xFF3551AE)),
                            ),
                          ),
                        )
                      else if (isPlaying)
                        InkWell(
                          onTap: () => context.read<QuranCubit>().pauseAudio(),
                          borderRadius: BorderRadius.circular(20.r),
                          child: Container(
                            width: 38.w,
                            height: 38.w,
                            decoration: const BoxDecoration(
                              color: Color(0xFF3551AE),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(IconsaxPlusBold.pause, color: Colors.white, size: 18),
                          ),
                        )
                      else if (state.audioStatus == QuranAudioStatus.paused)
                        InkWell(
                          onTap: () => context.read<QuranCubit>().resumeAudio(),
                          borderRadius: BorderRadius.circular(20.r),
                          child: Container(
                            width: 38.w,
                            height: 38.w,
                            decoration: const BoxDecoration(
                              color: Color(0xFF3551AE),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(IconsaxPlusBold.play, color: Colors.white, size: 18),
                          ),
                        )
                      else
                        InkWell(
                          onTap: () {
                            if (ayahs.isNotEmpty) {
                              final targetAyah = state.currentPlayingAyah ?? ayahs.first;
                              context.read<QuranCubit>().playAyah(targetAyah);
                            }
                          },
                          borderRadius: BorderRadius.circular(20.r),
                          child: Container(
                            width: 38.w,
                            height: 38.w,
                            decoration: const BoxDecoration(
                              color: Color(0xFF3551AE),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(IconsaxPlusBold.play, color: Colors.white, size: 18),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
      },
    );
  }
}
