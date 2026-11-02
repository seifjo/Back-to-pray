import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/worship_tracker.dart';
import '../../providers/worship_tracker_provider.dart';
import '../../widgets/islamic_motif.dart';
import '../adhkar/adhkar_screen.dart';
import '../quran/quran_screen.dart';
import '../tasbeeh/tasbeeh_screen.dart';
import 'worship_activity_editor_screen.dart';
import 'worship_history_screen.dart';

class WorshipTrackerScreen extends StatefulWidget {
  const WorshipTrackerScreen({super.key});

  @override
  State<WorshipTrackerScreen> createState() => _WorshipTrackerScreenState();
}

class _WorshipTrackerScreenState extends State<WorshipTrackerScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<WorshipTrackerProvider>();
      if (provider.loading) {
        provider.initialize();
      } else {
        provider.onDayBoundaryCheck();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<WorshipTrackerProvider>().onDayBoundaryCheck();
    }
  }

  void _openEditor({WorshipActivity? activity}) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            WorshipActivityEditorScreen(activityId: activity?.id),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 240),
      ),
    );
  }

  void _openHistory() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const WorshipHistoryScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 240),
      ),
    );
  }

  void _openShortcut(String? shortcut) {
    if (shortcut == null) return;
    final Widget page = switch (shortcut) {
      'quran' => const QuranScreen(),
      'adhkar' => const AdhkarScreen(),
      'tasbeeh' => const TasbeehScreen(),
      _ => const SizedBox.shrink(),
    };
    if (page is SizedBox) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorshipTrackerProvider>();
    final scheme = Theme.of(context).colorScheme;
    final english = !context.isArabic;
    final items = provider.dashboardActivities;
    final paused = provider.pausedActivities;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        icon: const Icon(Icons.add_rounded),
        label: Text(context.tr('wtAddActivity')),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: IslamicPatternPainter(
                color: scheme.onSurface.withValues(alpha: 0.03),
              ),
            ),
          ),
          RefreshIndicator(
            onRefresh: () async {
              provider.onDayBoundaryCheck();
              await provider.initialize();
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                SliverAppBar(
                  pinned: true,
                  title: Text(context.tr('wtTitle')),
                  actions: [
                    IconButton(
                      tooltip: context.tr('wtHistory'),
                      onPressed: _openHistory,
                      icon: const Icon(Icons.insights_rounded),
                    ),
                  ],
                ),
                if (provider.loading)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (provider.error != null)
                  SliverFillRemaining(
                    child: Center(child: Text(context.tr('wtLoadError'))),
                  )
                else ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('wtSubtitle'),
                            style: TextStyle(
                              height: 1.45,
                              color: scheme.onSurface.withValues(alpha: 0.68),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            context.tr('wtExplicitNote'),
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.4,
                              color: scheme.onSurface.withValues(alpha: 0.55),
                            ),
                          ),
                          const SizedBox(height: 14),
                          _ProgressHeader(
                            completed: provider.todayCompletedCount,
                            total: provider.todayTotalCount,
                            progress: provider.todayProgress,
                            dateLabel: _formatDate(
                              provider.selectedDate,
                              english,
                            ),
                            onToday: provider.goToToday,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (items.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.self_improvement_rounded,
                              size: 48,
                              color: scheme.onSurface.withValues(alpha: 0.35),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              context.tr('wtEmpty'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              context.tr('wtEmptyHelp'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color:
                                    scheme.onSurface.withValues(alpha: 0.65),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      sliver: SliverList.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final activity = items[index];
                          final done = provider.isCompleted(activity);
                          return _ActivityTile(
                            activity: activity,
                            english: english,
                            completed: done,
                            onToggle: () =>
                                provider.toggleCompleted(activity.id),
                            onEdit: () => _openEditor(activity: activity),
                            onShortcut: () =>
                                _openShortcut(activity.shortcut),
                          );
                        },
                      ),
                    ),
                  if (paused.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.tr('wtPaused'),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...paused.map(
                              (activity) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(activity.title(english)),
                                subtitle: Text(context.tr('wtPausedHint')),
                                trailing: TextButton(
                                  onPressed: () =>
                                      provider.setPaused(activity.id, false),
                                  child: Text(context.tr('wtResume')),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 100),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date, bool english) {
    final monthsEn = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    if (english) {
      return '${monthsEn[date.month - 1]} ${date.day}, ${date.year}';
    }
    return '${date.year}/${date.month}/${date.day}';
  }
}

class _ProgressHeader extends StatelessWidget {
  final int completed;
  final int total;
  final double progress;
  final String dateLabel;
  final VoidCallback onToday;

  const _ProgressHeader({
    required this.completed,
    required this.total,
    required this.progress,
    required this.dateLabel,
    required this.onToday,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final message = total == 0
        ? context.tr('wtEncourageEmpty')
        : completed == total
            ? context.tr('wtEncourageDone')
            : context.tr('wtEncouragePartial');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryGreen.withValues(alpha: 0.14),
            scheme.surface,
          ],
        ),
        border: Border.all(
          color: AppTheme.primaryGreen.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  dateLabel,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              TextButton(
                onPressed: onToday,
                child: Text(context.tr('wtToday')),
              ),
            ],
          ),
          Text(
            context
                .tr('wtDailyProgress')
                .replaceAll('{done}', '$completed')
                .replaceAll('{total}', '$total'),
            style: TextStyle(
              color: scheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: scheme.onSurface.withValues(alpha: 0.08),
              color: AppTheme.primaryGreen,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: TextStyle(
              height: 1.4,
              color: scheme.onSurface.withValues(alpha: 0.72),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final WorshipActivity activity;
  final bool english;
  final bool completed;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onShortcut;

  const _ActivityTile({
    required this.activity,
    required this.english,
    required this.completed,
    required this.onToggle,
    required this.onEdit,
    required this.onShortcut,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final natureLabel = activity.isObligation
        ? context.tr('wtNatureObligation')
        : context.tr('wtNaturePersonal');

    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onToggle,
        onLongPress: onEdit,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Checkbox(
                value: completed,
                onChanged: (_) => onToggle(),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title(english),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        decoration:
                            completed ? TextDecoration.lineThrough : null,
                        color: completed
                            ? scheme.onSurface.withValues(alpha: 0.55)
                            : scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      natureLabel,
                      style: TextStyle(
                        fontSize: 12,
                        color: activity.isObligation
                            ? AppTheme.accentGold
                            : scheme.onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                    if (activity.note(english) != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        activity.note(english)!,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.35,
                          color: scheme.onSurface.withValues(alpha: 0.58),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (activity.shortcut != null)
                IconButton(
                  tooltip: context.tr('wtOpenLinked'),
                  onPressed: onShortcut,
                  icon: const Icon(Icons.open_in_new_rounded),
                ),
              IconButton(
                tooltip: context.tr('wtEdit'),
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
