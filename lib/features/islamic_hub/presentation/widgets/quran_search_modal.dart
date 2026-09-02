import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:hugeicons/hugeicons.dart';
import '../../domain/entities/ayah_entity.dart';
import '../../domain/repositories/islamic_hub_repository.dart';
import '../../data/repositories/islamic_hub_repository_impl.dart';

class QuranSearchModal extends StatefulWidget {
  final void Function(AyahEntity ayah) onAyahSelected;

  const QuranSearchModal({
    super.key,
    required this.onAyahSelected,
  });

  static Future<void> show(BuildContext context, {required void Function(AyahEntity ayah) onAyahSelected}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(maxWidth: 640),
      builder: (ctx) => QuranSearchModal(onAyahSelected: onAyahSelected),
    );
  }

  @override
  State<QuranSearchModal> createState() => _QuranSearchModalState();
}

class _QuranSearchModalState extends State<QuranSearchModal> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  bool _isLoading = false;
  List<AyahEntity> _searchResults = [];
  String _lastSearchedQuery = '';

  final List<String> _quickSuggestions = [
    'الله نور السماوات',
    'آية الكرسي',
    'إن مع العسر يسرا',
    'الرحمن علم القرآن',
    'قل هو الله أحد',
    'رب اشرح لي صدري',
  ];

  IslamicHubRepository _getRepo() {
    try {
      return context.read<IslamicHubRepository>();
    } catch (_) {
      return IslamicHubRepositoryImpl();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    _debounceTimer?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
        _lastSearchedQuery = '';
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _performSearch(query.trim());
    });
  }

  Future<void> _performSearch(String query) async {
    if (query == 'آية الكرسي' || query == 'اية الكرسي') {
      query = 'الله لا إله إلا هو الحي القيوم';
    }

    setState(() {
      _isLoading = true;
      _lastSearchedQuery = query;
    });

    try {
      final repo = _getRepo();
      final results = await repo.searchQuran(query);

      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E2433) : Colors.white;
    const primaryColor = Color(0xFF3551AE);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag Handle
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
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedSearch01,
                    color: primaryColor,
                    size: 20.r,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'البحث في القرآن الكريم',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      Text(
                        'ابحث بأي كلمة أو جزء من الآية في كامل المصحف',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),

          // Search Field
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 6.h),
            child: TextField(
              controller: _searchController,
              onChanged: _onQueryChanged,
              textInputAction: TextInputAction.search,
              onSubmitted: (q) => _performSearch(q.trim()),
              autofocus: true,
              style: TextStyle(fontSize: 14.sp, fontFamily: 'Cairo'),
              decoration: InputDecoration(
                hintText: 'islamic.search.hint'.tr(),
                hintStyle: TextStyle(fontSize: 13.sp, color: Colors.grey, fontFamily: 'Cairo'),
                filled: true,
                fillColor: isDark ? const Color(0xFF141824) : const Color(0xFFF4F6FB),
                prefixIcon: Icon(Icons.search, color: primaryColor, size: 22.r),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _onQueryChanged('');
                        },
                      )
                    : null,
                contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: const BorderSide(color: primaryColor, width: 1.5),
                ),
              ),
            ),
          ),

          // Quick Chips (if no search)
          if (_searchResults.isEmpty && !_isLoading && _lastSearchedQuery.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'بحث سريع ومقترحات:',
                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.grey, fontFamily: 'Cairo'),
                  ),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: _quickSuggestions.map((s) {
                      return InkWell(
                        onTap: () {
                          _searchController.text = s;
                          _performSearch(s);
                        },
                        borderRadius: BorderRadius.circular(20.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
                          ),
                          child: Text(
                            s,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

          // Loading indicator
          if (_isLoading)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: primaryColor),
                    SizedBox(height: 12.h),
                    Text(
                      'جاري البحث في آيات القرآن الكريم...',
                      style: TextStyle(fontSize: 13.sp, color: Colors.grey, fontFamily: 'Cairo'),
                    ),
                  ],
                ),
              ),
            )
          // Results count
          else if (_searchResults.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
              child: Row(
                children: [
                  Text(
                    'نتائج البحث: ${_searchResults.length} آية',
                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: primaryColor, fontFamily: 'Cairo'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                itemCount: _searchResults.length,
                separatorBuilder: (_, __) => SizedBox(height: 8.h),
                itemBuilder: (context, index) {
                  final ayah = _searchResults[index];
                  return _buildAyahResultCard(context, ayah, isDark, primaryColor);
                },
              ),
            ),
          ]
          // No results
          else if (_lastSearchedQuery.isNotEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search_off_rounded, size: 48.r, color: Colors.grey),
                    SizedBox(height: 8.h),
                    Text(
                      'لم يتم العثور على نتائج لـ "$_lastSearchedQuery"',
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey, fontFamily: 'Cairo'),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'تأكد من كتابة الكلمة بشكل صحيح',
                      style: TextStyle(fontSize: 11.sp, color: Colors.grey.withValues(alpha: 0.7), fontFamily: 'Cairo'),
                    ),
                  ],
                ),
              ),
            )
          else
            const Spacer(),
        ],
      ),
    );
  }

  Widget _buildAyahResultCard(
    BuildContext context,
    AyahEntity ayah,
    bool isDark,
    Color primaryColor,
  ) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        widget.onAyahSelected(ayah);
      },
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF141824) : const Color(0xFFF9FAFC),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isDark ? const Color(0xFF283248) : const Color(0xFFE8EEF8),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Surah Name & Page Badge
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    ayah.surahName,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    'الآية ${ayah.numberInSurah}',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber[800],
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'صفحة ${ayah.page}',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Cairo',
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(Icons.arrow_forward_ios_rounded, size: 12.r, color: Colors.grey),
              ],
            ),
            SizedBox(height: 10.h),

            // Ayah Text
            Text(
              ayah.text,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontSize: 15.sp,
                fontFamily: 'Amiri',
                height: 1.7,
                color: isDark ? Colors.white : const Color(0xFF1B2030),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
