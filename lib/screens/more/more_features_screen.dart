import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/more_features_catalog.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/islamic_motif.dart';
import '../../widgets/more/feature_card.dart';
import '../achievements/achievements_screen.dart';
import '../adhkar/adhkar_screen.dart';
import '../asma/asma_library_screen.dart';
import '../dua/dua_library_screen.dart';
import '../hadith/hadith_library_screen.dart';
import '../hijri/hijri_calendar_screen.dart';
import '../journeys/journeys_screen.dart';
import '../qibla/qibla_screen.dart';
import '../quran_race/quran_race_screen.dart';
import '../quiz/islamic_quiz_home_screen.dart';
import '../nasheed/nasheed_library_screen.dart';
import '../saved/saved_library_screen.dart';
import '../tasbeeh/tasbeeh_screen.dart';
import '../worship/worship_tracker_screen.dart';

/// Central hub for additional Islamic features.
class MoreFeaturesScreen extends StatefulWidget {
  const MoreFeaturesScreen({super.key});

  @override
  State<MoreFeaturesScreen> createState() => _MoreFeaturesScreenState();
}

class _MoreFeaturesScreenState extends State<MoreFeaturesScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _open(MoreFeature feature) {
    final Widget page = switch (feature.route) {
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

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => page,
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.04, 0),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 280),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final query = _search.text;
    final grouped = MoreFeaturesCatalog.grouped(query);
    final totalMatches = grouped.values.fold<int>(
      0,
      (sum, list) => sum + list.length,
    );
    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width >= 720 ? 3 : 2;
    final childAspectRatio = width >= 720 ? 1.15 : 0.92;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: IslamicPatternPainter(
                color: scheme.onSurface.withValues(alpha: 0.03),
              ),
            ),
          ),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                pinned: true,
                floating: true,
                title: Text(context.tr('moreFeaturesTitle')),
                backgroundColor: scheme.surface.withValues(alpha: 0.92),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('moreFeaturesSubtitle'),
                        style: TextStyle(
                          height: 1.45,
                          color: scheme.onSurface.withValues(alpha: 0.68),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _search,
                        onChanged: (_) => setState(() {}),
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: context.tr('moreFeaturesSearch'),
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: query.trim().isEmpty
                              ? null
                              : IconButton(
                                  tooltip: context.tr('clearSearch'),
                                  onPressed: () {
                                    _search.clear();
                                    setState(() {});
                                  },
                                  icon: const Icon(Icons.close_rounded),
                                ),
                          filled: true,
                          fillColor: scheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: scheme.onSurface.withValues(alpha: 0.08),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: scheme.onSurface.withValues(alpha: 0.08),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (totalMatches == 0)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptySearch(
                    onClear: () {
                      _search.clear();
                      setState(() {});
                    },
                  ),
                )
              else
                ..._categorySlivers(
                  grouped,
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: childAspectRatio,
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 28)),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _categorySlivers(
    Map<MoreFeatureCategory, List<MoreFeature>> grouped, {
    required int crossAxisCount,
    required double childAspectRatio,
  }) {
    final slivers = <Widget>[];
    for (final category in MoreFeatureCategory.values) {
      final features = grouped[category] ?? const <MoreFeature>[];
      if (features.isEmpty) continue;
      final titleKey = MoreFeaturesCatalog.categoryTitleKeys[category]!;
      slivers.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
            child: Text(
              context.tr(titleKey),
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
      );
      slivers.add(
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: childAspectRatio,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final feature = features[index];
                return FeatureCard(
                  feature: feature,
                  onTap: () => _open(feature),
                );
              },
              childCount: features.length,
            ),
          ),
        ),
      );
    }
    return slivers;
  }
}

class _EmptySearch extends StatelessWidget {
  final VoidCallback onClear;

  const _EmptySearch({required this.onClear});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 52,
            color: scheme.onSurface.withValues(alpha: 0.35),
          ),
          const SizedBox(height: 14),
          Text(
            context.tr('moreFeaturesEmpty'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.tr('moreFeaturesEmptyHelp'),
            textAlign: TextAlign.center,
            style: TextStyle(
              height: 1.45,
              color: scheme.onSurface.withValues(alpha: 0.62),
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.tonal(
            onPressed: onClear,
            style: FilledButton.styleFrom(
              foregroundColor: AppTheme.primaryGreen,
            ),
            child: Text(context.tr('clearSearch')),
          ),
        ],
      ),
    );
  }
}
