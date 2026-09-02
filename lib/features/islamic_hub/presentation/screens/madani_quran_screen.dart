import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/ayah_entity.dart';
import '../cubits/quran_cubit.dart';
import '../cubits/khatmah_cubit.dart';
import '../../../rewards/presentation/cubits/arkan_coins_cubit.dart';
import '../../../rewards/domain/entities/arkan_coin_transaction.dart';
import '../widgets/madani_page_renderer.dart';
import '../widgets/quran_audio_player_bar.dart';
import '../widgets/quran_search_modal.dart';
import '../widgets/quran_khatmah_sheet.dart';
import '../widgets/ayah_share_card_dialog.dart';
import 'quran_notes_screen.dart';
import 'khatm_dua_screen.dart';

class MadaniQuranScreen extends StatefulWidget {
  const MadaniQuranScreen({super.key});

  static void showTafsirModal(
    BuildContext context, {
    required int ayahNumber,
    int? numberInSurah,
    String? ayahText,
    String? surahName,
  }) {
    final cubit = context.read<QuranCubit>();
    cubit.showAyahTafsir(ayahNumber);

    final isDark = cubit.state.readingMode == QuranReadingMode.dark;
    final isSepia = cubit.state.readingMode == QuranReadingMode.sepia;

    final sheetBg = isDark
        ? const Color(0xFF1B2030)
        : (isSepia ? const Color(0xFFF3E5CA) : Colors.white);
    final titleColor = isDark
        ? Colors.white
        : (isSepia ? const Color(0xFF4E342E) : const Color(0xFF1E2438));
    final bodyColor = isDark
        ? const Color(0xFFE2E8F0)
        : (isSepia ? const Color(0xFF5D4037) : const Color(0xFF2D3748));
    final ayahCardBg = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : (isSepia ? const Color(0xFFEADBC8) : const Color(0xFFF8FAFC));
    final borderColor = isDark
        ? Colors.white12
        : (isSepia ? const Color(0xFFD7CCC8) : const Color(0xFFE2E8F0));

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: sheetBg,
      constraints: const BoxConstraints(maxWidth: 640),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
      builder: (modalCtx) => BlocProvider.value(
        value: cubit,
        child: BlocBuilder<QuranCubit, QuranState>(
          builder: (ctx, state) {
            final isLoading = state.selectedAyahTafsir == null ||
                state.selectedAyahTafsir == 'جاري تحميل التفسير الميسر...';
            final displayText = state.selectedAyahTafsir ?? '';
            final displayNum = numberInSurah ?? state.selectedAyahNumber ?? ayahNumber;

            return SafeArea(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
                constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(ctx).height * 0.82),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(IconsaxPlusLinear.book_1, color: const Color(0xFF3551AE), size: 22.sp),
                            SizedBox(width: 8.w),
                            Text(
                              'التفسير الميسر',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: titleColor,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3551AE).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            surahName != null && surahName.isNotEmpty
                                ? '$surahName — آية $displayNum'
                                : 'آية $displayNum',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF3551AE),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16.h),

                    // Ayah Text in Calligraphy
                    if (ayahText != null && ayahText.isNotEmpty) ...[
                      Container(
                        padding: EdgeInsets.all(14.w),
                        decoration: BoxDecoration(
                          color: ayahCardBg,
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: borderColor),
                        ),
                        child: Text(
                          ayahText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontFamily: 'AmiriQuran',
                            fontWeight: FontWeight.bold,
                            color: titleColor,
                            height: 1.6,
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                    ],

                    // Tafsir Content
                    if (isLoading)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.h),
                        child: const Center(
                          child: CircularProgressIndicator(color: Color(0xFF3551AE)),
                        ),
                      )
                    else ...[
                      SelectableText(
                        displayText,
                        style: TextStyle(
                          fontSize: 14.5.sp,
                          height: 1.7,
                          color: bodyColor,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {
                              final targetAyah = AyahEntity(
                                number: ayahNumber,
                                surahNumber: cubit.state.currentSurah?.number ?? 1,
                                numberInSurah: displayNum,
                                page: cubit.state.currentPage,
                                juz: cubit.state.currentJuz?.number ?? 1,
                                hizbQuarter: 1,
                                text: ayahText ?? '',
                                surahName: surahName ?? cubit.state.currentSurah?.name ?? '',
                              );
                              AyahShareCardDialog.show(ctx, targetAyah);
                            },
                            icon: const Icon(Icons.share_outlined, size: 18),
                            label: const Text('مشاركة كبطاقة', style: TextStyle(fontFamily: 'Cairo')),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              final targetAyah = AyahEntity(
                                number: ayahNumber,
                                surahNumber: cubit.state.currentSurah?.number ?? 1,
                                numberInSurah: displayNum,
                                page: cubit.state.currentPage,
                                juz: cubit.state.currentJuz?.number ?? 1,
                                hizbQuarter: 1,
                                text: ayahText ?? '',
                                surahName: surahName ?? cubit.state.currentSurah?.name ?? '',
                              );
                              QuranNotesScreen.showAddNoteDialog(ctx, targetAyah);
                            },
                            icon: const Icon(Icons.edit_note_rounded, size: 18),
                            label: const Text('تدوين تدبر', style: TextStyle(fontFamily: 'Cairo')),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3551AE),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    ).whenComplete(() {
      cubit.clearTafsir();
    });
  }

