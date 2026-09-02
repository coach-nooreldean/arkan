import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../../../shared/widgets/premium_background.dart';
import '../cubits/quran_cubit.dart';

class SurahIndexScreen extends StatefulWidget {
  const SurahIndexScreen({super.key});

  @override
  State<SurahIndexScreen> createState() => _SurahIndexScreenState();
}

class _SurahIndexScreenState extends State<SurahIndexScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
        title: 'islamic.quran_title'.tr(),
        isTransparent: true,
      ),
      body: PremiumBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    indicatorColor: const Color(0xFF16A085),
                    labelColor: const Color(0xFF16A085),
                    unselectedLabelColor: isDark ? Colors.white60 : Colors.black54,
                    labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                    tabs: [
                      Tab(text: 'islamic.surahs_index'.tr()),
                      Tab(text: 'islamic.juz_index'.tr()),
                      Tab(text: 'islamic.bookmarks'.tr()),
                    ],
                  ),
                  // Search Bar
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => context.read<QuranCubit>().filterSurahs(val),
                      decoration: InputDecoration(
                        hintText: 'ابحث باسم السورة أو رقمها...',
                        prefixIcon: const Icon(IconsaxPlusLinear.search_normal),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  context.read<QuranCubit>().filterSurahs('');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: isDark ? const Color(0xFF161B2B) : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          borderSide: BorderSide(
                            color: isDark ? Colors.white12 : Colors.black12,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Tab Views
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Tab 1: Surahs List / Grid
                        _buildSurahsTab(context),

                        // Tab 2: Juzs List / Grid
                        _buildJuzsTab(context),

                        // Tab 3: Bookmarks List / Grid
                        _buildBookmarksTab(context),
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
  }

  Widget _buildSurahsTab(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<QuranCubit, QuranState>(
      builder: (context, state) {
        final surahs = state.filteredSurahs;

        if (surahs.isEmpty) {
          return const Center(child: Text('لا توجد نتائج مطابقة'));
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 600;

            if (isWide) {
              return GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 420,
                  mainAxisExtent: 82,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 10,
                ),
                itemCount: surahs.length,
                itemBuilder: (context, index) {
                  return _buildSurahCard(context, surahs[index], isDark);
                },
              );
            }

            return ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              itemCount: surahs.length,
              separatorBuilder: (_, __) => SizedBox(height: 8.h),
              itemBuilder: (context, index) {
                return _buildSurahCard(context, surahs[index], isDark);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSurahCard(BuildContext context, dynamic surah, bool isDark) {
    return InkWell(
      onTap: () {
        context.read<QuranCubit>().setPage(surah.startPage);
        context.push('/islamic-hub/quran/read');
      },
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161B2B) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.black12,
          ),
        ),
        child: Row(
          children: [
            // Number Badge
            Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF16A085).withValues(alpha: 0.12),
              ),
              child: Center(
                child: Text(
                  '${surah.number}',
                  style: TextStyle(
                    color: const Color(0xFF16A085),
                    fontWeight: FontWeight.bold,
                    fontSize: 13.sp,
                  ),
                ),
              ),
            ),
            SizedBox(width: 14.w),

            // Surah Name & details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    surah.name,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: surah.isMeccan
                              ? Colors.amber.withValues(alpha: 0.15)
                              : Colors.blue.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          surah.isMeccan ? 'مكية' : 'مدنية',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: surah.isMeccan ? Colors.amber[800] : Colors.blue[800],
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '${surah.numberOfAyahs} آية',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Page number badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                'ص ${surah.startPage}',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJuzsTab(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<QuranCubit, QuranState>(
      builder: (context, state) {
        final juzs = state.juzs;

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 600;

            if (isWide) {
              return GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 420,
                  mainAxisExtent: 82,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 10,
                ),
                itemCount: juzs.length,
                itemBuilder: (context, index) {
                  return _buildJuzCard(context, juzs[index], isDark);
                },
              );
            }

            return ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              itemCount: juzs.length,
              separatorBuilder: (_, __) => SizedBox(height: 8.h),
              itemBuilder: (context, index) {
                return _buildJuzCard(context, juzs[index], isDark);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildJuzCard(BuildContext context, dynamic juz, bool isDark) {
    return InkWell(
      onTap: () {
        context.read<QuranCubit>().setPage(juz.startPage);
        context.push('/islamic-hub/quran/read');
      },
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161B2B) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.black12,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF3551AE).withValues(alpha: 0.12),
              ),
              child: Center(
                child: Text(
                  '${juz.number}',
                  style: TextStyle(
                    color: const Color(0xFF3551AE),
                    fontWeight: FontWeight.bold,
                    fontSize: 13.sp,
                  ),
                ),
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    juz.name,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    'يبدأ من سورة ${juz.startSurah}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'ص ${juz.startPage}',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookmarksTab(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<QuranCubit, QuranState>(
      builder: (context, state) {
        final bookmarks = state.bookmarkedPages;

        if (bookmarks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(IconsaxPlusLinear.bookmark, size: 48.sp, color: Colors.grey),
                SizedBox(height: 12.h),
                Text(
                  'لا توجد علامات مرجعية محفوظة بعد',
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 600;

            if (isWide) {
              return GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 420,
                  mainAxisExtent: 72,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 10,
                ),
                itemCount: bookmarks.length,
                itemBuilder: (context, index) {
                  final page = bookmarks[index];
                  return ListTile(
                    tileColor: isDark ? const Color(0xFF161B2B) : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                    leading: const Icon(IconsaxPlusBold.bookmark, color: Color(0xFFE67E22)),
                    title: Text('صفحة $page'),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    onTap: () {
                      context.read<QuranCubit>().setPage(page);
                      context.push('/islamic-hub/quran/read');
                    },
                  );
                },
              );
            }

            return ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              itemCount: bookmarks.length,
              separatorBuilder: (_, __) => SizedBox(height: 8.h),
              itemBuilder: (context, index) {
                final page = bookmarks[index];

                return ListTile(
                  tileColor: isDark ? const Color(0xFF161B2B) : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                  leading: const Icon(IconsaxPlusBold.bookmark, color: Color(0xFFE67E22)),
                  title: Text('صفحة $page'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: () {
                    context.read<QuranCubit>().setPage(page);
                    context.push('/islamic-hub/quran/read');
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
