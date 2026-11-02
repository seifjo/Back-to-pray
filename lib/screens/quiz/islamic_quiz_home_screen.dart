import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../data/islamic_quiz_catalog.dart';
import '../../l10n/app_localizations.dart';
import '../../models/islamic_quiz.dart';
import '../../providers/islamic_quiz_provider.dart';
import '../../widgets/islamic_motif.dart';
import 'islamic_quiz_play_screen.dart';
import 'islamic_quiz_results_screen.dart';

class IslamicQuizHomeScreen extends StatefulWidget {
  const IslamicQuizHomeScreen({super.key});

  @override
  State<IslamicQuizHomeScreen> createState() => _IslamicQuizHomeScreenState();
}

class _IslamicQuizHomeScreenState extends State<IslamicQuizHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<IslamicQuizProvider>();
      if (provider.loading) {
        provider.initialize();
      } else if (provider.session?.isComplete == true) {
        provider.resumeOrDiscardCompleted();
      }
    });
  }

  Future<void> _openPlay() async {
    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const IslamicQuizPlayScreen(),
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
    if (!mounted) return;
    final provider = context.read<IslamicQuizProvider>();
    if (provider.session?.isComplete == true) {
      await Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const IslamicQuizResultsScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 260),
        ),
      );
    }
  }

  Future<void> _startTopic(QuizTopic topic) async {
    final provider = context.read<IslamicQuizProvider>();
    final ok = await provider.startTopicQuiz(topic);
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('quizNoQuestions'))),
      );
      return;
    }
    await _openPlay();
  }

  Future<void> _startRetry() async {
    final provider = context.read<IslamicQuizProvider>();
    final ok = await provider.startRetryIncorrect();
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('quizNoIncorrect'))),
      );
      return;
    }
    await _openPlay();
  }

  Future<void> _startRevision() async {
    final provider = context.read<IslamicQuizProvider>();
    final ok = await provider.startRevision();
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('quizNoRevision'))),
      );
      return;
    }
    await _openPlay();
  }

  Future<void> _continueSession() async {
    final provider = context.read<IslamicQuizProvider>();
    if (provider.session == null) return;
    if (provider.session!.isComplete) {
      await Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const IslamicQuizResultsScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 260),
        ),
      );
      return;
    }
    await _openPlay();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IslamicQuizProvider>();
    final scheme = Theme.of(context).colorScheme;
    final english = !context.isArabic;
    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width >= 720 ? 3 : 2;

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
          if (provider.loading)
            const Center(child: CircularProgressIndicator())
          else if (provider.error != null)
            Center(child: Text(context.tr('quizLoadError')))
          else
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  pinned: true,
                  title: Text(context.tr('quizTitle')),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('quizSubtitle'),
                          style: TextStyle(
                            height: 1.45,
                            color: scheme.onSurface.withValues(alpha: 0.68),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _DifficultySelector(
                          value: provider.selectedDifficulty,
                          onChanged: provider.setDifficulty,
                        ),
                        const SizedBox(height: 12),
                        _ProgressBanner(provider: provider),
                        if (provider.hasActiveIncompleteSession) ...[
                          const SizedBox(height: 12),
                          _ActionCard(
                            icon: Icons.play_circle_outline_rounded,
                            title: context.tr('quizContinue'),
                            subtitle: context.tr('quizContinueHelp'),
                            accent: AppTheme.primaryGreen,
                            onTap: _continueSession,
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _SmallAction(
                                icon: Icons.refresh_rounded,
                                label: context.tr('quizRetryIncorrect'),
                                enabled: provider.canRetryIncorrect,
                                onTap: _startRetry,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _SmallAction(
                                icon: Icons.menu_book_rounded,
                                label: context.tr('quizRevisionMode'),
                                enabled: provider.canRevise,
                                onTap: _startRevision,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          context.tr('quizTopics'),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.tr('quizTopicsHelp'),
                          style: TextStyle(
                            height: 1.4,
                            color: scheme.onSurface.withValues(alpha: 0.62),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: width >= 720 ? 1.15 : 0.95,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final info = provider.topics[index];
                        final count = provider.questionCountFor(
                          info.topic,
                          provider.selectedDifficulty,
                        );
                        return _TopicCard(
                          info: info,
                          count: count,
                          onTap: count > 0
                              ? () => _startTopic(info.topic)
                              : null,
                        );
                      },
                      childCount: provider.topics.length,
                    ),
                  ),
                ),
                if (provider.history.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('quizHistory'),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          ...provider.history.take(5).map(
                                (entry) => _HistoryTile(entry: entry),
                              ),
                        ],
                      ),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    child: Text(
                      english
                          ? provider.attributionEn
                          : provider.attributionAr,
                      style: TextStyle(
                        height: 1.45,
                        fontSize: 12.5,
                        color: scheme.onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _DifficultySelector extends StatelessWidget {
  const _DifficultySelector({
    required this.value,
    required this.onChanged,
  });

  final QuizDifficulty value;
  final ValueChanged<QuizDifficulty> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('quizDifficulty'),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: QuizDifficulty.values.map((level) {
            final selected = level == value;
            final label = switch (level) {
              QuizDifficulty.beginner => context.tr('quizDifficultyBeginner'),
              QuizDifficulty.intermediate =>
                context.tr('quizDifficultyIntermediate'),
              QuizDifficulty.advanced => context.tr('quizDifficultyAdvanced'),
            };
            return ChoiceChip(
              label: Text(label),
              selected: selected,
              onSelected: (_) => onChanged(level),
              selectedColor: AppTheme.primaryGreen.withValues(alpha: 0.22),
              labelStyle: TextStyle(
                color: selected
                    ? AppTheme.primaryGreen
                    : scheme.onSurface.withValues(alpha: 0.75),
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ProgressBanner extends StatelessWidget {
  const _ProgressBanner({
    required this.provider,
  });

  final IslamicQuizProvider provider;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final score = context.tr('quizLifetimeScore')
        .replaceAll('{correct}', '${provider.lifetimeCorrect}')
        .replaceAll('{total}', '${provider.lifetimeAnswered}');
    final topics = provider.topicsReviewed.length;
    final topicsLabel = context
        .tr('quizTopicsReviewed')
        .replaceAll('{count}', '$topics');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryGreen.withValues(alpha: 0.14),
            AppTheme.accentGold.withValues(alpha: 0.10),
          ],
        ),
        border: Border.all(
          color: scheme.outline.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('quizPersonalProgress'),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(score, style: TextStyle(height: 1.4, color: scheme.onSurface)),
          const SizedBox(height: 2),
          Text(
            topicsLabel,
            style: TextStyle(
              height: 1.4,
              color: scheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            context.tr('quizNoLeaderboard'),
            style: TextStyle(
              fontSize: 12,
              height: 1.35,
              color: scheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accent.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              Icon(icon, color: accent, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text(
                      subtitle,
                      style: TextStyle(
                        height: 1.35,
                        color: scheme.onSurface.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: accent),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallAction extends StatelessWidget {
  const _SmallAction({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: enabled ? onTap : null,
        child: Opacity(
          opacity: enabled ? 1 : 0.45,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: scheme.outline.withValues(alpha: 0.16),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: AppTheme.primaryGreen),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({
    required this.info,
    required this.count,
    required this.onTap,
  });

  final QuizTopicInfo info;
  final int count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = Color(info.accent);
    final countLabel = context
        .tr('quizQuestionCount')
        .replaceAll('{count}', '$count');

    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: accent.withValues(alpha: 0.28)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accent.withValues(alpha: 0.12),
                scheme.surface,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.quiz_rounded, color: accent, size: 20),
                ),
                const Spacer(),
                Text(
                  context.tr(info.nameKey),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15.5,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  context.tr(info.descriptionKey),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    height: 1.35,
                    fontSize: 12.5,
                    color: scheme.onSurface.withValues(alpha: 0.68),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  countLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: accent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.entry,
  });

  final QuizHistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final topicLabel = entry.topic == null
        ? context.tr(entry.mode == QuizPlayMode.revision
            ? 'quizRevisionMode'
            : 'quizRetryIncorrect')
        : context.tr(_topicKey(entry.topic!));
    final score = context
        .tr('quizSessionScore')
        .replaceAll('{correct}', '${entry.correct}')
        .replaceAll('{total}', '${entry.total}');

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: scheme.surface,
          border: Border.all(color: scheme.outline.withValues(alpha: 0.12)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                topicLabel,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              score,
              style: TextStyle(
                color: scheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _topicKey(QuizTopic topic) {
    return switch (topic) {
      QuizTopic.quran => 'quizTopicQuran',
      QuizTopic.hadith => 'quizTopicHadith',
      QuizTopic.seerah => 'quizTopicSeerah',
      QuizTopic.prophets => 'quizTopicProphets',
      QuizTopic.history => 'quizTopicHistory',
      QuizTopic.general => 'quizTopicGeneral',
    };
  }
}
