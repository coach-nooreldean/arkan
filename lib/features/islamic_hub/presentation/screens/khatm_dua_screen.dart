import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

class KhatmDuaScreen extends StatelessWidget {
  final void Function(int page)? onPageSelected;

  const KhatmDuaScreen({super.key, this.onPageSelected});

  static const List<Map<String, dynamic>> _sajdahPositions = [
    {'surah': 'الأعراف', 'surahNum': 7, 'ayah': 206, 'page': 176, 'juz': 9},
    {'surah': 'الرعد', 'surahNum': 13, 'ayah': 15, 'page': 250, 'juz': 13},
    {'surah': 'النحل', 'surahNum': 16, 'ayah': 50, 'page': 272, 'juz': 14},
    {'surah': 'الإسراء', 'surahNum': 17, 'ayah': 109, 'page': 293, 'juz': 15},
    {'surah': 'مريم', 'surahNum': 19, 'ayah': 58, 'page': 309, 'juz': 16},
    {'surah': 'الحج (الأولى)', 'surahNum': 22, 'ayah': 18, 'page': 334, 'juz': 17},
    {'surah': 'الحج (الثانية)', 'surahNum': 22, 'ayah': 77, 'page': 341, 'juz': 17},
    {'surah': 'الفرقان', 'surahNum': 25, 'ayah': 60, 'page': 365, 'juz': 19},
    {'surah': 'النمل', 'surahNum': 27, 'ayah': 26, 'page': 379, 'juz': 19},
    {'surah': 'السجدة', 'surahNum': 32, 'ayah': 15, 'page': 416, 'juz': 21},
    {'surah': 'ص', 'surahNum': 38, 'ayah': 24, 'page': 454, 'juz': 23},
    {'surah': 'فصلت', 'surahNum': 41, 'ayah': 38, 'page': 480, 'juz': 24},
    {'surah': 'النجم', 'surahNum': 53, 'ayah': 62, 'page': 528, 'juz': 27},
    {'surah': 'الانشقاق', 'surahNum': 84, 'ayah': 21, 'page': 589, 'juz': 30},
    {'surah': 'العلق', 'surahNum': 96, 'ayah': 19, 'page': 597, 'juz': 30},
  ];

