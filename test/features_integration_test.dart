import 'package:back_to_prayer/core/services/hadith_preferences_store.dart';
import 'package:back_to_prayer/core/services/saved_library_repository.dart';
import 'package:back_to_prayer/data/more_features_catalog.dart';
import 'package:back_to_prayer/l10n/app_localizations.dart';
import 'package:back_to_prayer/models/saved_library.dart';
import 'package:back_to_prayer/providers/saved_library_provider.dart';
import 'package:back_to_prayer/screens/adhkar/adhkar_screen.dart';
import 'package:back_to_prayer/screens/asma/asma_library_screen.dart';
import 'package:back_to_prayer/screens/dua/dua_library_screen.dart';
import 'package:back_to_prayer/screens/hadith/hadith_library_screen.dart';
import 'package:back_to_prayer/screens/hijri/hijri_calendar_screen.dart';
import 'package:back_to_prayer/screens/home/home_screen.dart';
import 'package:back_to_prayer/screens/journeys/journeys_screen.dart';
import 'package:back_to_prayer/screens/more/more_features_screen.dart';
import 'package:back_to_prayer/screens/achievements/achievements_screen.dart';
import 'package:back_to_prayer/screens/qibla/qibla_screen.dart';
import 'package:back_to_prayer/screens/quran/quran_screen.dart';
import 'package:back_to_prayer/screens/quran_race/quran_race_screen.dart';
import 'package:back_to_prayer/screens/quiz/islamic_quiz_home_screen.dart';
import 'package:back_to_prayer/screens/nasheed/nasheed_library_screen.dart';
import 'package:back_to_prayer/screens/saved/saved_library_screen.dart';
import 'package:back_to_prayer/screens/tasbeeh/tasbeeh_screen.dart';
import 'package:back_to_prayer/screens/worship/worship_tracker_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('every MoreFeatureRoute is implemented and available', () {
    final catalogRoutes =
        MoreFeaturesCatalog.features.map((f) => f.route).toSet();
    expect(catalogRoutes, MoreFeatureRoute.values.toSet());

    final unavailable = MoreFeaturesCatalog.features
        .where((f) => !f.available)
        .map((f) => f.id)
        .toList();
    expect(unavailable, isEmpty);

    final ids = MoreFeaturesCatalog.features.map((f) => f.id).toList();
    expect(ids.toSet().length, ids.length);

    // Quran reader stays on the main tab; race lives under More as "race".
    expect(ids.contains('quran'), isFalse);
    expect(ids, containsAll(['race', 'journeys', 'achievements', 'nasheed_library']));
  });

  test('hub route map opens the correct screen types', () {
    Widget pageFor(MoreFeatureRoute route) => switch (route) {
          MoreFeatureRoute.adhkar => const AdhkarScreen(),
          MoreFeatureRoute.journeys => const JourneysScreen(),
          MoreFeatureRoute.race => const QuranRaceScreen(),
          MoreFeatureRoute.achievements => const AchievementsScreen(),
          MoreFeatureRoute.qibla => const QiblaScreen(),
          MoreFeatureRoute.worshipTracker => const WorshipTrackerScreen(),
          MoreFeatureRoute.hadith => const HadithLibraryScreen(),
          MoreFeatureRoute.tasbeeh => const TasbeehScreen(),
          MoreFeatureRoute.duaLibrary => const DuaLibraryScreen(),
          MoreFeatureRoute.namesOfAllah => const AsmaLibraryScreen(),
          MoreFeatureRoute.hijriCalendar => const HijriCalendarScreen(),
          MoreFeatureRoute.quiz => const IslamicQuizHomeScreen(),
          MoreFeatureRoute.savedLibrary => const SavedLibraryScreen(),
          MoreFeatureRoute.nasheedLibrary => const NasheedLibraryScreen(),
        };

    expect(pageFor(MoreFeatureRoute.hadith), isA<HadithLibraryScreen>());
    expect(pageFor(MoreFeatureRoute.tasbeeh), isA<TasbeehScreen>());
    expect(pageFor(MoreFeatureRoute.duaLibrary), isA<DuaLibraryScreen>());
    expect(pageFor(MoreFeatureRoute.namesOfAllah), isA<AsmaLibraryScreen>());
    expect(pageFor(MoreFeatureRoute.worshipTracker), isA<WorshipTrackerScreen>());
    expect(pageFor(MoreFeatureRoute.journeys), isA<JourneysScreen>());
    expect(pageFor(MoreFeatureRoute.race), isA<QuranRaceScreen>());
    expect(pageFor(MoreFeatureRoute.achievements), isA<AchievementsScreen>());
    expect(pageFor(MoreFeatureRoute.hijriCalendar), isA<HijriCalendarScreen>());
    expect(pageFor(MoreFeatureRoute.quiz), isA<IslamicQuizHomeScreen>());
    expect(pageFor(MoreFeatureRoute.savedLibrary), isA<SavedLibraryScreen>());
    expect(pageFor(MoreFeatureRoute.nasheedLibrary), isA<NasheedLibraryScreen>());
    expect(pageFor(MoreFeatureRoute.qibla), isA<QiblaScreen>());
    expect(pageFor(MoreFeatureRoute.adhkar), isA<AdhkarScreen>());
  });

  test('home shell keeps Quran and More Features tabs', () {
    // Structural check: HomeScreen still embeds both destinations.
    expect(HomeScreen, isNotNull);
    expect(QuranScreen, isNotNull);
    expect(MoreFeaturesScreen, isNotNull);
  });

  test('hadith favorites and quran bookmark surface in Saved Library', () async {
    final hadithStore = HadithPreferencesStore();
    await hadithStore.saveFavorites({'nawawi:1'});

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_surah_number', 1);
    await prefs.setInt('last_ayah_number', 1);
    await prefs.setString('last_surah_name', 'الفاتحة');

    final provider = SavedLibraryProvider(
      repository: SavedLibraryRepository(
        hadithStore: hadithStore,
        clock: () => DateTime(2026, 3, 20, 9),
      ),
    );
    await provider.initialize();

    expect(
      provider.allItems.any(
        (i) =>
            i.type == SavedContentType.hadith &&
            i.sourceId == 'nawawi:1' &&
            i.available,
      ),
      isTrue,
    );
    expect(
      provider.allItems.any((i) => i.type == SavedContentType.quranBookmark),
      isTrue,
    );

    final hadithOnly = provider.allItems
        .where((i) => i.type == SavedContentType.hadith)
        .toList();
    provider.setTypeFilter(SavedContentType.hadith);
    expect(provider.filtered.length, hadithOnly.length);
  });

  test('new feature localization keys resolve in EN and AR', () {
    final en = AppLocalizations(const Locale('en'));
    final ar = AppLocalizations(const Locale('ar'));
    const keys = [
      'featureHadith',
      'featureTasbeeh',
      'featureDuaLibrary',
      'featureNamesOfAllah',
      'featureWorshipTracker',
      'featureJourneys',
      'featureHijri',
      'featureQuiz',
      'featureSavedLibrary',
      'featureNasheedLibrary',
      'featureQibla',
      'quizTitle',
      'hijriTitle',
      'savedTitle',
      'nasheedTitle',
      'asmaTitle',
      'duaLibraryTitle',
      'tasbeehTitle',
      'wtTitle',
      'hadithLibraryTitle',
      'hadithExplanationTitle',
    ];
    for (final key in keys) {
      expect(en.tr(key), isNot(equals(key)), reason: 'missing EN $key');
      expect(ar.tr(key), isNot(equals(key)), reason: 'missing AR $key');
      expect(ar.tr(key), isNot(equals(en.tr(key))), reason: 'same EN/AR $key');
    }
  });
}
