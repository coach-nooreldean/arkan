import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../../../shared/widgets/premium_background.dart';
import '../cubits/hadith_cubit.dart';

class NawawiHadithsScreen extends StatefulWidget {
  const NawawiHadithsScreen({super.key});

  @override
  State<NawawiHadithsScreen> createState() => _NawawiHadithsScreenState();
}

class _NawawiHadithsScreenState extends State<NawawiHadithsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showFavoritesOnly = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppTopBar(
        title: 'islamic.nawawi_hadiths_title'.tr(),
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
          child: BlocBuilder<HadithCubit, HadithState>(
            builder: (context, state) {
              if (state.isLoading && state.hadiths.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF3551AE)));
              }

              final displayList = _showFavoritesOnly
                  ? state.filteredHadiths.where((h) => state.favoriteIds.contains(h.id)).toList()
                  : state.filteredHadiths;

              return Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 960),
                  child: Column(
                    children: [
                      // Search Bar
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (q) => context.read<HadithCubit>().searchHadiths(q),
                      decoration: InputDecoration(
                        hintText: 'islamic.hadith.search_hint'.tr(),
                        hintStyle: TextStyle(fontSize: 13.sp),
                        prefixIcon: const Icon(IconsaxPlusLinear.search_normal_1, size: 20),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  context.read<HadithCubit>().searchHadiths('');
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

                  // Header intro
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                              : [const Color(0xFFEFF6FF), const Color(0xFFDBEAFE)],
                        ),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFBFDBFE),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3551AE).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Icon(IconsaxPlusBold.book, color: const Color(0xFF3551AE), size: 20.sp),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'جامع أصول وقواعد الإسلام',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : const Color(0xFF1E3A8A),
                                  ),
                                ),
                                Text(
                                  'أحاديث جامعة في العقيدة والأحكام والآداب والأخلاق',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: isDark ? Colors.white60 : const Color(0xFF3B82F6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 6.h),

                  // Hadiths List
                  Expanded(
                    child: displayList.isEmpty
                        ? Center(
                            child: Text(
                              _showFavoritesOnly
                                  ? 'لم تقم بحفظ أي أحاديث في المفضلة بعد'
                                  : 'لا توجد أحاديث تطابق بحثك',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                            itemCount: displayList.length,
                            separatorBuilder: (_, __) => SizedBox(height: 10.h),
                            itemBuilder: (context, index) {
                              final hadith = displayList[index];
                              final isFav = state.favoriteIds.contains(hadith.id);

                              return InkWell(
                                onTap: () {
                                  context.read<HadithCubit>().selectHadith(hadith);
                                  context.push('/islamic-hub/hadith/${hadith.id}', extra: hadith);
                                },
                                borderRadius: BorderRadius.circular(18.r),
                                child: Container(
                                  padding: EdgeInsets.all(14.w),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF181E2E) : Colors.white,
                                    borderRadius: BorderRadius.circular(18.r),
                                    border: Border.all(
                                      color: isFav
                                          ? const Color(0xFF3551AE)
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
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Number Badge
                                      Container(
                                        width: 36.w,
                                        height: 36.w,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF3551AE).withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(12.r),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${hadith.id}',
                                            style: TextStyle(
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF3551AE),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 12.w),
                                      // Details
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    hadith.title,
                                                    style: TextStyle(
                                                      fontSize: 14.sp,
                                                      fontWeight: FontWeight.bold,
                                                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                IconButton(
                                                  visualDensity: VisualDensity.compact,
                                                  padding: EdgeInsets.zero,
                                                  constraints: const BoxConstraints(),
                                                  icon: Icon(
                                                    isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                                    size: 18.sp,
                                                    color: isFav ? const Color(0xFFFF5252) : (isDark ? Colors.white38 : Colors.black26),
                                                  ),
                                                  onPressed: () {
                                                    context.read<HadithCubit>().toggleFavorite(hadith.id);
                                                  },
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 3.h),
                                            Text(
                                              'عن: ${hadith.narrator}',
                                              style: TextStyle(
                                                fontSize: 11.5.sp,
                                                color: const Color(0xFF059669),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            SizedBox(height: 6.h),
                                            Text(
                                              hadith.hadithText,
                                              style: TextStyle(
                                                fontSize: 12.5.sp,
                                                color: isDark ? Colors.white70 : Colors.black87,
                                                fontFamily: 'Amiri',
                                                height: 1.5,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
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
