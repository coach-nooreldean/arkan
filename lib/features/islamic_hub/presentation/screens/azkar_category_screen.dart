import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../../../shared/widgets/premium_background.dart';
import '../../data/datasources/quran_remote_datasource.dart';
import '../../domain/entities/azkar_category_entity.dart';
import '../cubits/azkar_cubit.dart';
import '../cubits/islamic_settings_cubit.dart';
import '../widgets/smart_reminders_sheet.dart';

class AzkarCategoryScreen extends StatefulWidget {
  const AzkarCategoryScreen({super.key});

  @override
  State<AzkarCategoryScreen> createState() => _AzkarCategoryScreenState();
}

class _AzkarCategoryScreenState extends State<AzkarCategoryScreen> {
  late final TextEditingController _searchController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  IconData _getCategoryIcon(String iconName) {
    switch (iconName) {
      case 'sun':
        return IconsaxPlusBold.sun_1;
      case 'moon':
        return IconsaxPlusBold.moon;
      case 'pray':
        return IconsaxPlusBold.clock;
      case 'bed':
        return IconsaxPlusBold.lamp_charge;
      case 'sunrise':
        return IconsaxPlusBold.sun_fog;
      case 'book-open':
        return IconsaxPlusBold.book_1;
      case 'shield-check':
        return IconsaxPlusBold.shield_tick;
      case 'car':
        return IconsaxPlusBold.car;
      case 'heart-circle':
        return IconsaxPlusBold.heart_circle;
      case 'trend-up':
        return IconsaxPlusBold.trend_up;
      case 'people':
        return IconsaxPlusBold.people;
      default:
        return IconsaxPlusBold.heart;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppTopBar(
        title: 'islamic.azkar_title'.tr(),
        isTransparent: true,
        showBackButton: false,
        actions: [
          IconButton(
            tooltip: 'تذكيرات الأذكار والورد',
            icon: const Icon(IconsaxPlusBold.notification_bing, color: Color(0xFF10B981)),
            onPressed: () => SmartRemindersSheet.show(context),
          ),
          TextButton.icon(
            onPressed: () => context.push('/tasbih'),
            icon: const Icon(IconsaxPlusBold.refresh_circle, size: 18, color: Color(0xFF8E44AD)),
            label: Text(
              'السبحة الذكية',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12.sp,
                color: const Color(0xFF8E44AD),
              ),
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: PremiumBackground(
        child: SafeArea(
          child: BlocBuilder<IslamicSettingsCubit, IslamicSettingsState>(
            builder: (context, settingsState) {
              final favoriteIds = settingsState.settings.favoriteAzkarIds;
              return BlocBuilder<AzkarCubit, AzkarState>(
                builder: (context, state) {
                  final categories = state.categories;

                  if (state.isLoading && categories.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final screenWidth = MediaQuery.sizeOf(context).width;
                  final isWide = screenWidth >= 650;
                  final normalizedQuery =
                      QuranRemoteDataSourceImpl.normalizeArabicForSearch(_searchQuery);
                  final isSearching = normalizedQuery.isNotEmpty;

                  final displayCategories = <AzkarCategoryEntity>[];
                  if (!isSearching && favoriteIds.isNotEmpty) {
                    final favCat =
                        context.read<AzkarCubit>().buildFavoritesCategory(favoriteIds);
                    if (favCat.items.isNotEmpty) {
                      displayCategories.add(favCat);
                    }
                  }
                  displayCategories.addAll(categories);

                  final matchingCategories = isSearching
                      ? categories
                          .where(
                            (c) => QuranRemoteDataSourceImpl.normalizeArabicForSearch(
                              c.name,
                            ).contains(normalizedQuery),
                          )
                          .toList()
                      : const <AzkarCategoryEntity>[];

                  final matchingItems =
                      <({AzkarCategoryEntity category, AzkarItemEntity item})>[];
                  if (isSearching) {
                    for (final c in categories) {
                      for (final item in c.items) {
                        final itemTextNorm =
                            QuranRemoteDataSourceImpl.normalizeArabicForSearch(item.text);
                        final rewardNorm =
                            QuranRemoteDataSourceImpl.normalizeArabicForSearch(
                          item.reward ?? '',
                        );
                        if (itemTextNorm.contains(normalizedQuery) ||
                            rewardNorm.contains(normalizedQuery)) {
                          matchingItems.add((category: c, item: item));
                          if (matchingItems.length >= 40) break;
                        }
                      }
                      if (matchingItems.length >= 40) break;
                    }
                  }

                  return Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 4.h),
                            child: TextField(
                              controller: _searchController,
                              onChanged: (val) => setState(() => _searchQuery = val),
                              decoration: InputDecoration(
                                hintText: 'ابحث في الأذكار والأدعية...',
                                prefixIcon: const Icon(IconsaxPlusLinear.search_normal),
                                suffixIcon: _searchQuery.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.close_rounded),
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() => _searchQuery = '');
                                        },
                                      )
                                    : null,
                                filled: true,
                                fillColor: isDark
                                    ? const Color(0xFF161B2B)
                                    : Colors.white,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 14.w,
                                  vertical: 12.h,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16.r),
                                  borderSide: BorderSide(
                                    color: isDark
                                        ? const Color(0xFF252E46)
                                        : const Color(0xFFE2E8F0),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16.r),
                                  borderSide: BorderSide(
                                    color: isDark
                                        ? const Color(0xFF252E46)
                                        : const Color(0xFFE2E8F0),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: isSearching
                                ? _buildSearchResults(
                                    context,
                                    matchingCategories,
                                    matchingItems,
                                    isDark,
                                  )
                                : (isWide
                                    ? GridView.builder(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16.w,
                                          vertical: 12.h,
                                        ),
                                        gridDelegate:
                                            const SliverGridDelegateWithMaxCrossAxisExtent(
                                          maxCrossAxisExtent: 440,
                                          mainAxisExtent: 90,
                                          crossAxisSpacing: 12,
                                          mainAxisSpacing: 12,
                                        ),
                                        itemCount: displayCategories.length,
                                        itemBuilder: (context, index) => _buildCategoryCard(
                                          context,
                                          displayCategories[index],
                                          isDark,
                                        ),
                                      )
                                    : ListView.separated(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16.w,
                                          vertical: 12.h,
                                        ),
                                        itemCount: displayCategories.length,
                                        separatorBuilder: (_, __) =>
                                            SizedBox(height: 12.h),
                                        itemBuilder: (context, index) => _buildCategoryCard(
                                          context,
                                          displayCategories[index],
                                          isDark,
                                        ),
                                      )),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults(
    BuildContext context,
    List<AzkarCategoryEntity> matchingCategories,
    List<({AzkarCategoryEntity category, AzkarItemEntity item})> matchingItems,
    bool isDark,
  ) {
    if (matchingCategories.isEmpty && matchingItems.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Text(
            'لا توجد أذكار مطابقة لعبارة البحث',
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      children: [
        if (matchingCategories.isNotEmpty) ...[
          Text(
            'الأقسام المطابقة',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          SizedBox(height: 8.h),
          for (final cat in matchingCategories) ...[
            _buildCategoryCard(context, cat, isDark),
            SizedBox(height: 10.h),
          ],
        ],
        if (matchingItems.isNotEmpty) ...[
          SizedBox(height: 4.h),
          Text(
            'أذكار وأدعية مطابقة (${matchingItems.length})',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          SizedBox(height: 8.h),
          for (final match in matchingItems)
            Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: InkWell(
                onTap: () {
                  context.read<AzkarCubit>().selectCategory(match.category.id);
                  context.push('/islamic-hub/azkar/reader/${match.category.id}');
                },
                borderRadius: BorderRadius.circular(16.r),
                child: Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF161B2B) : Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: isDark ? const Color(0xFF252E46) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        match.category.name,
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.bold,
                          color: Color(match.category.colorValue),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        match.item.text,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          height: 1.6,
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildCategoryCard(BuildContext context, AzkarCategoryEntity cat, bool isDark) {
    final iconData = _getCategoryIcon(cat.icon);
    final color = Color(cat.colorValue);
    final isDone = cat.id != 'favorites' && cat.isFullyClaimedToday;

    return InkWell(
      onTap: () {
        if (cat.id == 'favorites') {
          final favIds =
              context.read<IslamicSettingsCubit>().state.settings.favoriteAzkarIds;
          context.read<AzkarCubit>().selectFavoritesCategory(favIds);
        } else {
          context.read<AzkarCubit>().selectCategory(cat.id);
        }
        context.push('/islamic-hub/azkar/reader/${cat.id}');
      },
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161B2B) : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isDone
                ? const Color(0xFF27AE60)
                : (isDark ? const Color(0xFF252E46) : const Color(0xFFE2E8F0)),
            width: isDone ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Center(
                child: Icon(iconData, color: color, size: 24.sp),
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    cat.name,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    '${cat.items.length} ذكر ودعاء',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            if (isDone)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF27AE60).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(IconsaxPlusBold.tick_circle, color: Color(0xFF27AE60), size: 14),
                    SizedBox(width: 4),
                    Text(
                      'مكتمل اليوم',
                      style: TextStyle(
                        color: Color(0xFF27AE60),
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              )
            else
              Icon(
                IconsaxPlusLinear.arrow_left_2,
                color: isDark ? Colors.white38 : Colors.black26,
                size: 18.sp,
              ),
          ],
        ),
      ),
    );
  }
}