  static const String _khatmDuaText = '''
بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ

اللَّهُمَّ ارْحَمْنِي بِالقُرْآنِ، وَاجْعَلْهُ لِي إِمَاماً وَنُوراً وَهُدًى وَرَحْمَةً.

اللَّهُمَّ ذَكِّرْنِي مِنْهُ مَا نَسِيتُ، وَعَلِّمْنِي مِنْهُ مَا جَهِلْتُ، وَارْزُقْنِي تِلَاوَتَهُ آنَاءَ اللَّيْلِ وَأَطْرَافَ النَّهَارِ، وَاجْعَلْهُ لِي حُجَّةً يَا رَبَّ العَالَمِينَ.

اللَّهُمَّ أَصْلِحْ لِي دِينِي الَّذِي هُوَ عِصْمَةُ أَمْرِي، وَأَصْلِحْ لِي دُنْيَايَ الَّتِي فِيهَا مَعَاشِي، وَأَصْلِحْ لِي آخِرَتِي الَّتِي فِيهَا مَعَادِي، وَاجْعَلِ الحَيَاةَ زِيَادَةً لِي فِي كُلِّ خَيْرٍ، وَاجْعَلِ المَوْتَ رَاحَةً لِي مِنْ كُلِّ شَرٍّ.

اللَّهُمَّ اجْعَلْ خَيْرَ عُمْرِي آخِرَهُ، وَخَيْرَ عَمَلِي خَوَاتِمَهُ، وَخَيْرَ أَيَّامِي يَوْمَ أَلْقَاكَ فِيهِ.

اللَّهُمَّ إِنِّي أَسْأَلُكَ عِيشَةً هَنِيَّةً، وَمِيتَةً سَوِيَّةً، وَمَرَدّاً غَيْرَ مُخْزٍ وَلَا فَاضِحٍ.

اللَّهُمَّ إِنِّي أَسْأَلُكَ خَيْرَ المَسْأَلَةِ، وَخَيْرَ الدُّعَاءِ، وَخَيْرَ النَّجَاحِ، وَخَيْرَ العِلْمِ، وَخَيْرَ العَمَلِ، وَخَيْرَ الثَّوَابِ، وَخَيْرَ الحَيَاةِ، وَخَيْرَ المَمَاتِ، وَثَبِّتْنِي وَثَقِّلْ مَوَازِينِي، وَحَقِّقْ إِيمَانِي، وَارْفَعْ دَرَجَتِي، وَتَقَبَّلْ صَلَاتِي، وَاغْفِرْ خَطِيئَاتِي، وَأَسْأَلُكَ العُلَا مِنَ الجَنَّةِ.

اللَّهُمَّ إِنَّا نَسْأَلُكَ مُوجِبَاتِ رَحْمَتِكَ، وَعَزَائِمَ مَغْفِرَتِكَ، وَالسَّلَامَةَ مِنْ كُلِّ إِثْمٍ، وَالغَنِيمَةَ مِنْ كُلِّ بِرٍّ، وَالفَوْزَ بِالجَنَّةِ، وَالنَّجَاةَ مِنَ النَّارِ.

اللَّهُمَّ لَا تَدَعْ لَنَا ذَنْباً إِلَّا غَفَرْتَهُ، وَلَا هَمّاً إِلَّا فَرَّجْتَهُ، وَلَا دَيْناً إِلَّا قَضَيْتَهُ، وَلَا حَاجَةً مِنْ حَوَائِجِ الدُّنْيَا وَالآخِرَةِ إِلَّا قَضَيْتَهَا يَا أَرْحَمَ الرَّاحِمِينَ.

رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ، وَصَلَّى اللَّهُ عَلَى سَيِّدِنَا مُحَمَّدٍ وَعَلَى آلِهِ وَصَحْبِهِ وَسَلَّمَ تَسْلِيماً كَثِيراً.
''';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const primaryColor = Color(0xFF3551AE);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
                    child: Icon(IconsaxPlusLinear.arrow_right_3, size: 20.sp),
                  ),
                ),
              ),
            ),
          ),
          title: Text('islamic.khatm_dua_title'.tr(), style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
          centerTitle: true,
          bottom: TabBar(
            labelColor: isDark ? Colors.white : primaryColor,
            indicatorColor: primaryColor,
            labelStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
            tabs: [
              Tab(text: 'islamic.khatm_dua.dua_tab'.tr(), icon: const Icon(Icons.menu_book_outlined)),
              Tab(text: 'islamic.khatm_dua.sajdahs_tab'.tr(), icon: const Icon(Icons.place_outlined)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Dua
            _buildDuaTab(context, isDark, primaryColor),

            // Tab 2: Sajdahs
            _buildSajdahsTab(context, isDark, primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildDuaTab(BuildContext context, bool isDark, Color primaryColor) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 880),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.r),
          child: Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2433) : const Color(0xFFFAF8F5),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: isDark ? const Color(0xFF2C384E) : const Color(0xFFE8DFD8),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.auto_awesome_rounded, color: primaryColor, size: 28.r),
                ),
                SizedBox(height: 12.h),
                Text(
                  'islamic.khatm_dua.dua_title'.tr(),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                    fontFamily: 'Cairo',
                  ),
                ),
                SizedBox(height: 16.h),
                Divider(color: primaryColor.withValues(alpha: 0.2)),
                SizedBox(height: 12.h),
                Text(
                  _khatmDuaText,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontFamily: 'Amiri',
                    height: 2.1,
                    color: isDark ? Colors.white : const Color(0xFF1E2433),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSajdahsTab(BuildContext context, bool isDark, Color primaryColor) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 880),
        child: ListView(
          padding: EdgeInsets.all(16.r),
          children: [
            // Dua of Sujood banner
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF26324D), const Color(0xFF192133)]
                      : [const Color(0xFF3551AE), const Color(0xFF20367A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.wb_sunny_outlined, color: Colors.amber, size: 20),
                      SizedBox(width: 8.w),
                      Text(
                        'islamic.khatm_dua.sujood_dua_label'.tr(),
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    '«سَجَدَ وَجْهِي لِلَّذِي خَلَقَهُ، وَشَقَّ سَمْعَهُ وَبَصَرَهُ بِحَوْلِهِ وَقُوَّتِهِ، فَتَبَارَكَ اللَّهُ أَحْسَنُ الخَالِقِينَ»',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: 'Amiri',
                      height: 1.8,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            Text(
              'islamic.khatm_dua.sajdahs_list_title'.tr(),
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
            ),
            SizedBox(height: 10.h),

            ...List.generate(_sajdahPositions.length, (index) {
              final s = _sajdahPositions[index];
              return Card(
                margin: EdgeInsets.only(bottom: 8.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: primaryColor.withValues(alpha: 0.12),
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontFamily: 'Cairo'),
                    ),
                  ),
                  title: Text(
                    'سورة ${s['surah']}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp, fontFamily: 'Cairo'),
                  ),
                  subtitle: Text(
                    'islamic.khatm_dua.ayah_juz_format'.tr(args: [s['ayah'].toString(), s['juz'].toString()]),
                    style: TextStyle(fontSize: 11.sp, color: Colors.grey, fontFamily: 'Cairo'),
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      if (onPageSelected != null) {
                        Navigator.pop(context);
                        onPageSelected!(s['page'] as int);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor.withValues(alpha: 0.1),
                      foregroundColor: primaryColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                    ),
                    child: Text('islamic.khatm_dua.page_format'.tr(args: [s['page'].toString()]), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.sp, fontFamily: 'Cairo')),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
