import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/active_journey.dart';
import '../../models/spiritual_journey.dart';
import '../../providers/app_settings_provider.dart';
import '../../providers/spiritual_journey_provider.dart';
import '../../widgets/islamic_motif.dart';
import 'journey_intro_screen.dart';
import 'journey_selection_screen.dart';
import 'spiritual_journey_detail_screen.dart';

/// Journeys hub: one-time welcome, then spiritual plans beside recovery.
class JourneysScreen extends StatelessWidget {
  const JourneysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    if (!settings.isLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!settings.journeyIntroSeen) {
      return JourneyIntroScreen(
        onStart: () => settings.setJourneyIntroSeen(true),
        onSkip: () => settings.setJourneyIntroSeen(true),
      );
    }
    return const _JourneyHub();
  }
}

class _JourneyHub extends StatelessWidget {
  const _JourneyHub();

  void _openDetail(BuildContext context, String journeyId) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            SpiritualJourneyDetailScreen(journeyId: journeyId),
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
    final english = !context.isArabic;
    final provider = context.watch<SpiritualJourneyProvider>();
    final settings = context.read<AppSettingsProvider>();
    final scheme = Theme.of(context).colorScheme;
    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width >= 720 ? 2 : 1;

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
                title: Text(context.tr('journeysTitle')),
                actions: [
                  IconButton(
                    tooltip: context.tr('replayIntro'),
                    onPressed: () async {
                      await settings.setJourneyIntroSeen(false);
                    },
                    icon: const Icon(Icons.auto_stories_outlined),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('spiritualJourneys'),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.tr('journeyLibraryHelp'),
                        style: TextStyle(
                          height: 1.45,
                          color: scheme.onSurface.withValues(alpha: 0.68),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.tr('journeyDisclaimer'),
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.4,
                          color: scheme.onSurface.withValues(alpha: 0.55),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (provider.activeJourneys.isNotEmpty)
                ..._section(
                  context,
                  title: context.tr('activeJourneys'),
                  journeys: provider.activeJourneys,
                  provider: provider,
                  english: english,
                  crossAxisCount: crossAxisCount,
                  onOpen: (id) => _openDetail(context, id),
                ),
              if (provider.pausedJourneys.isNotEmpty)
                ..._section(
                  context,
                  title: context.tr('statusPaused'),
                  journeys: provider.pausedJourneys,
                  provider: provider,
                  english: english,
                  crossAxisCount: crossAxisCount,
                  onOpen: (id) => _openDetail(context, id),
                ),
              if (provider.completedJourneys.isNotEmpty)
                ..._section(
                  context,
                  title: context.tr('completedJourneys'),
                  journeys: provider.completedJourneys,
                  provider: provider,
                  english: english,
                  crossAxisCount: crossAxisCount,
                  onOpen: (id) => _openDetail(context, id),
                ),
              ..._section(
                context,
                title: context.tr('availableJourneys'),
                journeys: provider.availableJourneys,
                provider: provider,
                english: english,
                crossAxisCount: crossAxisCount,
                onOpen: (id) => _openDetail(context, id),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('recoveryJourneys'),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(context.tr('recoveryJourneysHelp')),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) =>
                                  const JourneySelectionScreen(),
                              transitionsBuilder: (_, animation, __, child) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                        icon: const Icon(Icons.self_improvement_rounded),
                        label: Text(context.tr('openRecovery')),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _section(
    BuildContext context, {
    required String title,
    required List<SpiritualJourney> journeys,
    required SpiritualJourneyProvider provider,
    required bool english,
    required int crossAxisCount,
    required ValueChanged<String> onOpen,
  }) {
    if (journeys.isEmpty) return const [];
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: crossAxisCount == 1 ? 2.2 : 1.35,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final journey = journeys[index];
              return _JourneyCard(
                journey: journey,
                english: english,
                progress: provider.progressFor(journey.id),
                ratio: provider.ratio(journey.id),
                onTap: () => onOpen(journey.id),
              );
            },
            childCount: journeys.length,
          ),
        ),
      ),
    ];
  }
}

class _JourneyCard extends StatelessWidget {
  final SpiritualJourney journey;
  final bool english;
  final SpiritualJourneyProgress? progress;
  final double ratio;
  final VoidCallback onTap;

  const _JourneyCard({
    required this.journey,
    required this.english,
    required this.progress,
    required this.ratio,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    String? status;
    if (progress != null) {
      status = switch (progress!.status) {
        JourneyStatus.active => context.tr('statusActive'),
        JourneyStatus.paused => context.tr('statusPaused'),
        JourneyStatus.completed => context.tr('statusCompleted'),
        JourneyStatus.abandoned => context.tr('statusAbandoned'),
      };
    }

    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppTheme.accentGold.withValues(alpha: 0.18),
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryGreen.withValues(alpha: 0.08),
                scheme.surface,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(journey.icon, style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        journey.title(english),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (status != null)
                      Text(
                        status,
                        style: const TextStyle(
                          color: AppTheme.accentGold,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  journey.description(english),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    height: 1.35,
                    color: scheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const Spacer(),
                Text(
                  '${journey.durationDays} ${context.tr('durationDays')}',
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
                if (progress != null) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: ratio,
                      minHeight: 6,
                      color: AppTheme.primaryGreen,
                      backgroundColor:
                          scheme.onSurface.withValues(alpha: 0.08),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