  @override
  State<MadaniQuranScreen> createState() => _MadaniQuranScreenState();
}

class _MadaniQuranScreenState extends State<MadaniQuranScreen> {
  late PageController _pageController;
  late PageController _spreadController;
  bool _showControls = true;
  bool _enableDualPage = true;

  @override
  void initState() {
    super.initState();
    final initialPage = context.read<QuranCubit>().state.currentPage;
    _pageController = PageController(initialPage: (initialPage - 1).clamp(0, 603));
    _spreadController = PageController(initialPage: ((initialPage - 1) ~/ 2).clamp(0, 301));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndPromptWird();
    });
  }

  void _checkAndPromptWird() {
    if (!mounted) return;
    final khatmahCubit = context.read<KhatmahCubit>();
    if (khatmahCubit.state.khatmahs.isEmpty && !khatmahCubit.state.isLoading) {
      QuranKhatmahSheet.show(
        context,
        onPageSelected: (page) => context.read<QuranCubit>().setPage(page),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _spreadController.dispose();
    super.dispose();
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  void _goToNextPage(bool isDual) {
    final cubit = context.read<QuranCubit>();
    final current = cubit.state.currentPage;
    if (isDual) {
      final currentSpread = (current - 1) ~/ 2;
      if (currentSpread < 301) {
        final nextSpread = currentSpread + 1;
        final nextPage = (nextSpread * 2) + 1;
        cubit.setPage(nextPage);
      }
    } else {
      if (current < 604) {
        cubit.setPage(current + 1);
      }
    }
  }

  void _goToPreviousPage(bool isDual) {
    final cubit = context.read<QuranCubit>();
    final current = cubit.state.currentPage;
    if (isDual) {
      final currentSpread = (current - 1) ~/ 2;
      if (currentSpread > 0) {
        final prevSpread = currentSpread - 1;
        final prevPage = (prevSpread * 2) + 1;
        cubit.setPage(prevPage);
      }
    } else {
      if (current > 1) {
        cubit.setPage(current - 1);
      }
    }
  }

  void _showPageAyahsModal(BuildContext context) {
    final cubit = context.read<QuranCubit>();
    final state = cubit.state;
    final isDark = state.readingMode == QuranReadingMode.dark;
    final isSepia = state.readingMode == QuranReadingMode.sepia;

    final bgColor = isDark ? const Color(0xFF1B2030) : (isSepia ? const Color(0xFFFAF2E4) : Colors.white);
    const primaryColor = Color(0xFF3551AE);
    final textColor = isDark ? Colors.white : (isSepia ? const Color(0xFF4E342E) : const Color(0xFF1E2438));
    final subtextColor = isDark ? Colors.white70 : (isSepia ? const Color(0xFF795548) : Colors.black54);
    final cardBg = isDark ? const Color(0xFF141824) : (isSepia ? const Color(0xFFF0E4D0) : const Color(0xFFF8FAFD));

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: bgColor,
      constraints: const BoxConstraints(maxWidth: 640),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
      builder: (ctx) {
        return SafeArea(
          child: Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(ctx).height * 0.85),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 44.w,
                    height: 5.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(Icons.edit_note_rounded, color: primaryColor, size: 20.r),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'آيات وتدبرات الصفحة ${state.currentPage}',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Cairo',
                              color: textColor,
                            ),
                          ),
                          Text(
                            'اضغط على أي آية لتدوين خاطرة أو قراءة التفسير والمشاركة',
                            style: TextStyle(fontSize: 11.sp, color: subtextColor, fontFamily: 'Cairo'),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Expanded(
                  child: state.currentPageAyahs.isEmpty
                      ? Center(
                          child: state.isLoadingAyahs
                              ? const CircularProgressIndicator(color: primaryColor)
                              : Text('جاري تحميل آيات الصفحة...', style: TextStyle(color: subtextColor, fontFamily: 'Cairo')),
                        )
                      : ListView.separated(
                          itemCount: state.currentPageAyahs.length,
                          separatorBuilder: (_, __) => SizedBox(height: 10.h),
                          itemBuilder: (context, index) {
                            final ayah = state.currentPageAyahs[index];
                            return Container(
                              padding: EdgeInsets.all(14.r),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(
                                  color: isDark ? Colors.white12 : (isSepia ? const Color(0xFFD7CCC8) : const Color(0xFFE8EEF8)),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                        decoration: BoxDecoration(
                                          color: primaryColor.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(8.r),
                                        ),
                                        child: Text(
                                          'الآية ${ayah.numberInSurah}',
                                          style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: primaryColor, fontFamily: 'Cairo'),
                                        ),
                                      ),
                                      const Spacer(),
                                      // Note Button
                                      IconButton(
                                        icon: const Icon(Icons.edit_note_rounded, color: Color(0xFF3551AE)),
                                        tooltip: 'تدوين تدبر',
                                        onPressed: () => QuranNotesScreen.showAddNoteDialog(context, ayah),
                                      ),
                                      // Tafsir Button
                                      IconButton(
                                        icon: const Icon(Icons.menu_book_outlined, color: Color(0xFFD97706)),
                                        tooltip: 'التفسير الميسر',
                                        onPressed: () {
                                          Navigator.pop(ctx);
                                          MadaniQuranScreen.showTafsirModal(
                                            context,
                                            ayahNumber: ayah.number,
                                            numberInSurah: ayah.numberInSurah,
                                            ayahText: ayah.text,
                                            surahName: ayah.surahName.isNotEmpty ? ayah.surahName : state.currentSurah?.name,
                                          );
                                        },
                                      ),
                                      // Share Button
                                      IconButton(
                                        icon: const Icon(Icons.share_outlined, color: Color(0xFF059669)),
                                        tooltip: 'مشاركة كبطاقة',
                                        onPressed: () => AyahShareCardDialog.show(context, ayah),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 6.h),
                                  Text(
                                    ayah.text,
                                    textDirection: TextDirection.rtl,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontFamily: 'Amiri',
                                      height: 1.6,
                                      color: textColor,
                                    ),
                                  ),
                                ],
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
    );
  }

  void _showReadingModeSheet(BuildContext context, bool isWideScreen) {
    final cubit = context.read<QuranCubit>();
    final isDark = cubit.state.readingMode == QuranReadingMode.dark ||
        Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1B2030) : Colors.white,
      constraints: const BoxConstraints(maxWidth: 560),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'نمط القراءة',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildModeOption(
                          context,
                          label: 'الورقي الأصلي',
                          mode: QuranReadingMode.classic,
                          color: const Color(0xFFFFFDF5),
                          textColor: Colors.black87,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: _buildModeOption(
                          context,
                          label: 'مريح للعين',
                          mode: QuranReadingMode.sepia,
                          color: const Color(0xFFFBF0D9),
                          textColor: const Color(0xFF5D4037),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: _buildModeOption(
                          context,
                          label: 'الوضع الليلي',
                          mode: QuranReadingMode.dark,
                          color: const Color(0xFF121212),
                          textColor: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  // Wide Screen Layout Mode Toggle
                  if (isWideScreen) ...[
                    SizedBox(height: 20.h),
                    Text(
                      'طريقة العرض للشاشات الكبيرة',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _enableDualPage = true;
                              });
                              setSheetState(() {});
                            },
                            borderRadius: BorderRadius.circular(12.r),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 10.w),
                              decoration: BoxDecoration(
                                color: _enableDualPage
                                    ? const Color(0xFF3551AE).withValues(alpha: 0.15)
                                    : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04)),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: _enableDualPage ? const Color(0xFF3551AE) : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.menu_book_rounded,
                                    color: _enableDualPage ? const Color(0xFF3551AE) : (isDark ? Colors.white70 : Colors.black87),
                                    size: 18.sp,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'صفحتين متجاورتين',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: _enableDualPage ? FontWeight.bold : FontWeight.normal,
                                      color: _enableDualPage ? const Color(0xFF3551AE) : (isDark ? Colors.white : Colors.black87),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _enableDualPage = false;
                              });
                              setSheetState(() {});
                            },
                            borderRadius: BorderRadius.circular(12.r),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 10.w),
                              decoration: BoxDecoration(
                                color: !_enableDualPage
                                    ? const Color(0xFF3551AE).withValues(alpha: 0.15)
                                    : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04)),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: !_enableDualPage ? const Color(0xFF3551AE) : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.auto_stories_rounded,
                                    color: !_enableDualPage ? const Color(0xFF3551AE) : (isDark ? Colors.white70 : Colors.black87),
                                    size: 18.sp,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'صفحة واحدة',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: !_enableDualPage ? FontWeight.bold : FontWeight.normal,
                                      color: !_enableDualPage ? const Color(0xFF3551AE) : (isDark ? Colors.white : Colors.black87),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildModeOption(
    BuildContext context, {
    required String label,
    required QuranReadingMode mode,
    required Color color,
    required Color textColor,
  }) {
    final cubit = context.read<QuranCubit>();
    final isSelected = cubit.state.readingMode == mode;

    return InkWell(
      onTap: () {
        cubit.setReadingMode(mode);
        Navigator.of(context).pop();
      },
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 6.w),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? const Color(0xFF3551AE) : Colors.black12,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              isSelected ? IconsaxPlusBold.tick_circle : IconsaxPlusLinear.sun_1,
              color: isSelected ? const Color(0xFF3551AE) : textColor,
              size: 20.sp,
            ),
            SizedBox(height: 6.h),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
                fontSize: 11.5.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageRenderer(BuildContext context, int pageNum, QuranState state) {
    final currentSurah = state.currentSurah?.name ?? '';
    final currentJuz = state.currentJuz?.name ?? '';
    final isAudioActive = state.audioStatus == QuranAudioStatus.playing ||
        state.audioStatus == QuranAudioStatus.loading ||
        state.audioStatus == QuranAudioStatus.paused;
    final currentPlaying = state.currentPlayingAyah;
    List<int> highlightLines = const [];
    List<AyahLineSegment> highlightSegments = const [];
    bool isPagePlaying = false;

    if (isAudioActive && currentPlaying != null) {
      if (pageNum == state.currentPage) {
        final onPageAyah = state.currentPageAyahs.where((a) =>
          (a.surahNumber == currentPlaying.surahNumber && a.numberInSurah == currentPlaying.numberInSurah) ||
          a.number == currentPlaying.number ||
          a.number == state.playingAyahNumber
        ).firstOrNull;

        if (onPageAyah != null) {
          isPagePlaying = true;
          highlightLines = onPageAyah.lines.isNotEmpty ? onPageAyah.lines : currentPlaying.lines;
          highlightSegments = onPageAyah.lineSegments.isNotEmpty ? onPageAyah.lineSegments : currentPlaying.lineSegments;
        }
      } else if (currentPlaying.page == pageNum) {
        isPagePlaying = true;
        highlightLines = currentPlaying.lines;
        highlightSegments = currentPlaying.lineSegments;
      }
    }

    return MadaniPageRenderer(
      pageNumber: pageNum,
      surahName: currentSurah,
      juzName: currentJuz,
      readingMode: state.readingMode,
      primaryImageUrl: context.read<QuranCubit>().getPageImageUrl(pageNum),
      alternativeUrls: context.read<QuranCubit>().getPageImageAlternativeUrls(pageNum),
      highlightLines: highlightLines,
      highlightSegments: highlightSegments,
      isCurrentlyPlaying: isPagePlaying,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isWideScreen = screenWidth >= 720;
    final isDual = isWideScreen && _enableDualPage;

    return BlocListener<KhatmahCubit, KhatmahState>(
      listener: (context, kState) {
        if (kState.successMessage != null && kState.successMessage!.isNotEmpty) {
          context.read<ArkanCoinsCubit>().awardCoins(
            amount: 10,
            title: 'إنجاز ورد القرآن الكريم 📖',
            subtitle: kState.successMessage!,
            source: ArkanCoinSource.quranWird,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFF3551AE),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              content: Row(
                children: [
                  const Icon(Icons.stars_rounded, color: Color(0xFFFFD54F), size: 24),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      kState.successMessage!,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                        fontSize: 13.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
      child: BlocConsumer<QuranCubit, QuranState>(
        listener: (context, state) {
          if (_pageController.hasClients &&
              _pageController.page?.round() != (state.currentPage - 1)) {
            _pageController.jumpToPage((state.currentPage - 1).clamp(0, 603));
          }
          final targetSpread = ((state.currentPage - 1) ~/ 2).clamp(0, 301);
          if (_spreadController.hasClients &&
              _spreadController.page?.round() != targetSpread) {
            _spreadController.jumpToPage(targetSpread);
          }

          if (state.downloadCompletedMessage != null && state.downloadCompletedMessage!.isNotEmpty) {
            final msg = state.downloadCompletedMessage!;
            context.read<QuranCubit>().clearDownloadCompletedMessage();
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: const Color(0xFF059669),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                content: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        msg,
                        style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          final isDark = state.readingMode == QuranReadingMode.dark;
          final isSepia = state.readingMode == QuranReadingMode.sepia;

          final currentSurah = state.currentSurah?.name ?? '';
          final currentJuz = state.currentJuz?.name ?? '';
          final isBookmarked = state.isCurrentPageBookmarked;

          final bgColor = isDark
              ? const Color(0xFF121212)
              : (isSepia ? const Color(0xFFFBF0D9) : const Color(0xFFFFFDF5));

          final appBarBgColor = isDark
              ? const Color(0xFF1B2030)
              : (isSepia ? const Color(0xFFF3E5CA) : Colors.white);

          final textColor = isDark
              ? Colors.white
              : (isSepia ? const Color(0xFF4E342E) : const Color(0xFF1E2438));

          final subtextColor = isDark
              ? Colors.white70
              : (isSepia ? const Color(0xFF795548) : Colors.black54);

          final iconColor = isDark
              ? Colors.white
              : (isSepia ? const Color(0xFF4E342E) : const Color(0xFF1E2438));

          return Focus(
            autofocus: true,
            onKeyEvent: (node, event) {
              if (event is KeyDownEvent) {
                if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                  _goToNextPage(isDual);
                  return KeyEventResult.handled;
                } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
                  _goToPreviousPage(isDual);
                  return KeyEventResult.handled;
                } else if (event.logicalKey == LogicalKeyboardKey.space) {
                  _toggleControls();
                  return KeyEventResult.handled;
                } else if (event.logicalKey == LogicalKeyboardKey.escape) {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/');
                  }
                  return KeyEventResult.handled;
                }
              }
              return KeyEventResult.ignored;
            },
            child: PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) {
                if (didPop) return;
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/');
                }
              },
              child: Scaffold(
              backgroundColor: bgColor,
              body: Stack(
                children: [
                  // Full Screen PageView (Single Page or Dual Page Spread)
                  GestureDetector(
                    onTap: _toggleControls,
                    child: isDual
                        ? PageView.builder(
                            controller: _spreadController,
                            reverse: true, // Madani Quran reads Right-to-Left
                            itemCount: 302,
                            onPageChanged: (spreadIdx) {
                              final rightPage = (spreadIdx * 2) + 1;
                              context.read<QuranCubit>().setPage(rightPage);
                              try {
                                context.read<KhatmahCubit>().updateCurrentPage(rightPage);
                              } catch (_) {}
                            },
                            itemBuilder: (context, spreadIdx) {
                              final rightPageNum = (spreadIdx * 2) + 1;
                              final leftPageNum = (spreadIdx * 2) + 2;

                              return Directionality(
                                textDirection: TextDirection.rtl,
                                child: Row(
                                  children: [
                                    // Right Page (Odd page: 1, 3, 5, ...)
                                    Expanded(
                                      child: _buildPageRenderer(context, rightPageNum, state),
                                    ),
                                    // Mushaf Spine Center Divider
                                    Container(
                                      width: 1.5,
                                      height: double.infinity,
                                      color: isDark
                                          ? Colors.white12
                                          : (isSepia ? const Color(0xFFD7CCC8) : const Color(0xFFE2E8F0)),
                                    ),
                                    // Left Page (Even page: 2, 4, 6, ...)
                                    Expanded(
                                      child: leftPageNum <= 604
                                          ? _buildPageRenderer(context, leftPageNum, state)
                                          : Container(color: bgColor),
                                    ),
                                  ],
                                ),
                              );
                            },
                          )
                        : PageView.builder(
                            controller: _pageController,
                            reverse: true, // Madani Quran reads Right-to-Left
                            itemCount: 604,
                            onPageChanged: (idx) {
                              final page = idx + 1;
                              context.read<QuranCubit>().setPage(page);
                              try {
                                context.read<KhatmahCubit>().updateCurrentPage(page);
                              } catch (_) {}
                            },
                            itemBuilder: (context, index) {
                              final pageNum = index + 1;
                              return _buildPageRenderer(context, pageNum, state);
                            },
                          ),
                  ),

                  // Side Navigation Buttons for Tablets & Large Screens
                  if (isWideScreen && _showControls) ...[
                    // Right Floating Nav (Previous Page in RTL)
                    Positioned(
                      right: 16.w,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _goToPreviousPage(isDual),
                            borderRadius: BorderRadius.circular(30.r),
                            child: Container(
                              padding: EdgeInsets.all(12.r),
                              decoration: BoxDecoration(
                                color: (isDark ? Colors.black45 : Colors.white70).withValues(alpha: 0.8),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                                border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                              ),
                              child: Icon(Icons.arrow_forward_ios_rounded, color: iconColor, size: 20.sp),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Left Floating Nav (Next Page in RTL)
                    Positioned(
                      left: 16.w,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _goToNextPage(isDual),
                            borderRadius: BorderRadius.circular(30.r),
                            child: Container(
                              padding: EdgeInsets.all(12.r),
                              decoration: BoxDecoration(
                                color: (isDark ? Colors.black45 : Colors.white70).withValues(alpha: 0.8),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                                border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                              ),
                              child: Icon(Icons.arrow_back_ios_new_rounded, color: iconColor, size: 20.sp),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],

                  // Floating "Jump to Playing Ayah Page" pill
                  if (state.currentPlayingAyah != null &&
                      state.currentPlayingAyah!.page != state.currentPage &&
                      (state.audioStatus == QuranAudioStatus.playing || state.audioStatus == QuranAudioStatus.loading))
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 60.h,
                      left: 20.w,
                      right: 20.w,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 500),
                          child: InkWell(
                            onTap: () {
                              context.read<QuranCubit>().setPage(state.currentPlayingAyah!.page);
                            },
                            borderRadius: BorderRadius.circular(20.r),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3551AE),
                                borderRadius: BorderRadius.circular(20.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.25),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(IconsaxPlusBold.volume_high, color: Colors.white, size: 16.sp),
                                  SizedBox(width: 6.w),
                                  Text(
                                    'الانتقال لصفحة التلاوة (صفحة ${state.currentPlayingAyah!.page})',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 12),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Real-time Offline Download Progress Overlay
                  if (state.isDownloadingSurah)
                    Positioned(
                      top: MediaQuery.of(context).padding.top + (_showControls ? 64.h : 16.h),
                      left: 16.w,
                      right: 16.w,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 600),
                          child: Material(
                            color: Colors.transparent,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E2433) : Colors.white,
                                borderRadius: BorderRadius.circular(16.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.18),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                border: Border.all(
                                  color: const Color(0xFF3551AE).withValues(alpha: 0.4),
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(6.r),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF3551AE).withValues(alpha: 0.12),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Color(0xFF3551AE),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 10.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'جاري تحميل سورة ${state.downloadingSurahName ?? state.currentSurah?.name ?? ""} أوفلاين',
                                              style: TextStyle(
                                                fontFamily: 'Cairo',
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12.sp,
                                                color: textColor,
                                              ),
                                            ),
                                            if (state.downloadingAyahInfo != null)
                                              Text(
                                                state.downloadingAyahInfo!,
                                                style: TextStyle(
                                                  fontFamily: 'Cairo',
                                                  fontSize: 10.sp,
                                                  color: subtextColor,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '${((state.downloadProgress ?? 0.0) * 100).toInt()}%',
                                        style: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.sp,
                                          color: const Color(0xFF3551AE),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8.h),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6.r),
                                    child: LinearProgressIndicator(
                                      value: state.downloadProgress,
                                      backgroundColor: isDark ? Colors.white12 : const Color(0xFFE8EEF8),
                                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3551AE)),
                                      minHeight: 6.h,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Animated Top Overlay App Bar
                  if (_showControls)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top + 4.h,
                          bottom: 8.h,
                          left: 12.w,
                          right: 12.w,
                        ),
                        decoration: BoxDecoration(
                          color: appBarBgColor,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                          border: Border(
                            bottom: BorderSide(
                              color: isDark
                                  ? Colors.white12
                                  : (isSepia ? const Color(0xFFD7CCC8) : Colors.black12),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 850),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.arrow_forward_ios_rounded, size: 18.sp, color: iconColor),
                                      tooltip: 'رجوع',
                                      onPressed: () {
                                        if (context.canPop()) {
                                          context.pop();
                                        } else {
                                          context.go('/');
                                        }
                                      },
                                    ),
                                    Expanded(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'سورة $currentSurah',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.bold,
                                              color: textColor,
                                            ),
                                          ),
                                          Text(
                                            isDual
                                                ? '$currentJuz — صفحة ${state.currentPage} & ${state.currentPage + 1 <= 604 ? state.currentPage + 1 : ""}'
                                                : '$currentJuz — صفحة ${state.currentPage}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 10.sp,
                                              color: subtextColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Dual Page Mode Toggle on Tablets / Large Screens
                                        if (isWideScreen)
                                          IconButton(
                                            icon: Icon(
                                              _enableDualPage ? Icons.menu_book_rounded : Icons.auto_stories_rounded,
                                              color: _enableDualPage ? const Color(0xFF3551AE) : iconColor,
                                              size: 19.sp,
                                            ),
                                            tooltip: _enableDualPage ? 'عرض صفحة واحدة' : 'عرض صفحتين متجاورتين',
                                            onPressed: () {
                                              setState(() {
                                                _enableDualPage = !_enableDualPage;
                                                if (_enableDualPage) {
                                                  final spread = (state.currentPage - 1) ~/ 2;
                                                  _spreadController = PageController(initialPage: spread.clamp(0, 301));
                                                } else {
                                                  _pageController = PageController(initialPage: (state.currentPage - 1).clamp(0, 603));
                                                }
                                              });
                                            },
                                          ),

                                        // Dedicated Khatmah / Wird button with badge
                                        IconButton(
                                          icon: Icon(
                                            Icons.flag_rounded,
                                            color: const Color(0xFF3551AE),
                                            size: 20.sp,
                                          ),
                                          tooltip: 'الورد والختمة',
                                          onPressed: () {
                                            QuranKhatmahSheet.show(
                                              context,
                                              onPageSelected: (page) => context.read<QuranCubit>().setPage(page),
                                            );
                                          },
                                        ),
                                        // Search Button
                                        IconButton(
                                          icon: Icon(IconsaxPlusLinear.search_normal, color: iconColor, size: 18.sp),
                                          tooltip: 'البحث في القرآن',
                                          onPressed: () {
                                            QuranSearchModal.show(
                                              context,
                                              onAyahSelected: (ayah) {
                                                final cubit = context.read<QuranCubit>();
                                                cubit.setPage(ayah.page);
                                                cubit.playAyah(ayah);
                                              },
                                            );
                                          },
                                        ),
                                        // Bookmark button
                                        IconButton(
                                          icon: Icon(
                                            isBookmarked ? IconsaxPlusBold.bookmark : IconsaxPlusLinear.bookmark,
                                            color: isBookmarked ? const Color(0xFFE67E22) : iconColor,
                                            size: 18.sp,
                                          ),
                                          onPressed: () => context.read<QuranCubit>().toggleBookmarkCurrentPage(),
                                        ),
                                        // Reading mode
                                        IconButton(
                                          icon: Icon(IconsaxPlusLinear.sun_1, color: iconColor, size: 18.sp),
                                          onPressed: () => _showReadingModeSheet(context, isWideScreen),
                                        ),
                                        // More Options (Ayahs, Khatmah, Dua, Notes, Offline Download)
                                        PopupMenuButton<String>(
                                          icon: Icon(Icons.more_vert_rounded, color: iconColor),
                                          color: isDark ? const Color(0xFF1E2433) : (isSepia ? const Color(0xFFFAF2E4) : Colors.white),
                                          surfaceTintColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16.r),
                                            side: BorderSide(
                                              color: isDark ? Colors.white12 : (isSepia ? const Color(0xFFD7CCC8) : const Color(0xFFE2E8F0)),
                                            ),
                                          ),
                                          onSelected: (val) {
                                            if (val == 'page_ayahs') {
                                              _showPageAyahsModal(context);
                                            } else if (val == 'khatmah') {
                                              QuranKhatmahSheet.show(
                                                context,
                                                onPageSelected: (page) => context.read<QuranCubit>().setPage(page),
                                              );
                                            } else if (val == 'dua') {
                                              Navigator.push<void>(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => KhatmDuaScreen(
                                                    onPageSelected: (p) => context.read<QuranCubit>().setPage(p),
                                                  ),
                                                ),
                                              );
                                            } else if (val == 'notes') {
                                              Navigator.push<void>(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => QuranNotesScreen(
                                                    onPageSelected: (p) => context.read<QuranCubit>().setPage(p),
                                                  ),
                                                ),
                                              );
                                            } else if (val == 'download') {
                                              final surahNum = state.currentSurah?.number ?? 1;
                                              context.read<QuranCubit>().downloadSurahAudio(surahNum);
                                            }
                                          },
                                          itemBuilder: (ctx) {
                                            final itemTextColor = isDark
                                                ? Colors.white
                                                : (isSepia ? const Color(0xFF4E342E) : const Color(0xFF1E2438));
                                            return [
                                              PopupMenuItem(
                                                value: 'page_ayahs',
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.auto_stories_rounded, size: 18, color: Color(0xFF3551AE)),
                                                    const SizedBox(width: 10),
                                                    Text(
                                                      'آيات الصفحة وتدبرها',
                                                      style: TextStyle(
                                                        fontFamily: 'Cairo',
                                                        fontSize: 13.sp,
                                                        fontWeight: FontWeight.w600,
                                                        color: itemTextColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              PopupMenuItem(
                                                value: 'khatmah',
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.bookmark_added_outlined, size: 18, color: Color(0xFF3551AE)),
                                                    const SizedBox(width: 10),
                                                    Text(
                                                      'الختمات والورد اليومي',
                                                      style: TextStyle(
                                                        fontFamily: 'Cairo',
                                                        fontSize: 13.sp,
                                                        fontWeight: FontWeight.w600,
                                                        color: itemTextColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              PopupMenuItem(
                                                value: 'notes',
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.edit_note_rounded, size: 18, color: Color(0xFF3551AE)),
                                                    const SizedBox(width: 10),
                                                    Text(
                                                      'تدبراتي وملاحظاتي',
                                                      style: TextStyle(
                                                        fontFamily: 'Cairo',
                                                        fontSize: 13.sp,
                                                        fontWeight: FontWeight.w600,
                                                        color: itemTextColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              PopupMenuItem(
                                                value: 'dua',
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.menu_book_outlined, size: 18, color: Color(0xFF3551AE)),
                                                    const SizedBox(width: 10),
                                                    Text(
                                                      'دعاء الختم وسجدات التلاوة',
                                                      style: TextStyle(
                                                        fontFamily: 'Cairo',
                                                        fontSize: 13.sp,
                                                        fontWeight: FontWeight.w600,
                                                        color: itemTextColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              PopupMenuItem(
                                                value: 'download',
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.download_rounded, size: 18, color: Color(0xFF3551AE)),
                                                    const SizedBox(width: 10),
                                                    Text(
                                                      'تحميل سورة ${state.currentSurah?.name ?? ""} أوفلاين',
                                                      style: TextStyle(
                                                        fontFamily: 'Cairo',
                                                        fontSize: 13.sp,
                                                        fontWeight: FontWeight.w600,
                                                        color: itemTextColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ];
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                // Interactive Daily Wird Progress Strip
                                _buildDailyWirdStrip(context, state, isDark, isSepia),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Floating Bottom Audio Player Bar
                  if (_showControls)
                    Positioned(
                      bottom: 12,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 680),
                          child: const QuranAudioPlayerBar(),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

  Widget _buildDailyWirdStrip(
    BuildContext context,
    QuranState qState,
    bool isDark,
    bool isSepia,
  ) {
    final textColor = isDark
        ? Colors.white
        : (isSepia ? const Color(0xFF4E342E) : const Color(0xFF1E2438));
    final cardBg = isDark
        ? const Color(0xFF161B26)
        : (isSepia ? const Color(0xFFF4ECDC) : const Color(0xFFF4F7FC));

    return BlocBuilder<KhatmahCubit, KhatmahState>(
      builder: (context, kState) {
        final active = kState.activeKhatmah;
        if (active != null) {
          final isDoneToday = active.remainingPagesToday == 0;
          final isDual = _enableDualPage &&
              (MediaQuery.of(context).size.width >= 720 ||
                  MediaQuery.of(context).orientation == Orientation.landscape);
          final isOnWirdPage = isDual
              ? (active.currentPage >= qState.currentPage &&
                  active.currentPage <= qState.currentPage + 1)
              : (qState.currentPage == active.currentPage);

          return Container(
            margin: EdgeInsets.only(top: 6.h, left: 4.w, right: 4.w),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
            decoration: BoxDecoration(
              color: isDoneToday
                  ? const Color(0xFF059669).withValues(alpha: 0.12)
                  : cardBg,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isDoneToday
                    ? const Color(0xFF059669).withValues(alpha: 0.35)
                    : const Color(0xFF3551AE).withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(5.r),
                  decoration: BoxDecoration(
                    color: isDoneToday
                        ? const Color(0xFF059669).withValues(alpha: 0.15)
                        : const Color(0xFF3551AE).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    isDoneToday ? Icons.check_circle_rounded : Icons.menu_book_rounded,
                    color: isDoneToday ? const Color(0xFF059669) : const Color(0xFF3551AE),
                    size: 16.sp,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            active.title,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          Text(
                            isDoneToday
                                ? 'أتممت ورد اليوم 🎉'
                                : 'متبقي ${active.remainingPagesToday} صفحة اليوم',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 10.5.sp,
                              fontWeight: FontWeight.bold,
                              color: isDoneToday
                                  ? const Color(0xFF059669)
                                  : const Color(0xFF3551AE),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 3.h),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3.r),
                        child: LinearProgressIndicator(
                          value: active.pagesPerDay > 0
                              ? (active.pagesReadToday / active.pagesPerDay).clamp(0.0, 1.0)
                              : 0.0,
                          backgroundColor: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDoneToday ? const Color(0xFF059669) : const Color(0xFF3551AE),
                          ),
                          minHeight: 3.5.h,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                if (!isOnWirdPage)
                  InkWell(
                    onTap: () {
                      context.read<QuranCubit>().setPage(active.currentPage);
                    },
                    borderRadius: BorderRadius.circular(8.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3551AE),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'صفحة ${active.currentPage}',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 10.5.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 9),
                        ],
                      ),
                    ),
                  )
                else
                  InkWell(
                    onTap: () {
                      QuranKhatmahSheet.show(
                        context,
                        onPageSelected: (page) => context.read<QuranCubit>().setPage(page),
                      );
                    },
                    borderRadius: BorderRadius.circular(8.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3551AE).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(Icons.tune_rounded, size: 16.sp, color: const Color(0xFF3551AE)),
                    ),
                  ),
              ],
            ),
          );
        }

        // When no active khatmah
        return Container(
          margin: EdgeInsets.only(top: 6.h, left: 4.w, right: 4.w),
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF3551AE).withValues(alpha: 0.12),
                const Color(0xFF059669).withValues(alpha: 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFF3551AE).withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Icon(Icons.flag_rounded, color: const Color(0xFF3551AE), size: 16.sp),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  'لم تحدد وردك اليومي بعد — حدد هدفك (مثلاً: جزء يومياً)',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
              SizedBox(width: 6.w),
              ElevatedButton(
                onPressed: () {
                  QuranKhatmahSheet.show(
                    context,
                    onPageSelected: (page) => context.read<QuranCubit>().setPage(page),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3551AE),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                  visualDensity: VisualDensity.compact,
                ),
                child: Text(
                  'تحديد الورد 🎯',
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 10.5.sp, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
