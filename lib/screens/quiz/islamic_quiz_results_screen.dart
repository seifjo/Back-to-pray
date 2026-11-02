import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../data/islamic_quiz_catalog.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/islamic_quiz_provider.dart';
import '../../widgets/islamic_motif.dart';
import 'islamic_quiz_play_screen.dart';

class IslamicQuizResultsScreen extends StatelessWidget {
  const IslamicQuizResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IslamicQuizProvider>();
    final session = provider.session;
    final scheme = Theme.of(context).colorScheme;
    final english = !context.isArabic;

    if (session == null || !session.isComplete) {
      return Scaffold(
        appBar: AppBar(title: Text(context.tr('quizResults'))),
        body: Center(child: Text(context.tr('quizNoActiveSession'))),
      );
    }

    final scoreLabel = context
        .tr('quizSessionScore')
        .replaceAll('{correct}', '${session.correctCount}')
        .replaceAll('{total}', '${session.total}');
    final ratio =
        session.total == 0 ? 0.0 : session.correctCount / session.total;
    final incorrectAnswers =
        session.answers.where((a) => !a.correct).toList();

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
                title: Text(context.tr('quizResults')),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryGreen.withValues(alpha: 0.16),
                              AppTheme.accentGold.withValues(alpha: 0.12),
                            ],
                          ),
                          border: Border.all(
                            color: AppTheme.primaryGreen.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              scoreLabel,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: LinearProgressIndicator(
                                value: ratio,
                                minHeight: 10,
                                backgroundColor:
                                    scheme.onSurface.withValues(alpha: 0.08),
                                color: AppTheme.primaryGreen,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              context.tr('quizResultsHelp'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                height: 1.4,
                                color:
                                    scheme.onSurface.withValues(alpha: 0.68),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (incorrectAnswers.isNotEmpty) ...[
                        Text(
                          context.tr('quizReviewIncorrect'),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        ...incorrectAnswers.map((answer) {
                          final q = IslamicQuizCatalog.byId(answer.questionId);
                          if (q == null) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: scheme.surface,
                                border: Border.all(
                                  color:
                                      scheme.outline.withValues(alpha: 0.14),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    q.prompt(english),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      height: 1.35,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    q.explanation(english),
                                    style: TextStyle(
                                      height: 1.4,
                                      color: scheme.onSurface
                                          .withValues(alpha: 0.72),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    q.source(english),
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      height: 1.35,
                                      color: scheme.onSurface
                                          .withValues(alpha: 0.55),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 8),
                      ],
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: incorrectAnswers.isEmpty
                              ? null
                              : () async {
                                  final ok =
                                      await provider.startRetryIncorrect();
                                  if (!context.mounted || !ok) return;
                                  await Navigator.of(context).pushReplacement(
                                    PageRouteBuilder(
                                      pageBuilder: (_, __, ___) =>
                                          const IslamicQuizPlayScreen(),
                                      transitionsBuilder:
                                          (_, animation, __, child) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        );
                                      },
                                      transitionDuration:
                                          const Duration(milliseconds: 260),
                                    ),
                                  );
                                },
                          icon: const Icon(Icons.refresh_rounded),
                          label: Text(context.tr('quizRetryIncorrect')),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.primaryGreen,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await provider.clearActiveSession();
                            if (!context.mounted) return;
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.home_rounded),
                          label: Text(context.tr('quizBackHome')),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
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
}
