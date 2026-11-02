import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'core/theme/app_theme.dart';
import 'core/services/notification_service.dart';
import 'core/navigation/app_navigator.dart';
import 'l10n/app_localizations.dart';
import 'providers/app_settings_provider.dart';
import 'providers/adhkar_progress_provider.dart';
import 'providers/spiritual_journey_provider.dart';
import 'providers/prayer_provider.dart';
import 'providers/achievement_provider.dart';
import 'providers/quran_provider.dart';
import 'providers/gamification_provider.dart';
import 'providers/urge_resistance_provider.dart';
import 'providers/journey_provider.dart';
import 'providers/daily_achievements_provider.dart';
import 'providers/rewards_provider.dart';
import 'providers/tasbeeh_provider.dart';
import 'providers/dua_provider.dart';
import 'providers/asma_provider.dart';
import 'providers/worship_tracker_provider.dart';
import 'providers/hijri_calendar_provider.dart';
import 'providers/islamic_quiz_provider.dart';
import 'providers/saved_library_provider.dart';
import 'providers/nasheed_library_provider.dart';
import 'providers/quran_audio_settings_provider.dart';
import 'providers/hadith_explanation_provider.dart';
import 'providers/hadith_provider.dart';
import 'providers/quran_race_provider.dart';
import 'core/services/alnoor_audio_handler.dart';
import 'core/services/islamic_audio_player.dart';
import 'screens/home/home_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'widgets/audio/global_mini_player.dart';
import 'package:audio_service/audio_service.dart';

AudioHandler? _globalAudioHandler;
bool _audioServiceStarting = false;

/// Starts the background media session after the splash intro has finished,
/// so [IntroAudio] can play `opening.mpeg` without fighting AudioService.
Future<AudioHandler?> ensureAlNoorAudioService() async {
  if (_globalAudioHandler != null) return _globalAudioHandler;
  if (_audioServiceStarting) return null;
  _audioServiceStarting = true;
  try {
    _globalAudioHandler = await initAlNoorAudioService();
  } catch (e) {
    debugPrint('AudioService init failed (foreground-only fallback): $e');
  } finally {
    _audioServiceStarting = false;
  }
  return _globalAudioHandler;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final timezone = await FlutterTimezone.getLocalTimezone();
    await NotificationService().rememberTimezone(timezone);
  } catch (e) {
    debugPrint('Timezone lookup failed: $e');
  }

  // Delay AudioService until after splash so opening.mpeg can play cleanly.

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
        ChangeNotifierProvider(create: (_) => AppSettingsProvider()),
        ChangeNotifierProvider(create: (_) => AdhkarProgressProvider()),
        ChangeNotifierProvider(create: (_) => SpiritualJourneyProvider()),
        ChangeNotifierProvider(create: (_) => PrayerProvider()),
        ChangeNotifierProvider(create: (_) => QuranProvider()),
        ChangeNotifierProvider(create: (_) => GamificationProvider()),
        ChangeNotifierProvider(create: (_) => JourneyProvider()),
        ChangeNotifierProvider(create: (_) => UrgeResistanceProvider()),
        ChangeNotifierProvider(create: (_) => AchievementProvider()),
        ChangeNotifierProvider(create: (_) => DailyAchievementsProvider()),
        ChangeNotifierProvider(create: (_) => RewardsProvider()),
        ChangeNotifierProvider(create: (_) => QuranRaceProvider()),
        ChangeNotifierProvider(create: (_) => HadithProvider()..initialize()),
        ChangeNotifierProvider(
          create: (_) => HadithExplanationProvider()..initialize(),
        ),
        ChangeNotifierProvider(create: (_) => TasbeehProvider()..load()),
        ChangeNotifierProvider(create: (_) => DuaProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => AsmaProvider()..initialize()),
        ChangeNotifierProvider(
          create: (_) => WorshipTrackerProvider()..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => HijriCalendarProvider()..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => IslamicQuizProvider()..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => SavedLibraryProvider()..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => IslamicAudioPlayer(handler: _globalAudioHandler),
        ),
        ChangeNotifierProvider(create: (_) => QuranAudioSettingsProvider()),
        ChangeNotifierProvider(
          create: (_) => NasheedLibraryProvider()..initialize(),
        ),
      ],
      child: Builder(
        builder: (context) {
          // Wire nasheed library to the single global player once.
          context.read<NasheedLibraryProvider>().attachPlayer(
                context.read<IslamicAudioPlayer>(),
              );

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

          // Check for daily reset on app start (achievements + Adhkar)
          dailyAchievementsProvider.checkDailyReset();
          context.read<AdhkarProgressProvider>().ensureToday();

          return Consumer2<RewardsProvider, AppSettingsProvider>(
            builder: (context, rewardsProvider, settings, child) {
              return MaterialApp(
                title: 'AlNoor | النور',
                navigatorKey: appNavigatorKey,
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightThemeFor(rewardsProvider.activeThemeId),
                darkTheme: AppTheme.getThemeById(rewardsProvider.activeThemeId),
                themeMode: settings.themeMode,
                themeAnimationDuration: const Duration(milliseconds: 350),
                themeAnimationCurve: Curves.easeOutCubic,
                home: const _AppEntry(),
                builder: (context, child) {
                  return GlobalAudioShell(child: child ?? const SizedBox.shrink());
                },

                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                locale: settings.locale,
                supportedLocales: AppLocalizations.supportedLocales,
              );
            },
          );
        },
      ),
    );
  }
}

class _AppEntry extends StatefulWidget {
  const _AppEntry();

  @override
  State<_AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<_AppEntry> {
  bool _splashVisible = true;
  bool _splashHolding = true;

  Future<void> _leaveSplash() async {
    if (!_splashHolding) return;
    setState(() => _splashHolding = false);
    // Bring up the shared media session only after the opening clip.
    final handler = await ensureAlNoorAudioService();
    if (!mounted || handler == null) return;
    context.read<IslamicAudioPlayer>().attachHandler(handler);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const HomeScreen(),
        if (_splashVisible)
          IgnorePointer(
            ignoring: !_splashHolding,
            child: AnimatedOpacity(
              opacity: _splashHolding ? 1 : 0,
              duration: const Duration(milliseconds: 500),
              onEnd: () {
                if (!_splashHolding && mounted) {
                  setState(() => _splashVisible = false);
                }
              },
              child: SplashScreen(onFinished: _leaveSplash),
            ),
          ),
      ],
    );
  }
}
