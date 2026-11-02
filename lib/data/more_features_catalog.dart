import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

/// Groups shown on the More Features hub.
enum MoreFeatureCategory {
  worship,
  knowledge,
  tools,
}

/// How a hub card opens its destination.
enum MoreFeatureRoute {
  adhkar,
  tasbeeh,
  duaLibrary,
  worshipTracker,
  journeys,
  race,
  achievements,
  hadith,
  namesOfAllah,
  quiz,
  hijriCalendar,
  savedLibrary,
  nasheedLibrary,
  qibla,
}

/// One card on the More Features hub.
class MoreFeature {
  final String id;
  final MoreFeatureCategory category;
  final MoreFeatureRoute route;
  final String nameKey;
  final String descriptionKey;
  final IconData icon;
  final Color accent;
  final bool available;

  const MoreFeature({
    required this.id,
    required this.category,
    required this.route,
    required this.nameKey,
    required this.descriptionKey,
    required this.icon,
    required this.accent,
    required this.available,
  });

  bool matchesQuery(String query) {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) return true;
    final en = AppLocalizations(const Locale('en'));
    final ar = AppLocalizations(const Locale('ar'));
    final haystack = [
      en.tr(nameKey),
      ar.tr(nameKey),
      en.tr(descriptionKey),
      ar.tr(descriptionKey),
      id,
    ].join(' ').toLowerCase();
    return haystack.contains(trimmed);
  }
}

/// Catalog of hub features. Quran stays on the main tab and is not listed here.
class MoreFeaturesCatalog {
  static const categoryTitleKeys = {
    MoreFeatureCategory.worship: 'moreCatWorship',
    MoreFeatureCategory.knowledge: 'moreCatKnowledge',
    MoreFeatureCategory.tools: 'moreCatTools',
  };

  static const features = <MoreFeature>[
    MoreFeature(
      id: 'adhkar',
      category: MoreFeatureCategory.worship,
      route: MoreFeatureRoute.adhkar,
      nameKey: 'featureAdhkar',
      descriptionKey: 'featureAdhkarDesc',
      icon: Icons.auto_stories_rounded,
      accent: Color(0xFF0D7377),
      available: true,
    ),
    MoreFeature(
      id: 'tasbeeh',
      category: MoreFeatureCategory.worship,
      route: MoreFeatureRoute.tasbeeh,
      nameKey: 'featureTasbeeh',
      descriptionKey: 'featureTasbeehDesc',
      icon: Icons.fingerprint_rounded,
      accent: Color(0xFFD4AF37),
      available: true,
    ),
    MoreFeature(
      id: 'dua_library',
      category: MoreFeatureCategory.worship,
      route: MoreFeatureRoute.duaLibrary,
      nameKey: 'featureDuaLibrary',
      descriptionKey: 'featureDuaLibraryDesc',
      icon: Icons.menu_book_rounded,
      accent: Color(0xFF5B8C5A),
      available: true,
    ),
    MoreFeature(
      id: 'worship_tracker',
      category: MoreFeatureCategory.worship,
      route: MoreFeatureRoute.worshipTracker,
      nameKey: 'featureWorshipTracker',
      descriptionKey: 'featureWorshipTrackerDesc',
      icon: Icons.track_changes_rounded,
      accent: Color(0xFF6B5B95),
      available: true,
    ),
    MoreFeature(
      id: 'journeys',
      category: MoreFeatureCategory.worship,
      route: MoreFeatureRoute.journeys,
      nameKey: 'featureJourneys',
      descriptionKey: 'featureJourneysDesc',
      icon: Icons.self_improvement_rounded,
      accent: Color(0xFF45B8AC),
      available: true,
    ),
    MoreFeature(
      id: 'race',
      category: MoreFeatureCategory.worship,
      route: MoreFeatureRoute.race,
      nameKey: 'featureRace',
      descriptionKey: 'featureRaceDesc',
      icon: Icons.groups_rounded,
      accent: Color(0xFF0D7377),
      available: true,
    ),
    MoreFeature(
      id: 'achievements',
      category: MoreFeatureCategory.worship,
      route: MoreFeatureRoute.achievements,
      nameKey: 'featureAchievements',
      descriptionKey: 'featureAchievementsDesc',
      icon: Icons.emoji_events_rounded,
      accent: Color(0xFFD4AF37),
      available: true,
    ),
    MoreFeature(
      id: 'hadith',
      category: MoreFeatureCategory.knowledge,
      route: MoreFeatureRoute.hadith,
      nameKey: 'featureHadith',
      descriptionKey: 'featureHadithDesc',
      icon: Icons.history_edu_rounded,
      accent: Color(0xFF8B6F47),
      available: true,
    ),
    MoreFeature(
      id: 'names_of_allah',
      category: MoreFeatureCategory.knowledge,
      route: MoreFeatureRoute.namesOfAllah,
      nameKey: 'featureNamesOfAllah',
      descriptionKey: 'featureNamesOfAllahDesc',
      icon: Icons.brightness_5_rounded,
      accent: Color(0xFFC9A227),
      available: true,
    ),
    MoreFeature(
      id: 'quiz',
      category: MoreFeatureCategory.knowledge,
      route: MoreFeatureRoute.quiz,
      nameKey: 'featureQuiz',
      descriptionKey: 'featureQuizDesc',
      icon: Icons.quiz_rounded,
      accent: Color(0xFF3D7EA6),
      available: true,
    ),
    MoreFeature(
      id: 'hijri_calendar',
      category: MoreFeatureCategory.tools,
      route: MoreFeatureRoute.hijriCalendar,
      nameKey: 'featureHijri',
      descriptionKey: 'featureHijriDesc',
      icon: Icons.calendar_month_rounded,
      accent: Color(0xFF0D7377),
      available: true,
    ),
    MoreFeature(
      id: 'saved_library',
      category: MoreFeatureCategory.tools,
      route: MoreFeatureRoute.savedLibrary,
      nameKey: 'featureSavedLibrary',
      descriptionKey: 'featureSavedLibraryDesc',
      icon: Icons.bookmarks_rounded,
      accent: Color(0xFFB42318),
      available: true,
    ),
    MoreFeature(
      id: 'nasheed_library',
      category: MoreFeatureCategory.knowledge,
      route: MoreFeatureRoute.nasheedLibrary,
      nameKey: 'featureNasheedLibrary',
      descriptionKey: 'featureNasheedLibraryDesc',
      icon: Icons.library_music_rounded,
      accent: Color(0xFF0D7377),
      available: true,
    ),
    MoreFeature(
      id: 'qibla',
      category: MoreFeatureCategory.tools,
      route: MoreFeatureRoute.qibla,
      nameKey: 'featureQibla',
      descriptionKey: 'featureQiblaDesc',
      icon: Icons.explore_rounded,
      accent: Color(0xFF14A3A8),
      available: true,
    ),
  ];

  static List<MoreFeature> search(String query) {
    return features.where((feature) => feature.matchesQuery(query)).toList();
  }

  static Map<MoreFeatureCategory, List<MoreFeature>> grouped(String query) {
    final matched = search(query);
    return {
      for (final category in MoreFeatureCategory.values)
        category: matched
            .where((feature) => feature.category == category)
            .toList(),
    };
  }
}
