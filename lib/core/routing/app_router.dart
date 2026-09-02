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
    // ── Main Tab Navigation Shells ──
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
      path: '/azkar',
      builder: (context, state) => const MainNavigationScaffold(initialIndex: 2),
    ),
    GoRoute(
      path: '/worship',
      builder: (context, state) => const MainNavigationScaffold(initialIndex: 3),
    ),
    GoRoute(
      path: '/more',
      builder: (context, state) => const MainNavigationScaffold(initialIndex: 4),
    ),

    // ── Dedicated Full-Screen Pages (Push over Root Navigator to HIDE bottom bar) ──
    GoRoute(
      path: '/madani-quran',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const MadaniQuranScreen(),
    ),
    GoRoute(
      path: '/quran/read',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const MadaniQuranScreen(),
    ),
    GoRoute(
      path: '/islamic-hub/quran/read',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const MadaniQuranScreen(),
    ),
    GoRoute(
      path: '/surah-index',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const SurahIndexScreen(),
    ),
    GoRoute(
      path: '/quran-notes',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const QuranNotesScreen(),
    ),
    GoRoute(
      path: '/islamic-hub/quran-notes',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const QuranNotesScreen(),
    ),
    GoRoute(
      path: '/azkar/reader/:id',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        final categoryId = state.pathParameters['id'] ?? 'morning';
        return AzkarReaderScreen(categoryId: categoryId);
      },
    ),
    GoRoute(
      path: '/islamic-hub/azkar/reader/:id',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        final categoryId = state.pathParameters['id'] ?? 'morning';
        return AzkarReaderScreen(categoryId: categoryId);
      },
    ),
    GoRoute(
      path: '/tasbih',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const SmartTasbihScreen(),
    ),
    GoRoute(
      path: '/islamic-hub/tasbih',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const SmartTasbihScreen(),
    ),
    GoRoute(
      path: '/qibla',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const QiblaCompassScreen(),
    ),
    GoRoute(
      path: '/islamic-hub/qibla',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const QiblaCompassScreen(),
    ),
    GoRoute(
      path: '/worship-tracker',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const WorshipTrackerScreen(),
    ),
    GoRoute(
      path: '/islamic-hub/worship-tracker',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const WorshipTrackerScreen(),
    ),
    GoRoute(
      path: '/names-of-allah',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const NamesOfAllahScreen(),
    ),
    GoRoute(
      path: '/islamic-hub/names-of-allah',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const NamesOfAllahScreen(),
    ),
    GoRoute(
      path: '/hadith',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const NawawiHadithsScreen(),
    ),
    GoRoute(
      path: '/islamic-hub/hadith',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const NawawiHadithsScreen(),
    ),
    GoRoute(
      path: '/hadith/:id',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        return HadithDetailScreen(hadithId: id);
      },
    ),
    GoRoute(
      path: '/islamic-hub/hadith/:id',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        return HadithDetailScreen(hadithId: id);
      },
    ),
    GoRoute(
      path: '/khatm-dua',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const KhatmDuaScreen(),
    ),
    GoRoute(
      path: '/islamic-hub/khatm-dua',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const KhatmDuaScreen(),
    ),
    GoRoute(
      path: '/prayer-times',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const PrayerTimesScreen(),
    ),
    GoRoute(
      path: '/islamic-hub/prayer-times',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const PrayerTimesScreen(),
    ),

    // Hub Aliases
    GoRoute(
      path: '/islamic-hub',
      builder: (context, state) => const MainNavigationScaffold(initialIndex: 0),
    ),
    GoRoute(
      path: '/islamic-hub/quran',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const MadaniQuranScreen(),
    ),
    GoRoute(
      path: '/islamic-hub/azkar',
      builder: (context, state) => const MainNavigationScaffold(initialIndex: 2),
    ),
  ],
);
