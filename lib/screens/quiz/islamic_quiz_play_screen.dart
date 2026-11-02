import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/islamic_quiz.dart';
import '../../providers/islamic_quiz_provider.dart';
import '../../widgets/islamic_motif.dart';

class IslamicQuizPlayScreen extends StatefulWidget {
  const IslamicQuizPlayScreen({super.key});

  @override
  State<IslamicQuizPlayScreen> createState() => _IslamicQuizPlayScreenState();
}

class _IslamicQuizPlayScreenState extends State<IslamicQuizPlayScreen> {
  bool _popScheduled = false;

  void _popWhenComplete() {
    if (_popScheduled || !mounted) return;
    _popScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IslamicQuizProvider>();
    final session = provider.session;
    final question = provider.currentQuestion;
    final scheme = Theme.of(context).colorScheme;
    final english = !context.isArabic;

    if (session == null) {
      return Scaffold(
        appBar: AppBar(title: Text(context.tr('quizTitle'))),
        body: Center(child: Text(context.tr('quizNoActiveSession'))),
      );
    }

    if (session.isComplete || question == null) {
      _popWhenComplete();
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final progressLabel = context
        .tr('quizProgress')
        .replaceAll('{current}', '${session.cursor + 1}')
        .replaceAll('{total}', '${session.total}');
    final progress = (session.cursor + (provider.revealed ? 1 : 0)) /
        session.total.clamp(1, 9999);
    final options = question.options(english);
    final modeLabel = switch (session.mode) {
      QuizPlayMode.practice => context.tr('quizModePractice'),
      QuizPlayMode.retryIncorrect => context.tr('quizRetryIncorrect'),
      QuizPlayMode.revision => context.tr('quizRevisionMode'),
    };

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
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                        tooltip: context.tr('close'),
                      ),
                      Expanded(
                        child: Text(
                          modeLabel,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        progressLabel,
                        style: TextStyle(
                          color: scheme.onSurface.withValues(alpha: 0.65),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          minHeight: 8,
                          backgroundColor:
                              scheme.onSurface.withValues(alpha: 0.08),
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.04, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: _QuestionBody(
                      key: ValueKey(question.id),
                      question: question,
                      options: options,
                      english: english,
                      selected: provider.pendingSelection,
                      revealed: provider.revealed,
                      onSelect: provider.selectOption,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: provider.revealed
                          ? () async {
                              final nav = Navigator.of(context);
                              await provider.nextQuestion();
                              if (!mounted) return;
                              if (provider.session?.isComplete == true) {
                                nav.pop();
                              }
                            }
                          : (provider.pendingSelection == null
                              ? null
                              : () => provider.submitAnswer()),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        provider.revealed
                            ? (session.cursor + 1 >= session.total
                                ? context.tr('quizSeeResults')
                                : context.tr('next'))
                            : context.tr('quizSubmitAnswer'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionBody extends StatelessWidget {
  const _QuestionBody({
    super.key,
    required this.question,
    required this.options,
    required this.english,
    required this.selected,
    required this.revealed,
    required this.onSelect,
  });

  final QuizQuestion question;
  final List<String> options;
  final bool english;
  final int? selected;
  final bool revealed;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final correct = question.correctIndex;
    final caution = question.caution(english);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: scheme.surface,
            border: Border.all(color: scheme.outline.withValues(alpha: 0.12)),
          ),
          child: Text(
            question.prompt(english),
            style: TextStyle(
              fontSize: english ? 18 : 19,
              height: 1.45,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(options.length, (index) {
          final isSelected = selected == index;
          final isCorrect = index == correct;
          Color border;
          Color fill;
          Color? iconColor;
          IconData? trailing;

          if (!revealed) {
            border = isSelected
                ? AppTheme.primaryGreen
                : scheme.outline.withValues(alpha: 0.18);
            fill = isSelected
                ? AppTheme.primaryGreen.withValues(alpha: 0.12)
                : scheme.surface;
          } else if (isCorrect) {
            border = const Color(0xFF2E7D32);
            fill = const Color(0xFF2E7D32).withValues(alpha: 0.12);
            trailing = Icons.check_circle_rounded;
            iconColor = const Color(0xFF2E7D32);
          } else if (isSelected && !isCorrect) {
            border = const Color(0xFFB42318);
            fill = const Color(0xFFB42318).withValues(alpha: 0.10);
            trailing = Icons.cancel_rounded;
            iconColor = const Color(0xFFB42318);
          } else {
            border = scheme.outline.withValues(alpha: 0.12);
            fill = scheme.surface.withValues(alpha: 0.7);
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: fill,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: revealed ? null : () => onSelect(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border:
                        Border.all(color: border, width: isSelected ? 1.6 : 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: border.withValues(alpha: 0.15),
                        ),
                        child: Text(
                          String.fromCharCode(65 + index),
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: scheme.onSurface.withValues(alpha: 0.75),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          options[index],
                          style: TextStyle(
                            height: 1.35,
                            fontSize: english ? 15.5 : 16,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                      if (trailing != null)
                        Icon(trailing, color: iconColor, size: 22),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
        if (revealed) ...[
          const SizedBox(height: 8),
          _FeedbackPanel(
            correct: selected == correct,
            explanation: question.explanation(english),
            source: question.source(english),
            caution: caution,
          ),
        ],
      ],
    );
  }
}

class _FeedbackPanel extends StatelessWidget {
  const _FeedbackPanel({
    required this.correct,
    required this.explanation,
    required this.source,
    required this.caution,
  });

  final bool correct;
  final String explanation;
  final String source;
  final String? caution;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent =
        correct ? const Color(0xFF2E7D32) : const Color(0xFFB42318);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: accent.withValues(alpha: 0.08),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            correct
                ? context.tr('quizAnswerCorrect')
                : context.tr('quizAnswerIncorrect'),
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            explanation,
            style: TextStyle(height: 1.45, color: scheme.onSurface),
          ),
          const SizedBox(height: 10),
          Text(
            context.tr('quizSource'),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            source,
            style: TextStyle(
              height: 1.4,
              color: scheme.onSurface.withValues(alpha: 0.72),
            ),
          ),
          if (caution != null && caution!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              context.tr('quizCaution'),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              caution!,
              style: TextStyle(
                height: 1.4,
                color: scheme.onSurface.withValues(alpha: 0.68),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
