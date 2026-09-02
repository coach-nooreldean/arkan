import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../../../shared/widgets/premium_background.dart';
import '../../domain/entities/name_of_allah_entity.dart';
import '../cubits/names_of_allah_cubit.dart';

class NamesOfAllahScreen extends StatefulWidget {
  const NamesOfAllahScreen({super.key});

  @override
  State<NamesOfAllahScreen> createState() => _NamesOfAllahScreenState();
}

class _NamesOfAllahScreenState extends State<NamesOfAllahScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showFavoritesOnly = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showNameDetailsModal(BuildContext context, NameOfAllahEntity name) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF181E2E) : Colors.white,
      constraints: const BoxConstraints(maxWidth: 600),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      builder: (ctx) {
        return BlocBuilder<NamesOfAllahCubit, NamesOfAllahState>(
          builder: (cubitCtx, state) {
            final isFav = state.favoriteIds.contains(name.id);
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: ListView(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  children: [
                    Center(
                      child: Container(
                        width: 44.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Top Ornate Card with Calligraphy Name
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF16A085),
                            Color(0xFF0E6251),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24.r),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF16A085).withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
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
                                  'الاسم رقم ${name.id}',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                  color: isFav ? const Color(0xFFFF5252) : Colors.white,
                                ),
                                onPressed: () {
                                  context.read<NamesOfAllahCubit>().toggleFavorite(name.id);
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            name.name,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 34.sp,
                              fontFamily: 'AmiriQuran',
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFFFF7D6),
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          if (name.transliteration.isNotEmpty) ...[
                            SizedBox(height: 4.h),
                            Text(
                              name.transliteration,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.white70,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // Meaning Section
                    _buildDetailSection(
                      context,
                      title: 'islamic.names_of_allah.meaning_title'.tr(),
                      icon: IconsaxPlusBold.book_1,
                      content: name.meaning,
                      isDark: isDark,
                      accentColor: const Color(0xFF16A085),
                    ),

                    SizedBox(height: 14.h),

                    // Quran / Hadith Reference
                    if (name.reference.isNotEmpty) ...[
                      _buildDetailSection(
                        context,
                        title: 'islamic.names_of_allah.evidence_title'.tr(),
                        icon: IconsaxPlusBold.document_text,
                        content: name.reference,
                        isDark: isDark,
                        accentColor: const Color(0xFF2980B9),
                      ),
                      SizedBox(height: 14.h),
                    ],

                    // Spiritual Benefit Section
                    if (name.benefit.isNotEmpty) ...[
                      _buildDetailSection(
                        context,
                        title: 'islamic.names_of_allah.fruits_title'.tr(),
                        icon: IconsaxPlusBold.heart,
                        content: name.benefit,
                        isDark: isDark,
                        accentColor: const Color(0xFFE67E22),
                      ),
                      SizedBox(height: 20.h),
                    ],

                    // Action Buttons (Share & Copy)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              final textToCopy = 'اسم الله: ${name.name}\n\nالمعنى: ${name.meaning}\n\nالشاهد: ${name.reference}\n\nالثمرة: ${name.benefit}';
                              Clipboard.setData(ClipboardData(text: textToCopy));
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('islamic.names_of_allah.copied_desc'.tr()),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            icon: const Icon(Icons.copy_rounded, size: 18),
                            label: Text('islamic.names_of_allah.copy_desc_btn'.tr()),
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
                                  final shareText = 'قال تعالى: ﴿وَلِلَّهِ الْأَسْمَاءُ الْحُسْنَىٰ فَادْعُوهُ بِهَا﴾\n\n✨ اسم الله: ${name.name} (${name.transliteration})\n📖 المعنى: ${name.meaning}\n📍 الشاهد: ${name.reference}\n🌱 الثمرة: ${name.benefit}\n\n#تطبيق_نورالدين #أسماء_الله_الحسنى';

                                  final box = btnContext.findRenderObject() as RenderBox?;
                                  final origin = box != null ? box.localToGlobal(Offset.zero) & box.size : null;

                                  try {
                                    final result = await Share.share(
                                      shareText,
                                      subject: name.name,
                                      sharePositionOrigin: origin,
                                    );
                                    if (result.status == ShareResultStatus.unavailable) {
                                      throw Exception('Share unavailable');
                                    }
                                  } catch (_) {
                                    await Clipboard.setData(ClipboardData(text: shareText));
                                    if (btnContext.mounted) {
                                      ScaffoldMessenger.of(btnContext).clearSnackBars();
                                      ScaffoldMessenger.of(btnContext).showSnackBar(
                                        SnackBar(
                                          content: Row(
                                            children: [
                                              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                                              const SizedBox(width: 8),
                                              Text('islamic.names_of_allah.copied_name'.tr(),
                                                  style: const TextStyle(fontFamily: 'Cairo')),
                                            ],
                                          ),
                                          backgroundColor: const Color(0xFF16A085),
                                          behavior: SnackBarBehavior.floating,
                                          duration: const Duration(seconds: 2),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                      );
                                    }
                                  }
                                },
                                icon: const Icon(Icons.share_outlined, size: 18),
                                label: Text('islamic.names_of_allah.share_name'.tr()),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF16A085),
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
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String content,
    required bool isDark,
    required Color accentColor,
  }) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131826) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? const Color(0xFF283452) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18.sp, color: accentColor),
              SizedBox(width: 8.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            content,
            style: TextStyle(
              fontSize: 13.sp,
              height: 1.6,
              color: isDark ? Colors.white70 : const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppTopBar(
        title: 'islamic.names_of_allah_title'.tr(),
        isTransparent: true,
        actions: [
          IconButton(
            icon: Icon(
              _showFavoritesOnly ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: _showFavoritesOnly ? const Color(0xFFFF5252) : (isDark ? Colors.white : Colors.black87),
            ),
            tooltip: 'islamic.hadith.favorites'.tr(),
            onPressed: () {
              setState(() {
                _showFavoritesOnly = !_showFavoritesOnly;
              });
            },
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: PremiumBackground(
        child: SafeArea(
          child: BlocBuilder<NamesOfAllahCubit, NamesOfAllahState>(
            builder: (context, state) {
              if (state.isLoading && state.names.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF16A085)));
              }

              final displayList = _showFavoritesOnly
                  ? state.filteredNames.where((n) => state.favoriteIds.contains(n.id)).toList()
                  : state.filteredNames;

              final screenWidth = MediaQuery.sizeOf(context).width;
              final crossAxisCount = screenWidth >= 1100
                  ? 5
                  : (screenWidth >= 800 ? 4 : (screenWidth >= 550 ? 3 : 2));
              final childAspectRatio = screenWidth >= 1100
                  ? 1.25
                  : (screenWidth >= 800 ? 1.2 : 1.12);

              return Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1080),
                  child: Column(
                    children: [
                      // Search & Filter Header
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (q) => context.read<NamesOfAllahCubit>().searchNames(q),
                            decoration: InputDecoration(
                              hintText: 'islamic.names_of_allah.search_hint'.tr(),
                              hintStyle: TextStyle(fontSize: 13.sp),
                              prefixIcon: const Icon(IconsaxPlusLinear.search_normal_1, size: 20),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 18),
                                      onPressed: () {
                                        _searchController.clear();
                                        context.read<NamesOfAllahCubit>().searchNames('');
                                      },
                                    )
                                  : null,
                              contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                              filled: true,
                              fillColor: isDark ? const Color(0xFF181E2E) : Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.r),
                                borderSide: BorderSide(
                                  color: isDark ? const Color(0xFF2B3650) : const Color(0xFFE2E8F0),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.r),
                                borderSide: BorderSide(
                                  color: isDark ? const Color(0xFF2B3650) : const Color(0xFFE2E8F0),
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (_showFavoritesOnly) ...[
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF5252).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.favorite, color: const Color(0xFFFF5252), size: 16.sp),
                                SizedBox(width: 4.w),
                                Text(
                                  'المفضلة (${state.favoriteIds.length})',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFFF5252),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Header Info Banner
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16A085).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: const Color(0xFF16A085).withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(IconsaxPlusBold.star_1, color: const Color(0xFF16A085), size: 18.sp),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              'قال رسول الله ﷺ: «إِنَّ لِلَّهِ تِسْعَةً وَتِسْعِينَ اسْمًا، مَنْ أَحْصَاهَا دَخَلَ الْجَنَّةَ»',
                              style: TextStyle(
                                fontSize: 11.5.sp,
                                fontWeight: FontWeight.bold,
                                color: isDark ? const Color(0xFF81C784) : const Color(0xFF0E6251),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 6.h),

                  // 99 Names Grid
                  Expanded(
                    child: displayList.isEmpty
                        ? Center(
                            child: Text(
                              _showFavoritesOnly
                                  ? 'لم تقم بإضافة أي أسماء إلى المفضلة بعد'
                                  : 'لا توجد نتائج تطابق بحثك',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                            ),
                          )
                        : GridView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 10.w,
                              mainAxisSpacing: 10.h,
                              childAspectRatio: childAspectRatio,
                            ),
                            itemCount: displayList.length,
                            itemBuilder: (context, index) {
                              final name = displayList[index];
                              final isFav = state.favoriteIds.contains(name.id);

                              return InkWell(
                                onTap: () => _showNameDetailsModal(context, name),
                                borderRadius: BorderRadius.circular(20.r),
                                child: Container(
                                  padding: EdgeInsets.all(12.w),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF181E2E) : Colors.white,
                                    borderRadius: BorderRadius.circular(20.r),
                                    border: Border.all(
                                      color: isFav
                                          ? const Color(0xFF16A085)
                                          : (isDark ? const Color(0xFF2B3650) : const Color(0xFFE2E8F0)),
                                      width: isFav ? 1.5 : 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.03),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            width: 26.w,
                                            height: 26.w,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: const Color(0xFF16A085).withValues(alpha: 0.12),
                                            ),
                                            child: Center(
                                              child: Text(
                                                '${name.id}',
                                                style: TextStyle(
                                                  fontSize: 10.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: const Color(0xFF16A085),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Icon(
                                            isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                            size: 16.sp,
                                            color: isFav
                                                ? const Color(0xFFFF5252)
                                                : (isDark ? Colors.white38 : Colors.black26),
                                          ),
                                        ],
                                      ),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          name.name,
                                          style: TextStyle(
                                            fontSize: 20.sp,
                                            fontFamily: 'Amiri',
                                            fontWeight: FontWeight.bold,
                                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                                          ),
                                        ),
                                      ),
                                      Text(
                                        name.transliteration,
                                        style: TextStyle(
                                          fontSize: 11.sp,
                                          color: isDark ? Colors.white54 : Colors.black45,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
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
    ),
  ),
);
}
}
