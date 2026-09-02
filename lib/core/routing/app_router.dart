import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/main_navigation/presentation/screens/main_navigation_scaffold.dart';
import '../../features/islamic_hub/presentation/screens/madani_quran_screen.dart';
import '../../features/islamic_hub/presentation/screens/surah_index_screen.dart';
import '../../features/islamic_hub/presentation/screens/quran_notes_screen.dart';
import '../../features/islamic_hub/presentation/screens/azkar_reader_screen.dart';
import '../../features/islamic_hub/presentation/screens/smart_tasbih_screen.dart';
import '../../features/islamic_hub/presentation/screens/qibla_compass_screen.dart';
import '../../features/islamic_hub/presentation/screens/worship_tracker_screen.dart';
import '../../features/islamic_hub/presentation/screens/names_of_allah_screen.dart';
import '../../features/islamic_hub/presentation/screens/nawawi_hadiths_screen.dart';
import '../../features/islamic_hub/presentation/screens/hadith_detail_screen.dart';
import '../../features/islamic_hub/presentation/screens/khatm_dua_screen.dart';
import '../../features/islamic_hub/presentation/screens/prayer_times_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MainNavigationScaffold(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const MainNavigationScaffold(initialIndex: 0),
    ),
    GoRoute(
      path: '/quran',
      builder: (context, state) => const MainNavigationScaffold(initialIndex: 1),
    ),
    GoRoute(
      path: '/madani-quran',
      builder: (context, state) => const MadaniQuranScreen(),
    ),
    GoRoute(
      path: '/surah-index',
      builder: (context, state) => const SurahIndexScreen(),
    ),
    GoRoute(
      path: '/quran-notes',
      builder: (context, state) => const QuranNotesScreen(),
    ),
    GoRoute(
      path: '/azkar',
      builder: (context, state) => const MainNavigationScaffold(initialIndex: 2),
    ),
    GoRoute(
      path: '/azkar/reader/:id',
      builder: (context, state) {
        final categoryId = state.pathParameters['id'] ?? 'morning';
        return AzkarReaderScreen(categoryId: categoryId);
      },
    ),
    GoRoute(
      path: '/tasbih',
      builder: (context, state) => const SmartTasbihScreen(),
    ),
    GoRoute(
      path: '/qibla',
      builder: (context, state) => const QiblaCompassScreen(),
    ),
    GoRoute(
      path: '/worship',
      builder: (context, state) => const MainNavigationScaffold(initialIndex: 3),
    ),
    GoRoute(
      path: '/worship-tracker',
      builder: (context, state) => const WorshipTrackerScreen(),
    ),
    GoRoute(
      path: '/more',
      builder: (context, state) => const MainNavigationScaffold(initialIndex: 4),
    ),
    GoRoute(
      path: '/names-of-allah',
      builder: (context, state) => const NamesOfAllahScreen(),
    ),
    GoRoute(
      path: '/hadith',
      builder: (context, state) => const NawawiHadithsScreen(),
    ),
    GoRoute(
      path: '/hadith/:id',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        return HadithDetailScreen(hadithId: id);
      },
    ),
    GoRoute(
      path: '/khatm-dua',
      builder: (context, state) => const KhatmDuaScreen(),
    ),
    GoRoute(
      path: '/prayer-times',
      builder: (context, state) => const PrayerTimesScreen(),
    ),

    // ── Legacy / Hub Aliases ──
    GoRoute(
      path: '/islamic-hub',
      builder: (context, state) => const MainNavigationScaffold(initialIndex: 0),
    ),
    GoRoute(
      path: '/islamic-hub/quran',
      builder: (context, state) => const MainNavigationScaffold(initialIndex: 1),
    ),
    GoRoute(
      path: '/islamic-hub/azkar',
      builder: (context, state) => const MainNavigationScaffold(initialIndex: 2),
    ),
    GoRoute(
      path: '/islamic-hub/azkar/reader/:id',
      builder: (context, state) {
        final categoryId = state.pathParameters['id'] ?? 'morning';
        return AzkarReaderScreen(categoryId: categoryId);
      },
    ),
    GoRoute(
      path: '/islamic-hub/tasbih',
      builder: (context, state) => const SmartTasbihScreen(),
    ),
    GoRoute(
      path: '/islamic-hub/qibla',
      builder: (context, state) => const QiblaCompassScreen(),
    ),
    GoRoute(
      path: '/islamic-hub/worship-tracker',
      builder: (context, state) => const WorshipTrackerScreen(),
    ),
    GoRoute(
      path: '/islamic-hub/names-of-allah',
      builder: (context, state) => const NamesOfAllahScreen(),
    ),
    GoRoute(
      path: '/islamic-hub/hadith',
      builder: (context, state) => const NawawiHadithsScreen(),
    ),
    GoRoute(
      path: '/islamic-hub/hadith/:id',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        return HadithDetailScreen(hadithId: id);
      },
    ),
    GoRoute(
      path: '/islamic-hub/khatm-dua',
      builder: (context, state) => const KhatmDuaScreen(),
    ),
    GoRoute(
      path: '/islamic-hub/prayer-times',
      builder: (context, state) => const PrayerTimesScreen(),
    ),
  ],
);
