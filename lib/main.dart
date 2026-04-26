import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'core/theme/app_theme.dart';
import 'providers/prayer_provider.dart';
import 'providers/achievement_provider.dart';
import 'providers/quran_provider.dart';
import 'providers/gamification_provider.dart';
import 'providers/urge_resistance_provider.dart';
import 'providers/journey_provider.dart';
import 'providers/daily_achievements_provider.dart';
import 'providers/rewards_provider.dart';
import 'providers/quran_race_provider.dart';
import 'screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('APP_START: Starting Firebase initialization...');
  try {
    await Firebase.initializeApp().timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        print('APP_START: Firebase.initializeApp TIMED OUT');
        throw TimeoutException('Firebase init timeout');
      },
    );
    print('APP_START: Firebase initialized successfully');

    print('APP_START: Attempting anonymous sign-in...');
    await FirebaseAuth.instance.signInAnonymously().timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        print('APP_START: FirebaseAuth sign-in TIMED OUT');
        throw TimeoutException('Auth timeout');
      },
    );
    print('APP_START: Anonymous sign-in successful');
  } catch (e) {
    print('APP_START: Firebase/Auth Error: $e');
    debugPrint('Firebase initialization error: $e');
  }

  runApp(const BackToPrayerApp());
}

class BackToPrayerApp extends StatelessWidget {
  const BackToPrayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PrayerProvider()),
        ChangeNotifierProvider(create: (_) => QuranProvider()),
        ChangeNotifierProvider(create: (_) => GamificationProvider()),
        ChangeNotifierProvider(create: (_) => JourneyProvider()),
        ChangeNotifierProvider(create: (_) => UrgeResistanceProvider()),
        ChangeNotifierProvider(create: (_) => AchievementProvider()),
        ChangeNotifierProvider(create: (_) => DailyAchievementsProvider()),
        ChangeNotifierProvider(create: (_) => RewardsProvider()),
        ChangeNotifierProvider(create: (_) => QuranRaceProvider()),
      ],
      child: Builder(
        builder: (context) {
          // Connect providers with GamificationProvider
          final gamProvider = Provider.of<GamificationProvider>(
            context,
            listen: false,
          );
          final journeyProvider = Provider.of<JourneyProvider>(
            context,
            listen: false,
          );
          final dailyAchievementsProvider =
              Provider.of<DailyAchievementsProvider>(context, listen: false);
          final rewardsProvider = Provider.of<RewardsProvider>(
            context,
            listen: false,
          );

          journeyProvider.setGamificationProvider(gamProvider);
          dailyAchievementsProvider.setGamificationProvider(gamProvider);
          rewardsProvider.setGamificationProvider(gamProvider);

          // Check for daily reset on app start
          dailyAchievementsProvider.checkDailyReset();

          return Consumer<RewardsProvider>(
            builder: (context, rewardsProvider, child) {
              return MaterialApp(
                title: 'AlNoor | النور',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.getThemeById(rewardsProvider.activeThemeId),
                themeMode:
                    ThemeMode.dark, // Keep dark mode as default/forced for now
                home: const HomeScreen(),

                // Localization Config
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                locale: const Locale('ar', 'SA'),
                supportedLocales: const [
                  Locale('ar', 'SA'), // Arabic
                  Locale('en', 'US'), // English
                ],
              );
            },
          );
        },
      ),
    );
  }
}
