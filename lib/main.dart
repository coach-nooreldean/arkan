import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'core/theme/theme.dart';
import 'core/services/notification_service.dart';
import 'core/routing/app_router.dart';
import 'features/islamic_hub/data/repositories/islamic_hub_repository_impl.dart';
import 'features/islamic_hub/domain/repositories/islamic_hub_repository.dart';
import 'features/islamic_hub/presentation/cubits/islamic_settings_cubit.dart';
import 'features/islamic_hub/presentation/cubits/prayer_times_cubit.dart';
import 'features/islamic_hub/presentation/cubits/quran_cubit.dart';
import 'features/islamic_hub/presentation/cubits/azkar_cubit.dart';
import 'features/islamic_hub/presentation/cubits/tasbih_cubit.dart';
import 'features/islamic_hub/presentation/cubits/worship_tracker_cubit.dart';
import 'features/islamic_hub/presentation/cubits/khatmah_cubit.dart';
import 'features/islamic_hub/presentation/cubits/names_of_allah_cubit.dart';
import 'features/islamic_hub/presentation/cubits/hadith_cubit.dart';
import 'features/islamic_hub/presentation/cubits/qibla_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Initialize notifications service for prayer alerts & azkar
  await NotificationService().init(requestPermissions: true);

  final repository = IslamicHubRepositoryImpl();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ar'),
      startLocale: const Locale('ar'),
      child: RepositoryProvider<IslamicHubRepository>.value(
        value: repository,
        child: MultiBlocProvider(
          providers: [
            BlocProvider<IslamicSettingsCubit>(
              create: (context) => IslamicSettingsCubit(repository: repository),
            ),
            BlocProvider<PrayerTimesCubit>(
              create: (context) => PrayerTimesCubit(repository: repository),
            ),
            BlocProvider<QuranCubit>(
              create: (context) => QuranCubit(repository: repository),
            ),
            BlocProvider<AzkarCubit>(
              create: (context) => AzkarCubit(repository: repository),
            ),
            BlocProvider<TasbihCubit>(
              create: (context) => TasbihCubit(repository: repository),
            ),
            BlocProvider<WorshipTrackerCubit>(
              create: (context) => WorshipTrackerCubit(),
            ),
            BlocProvider<KhatmahCubit>(
              create: (context) => KhatmahCubit(repository: repository),
            ),
            BlocProvider<NamesOfAllahCubit>(
              create: (context) => NamesOfAllahCubit(),
            ),
            BlocProvider<HadithCubit>(
              create: (context) => HadithCubit(),
            ),
            BlocProvider<QiblaCubit>(
              create: (context) => QiblaCubit(repository: repository),
            ),
          ],
          child: const ArkanApp(),
        ),
      ),
    ),
  );
}

class ArkanApp extends StatelessWidget {
  const ArkanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'أركان | Arkan',
          debugShowCheckedModeBanner: false,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          theme: buildLightTheme(primaryColorHex: '#3551AE'),
          darkTheme: buildDarkTheme(primaryColorHex: '#3551AE'),
          themeMode: ThemeMode.dark, // Default to obsidian dark theme
          routerConfig: appRouter,
        );
      },
    );
  }
}
