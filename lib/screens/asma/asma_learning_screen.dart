import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/asma_provider.dart';
import 'asma_detail_screen.dart';

class AsmaLearningScreen extends StatefulWidget {
  const AsmaLearningScreen({super.key});

  @override
  State<AsmaLearningScreen> createState() => _AsmaLearningScreenState();
}

class _AsmaLearningScreenState extends State<AsmaLearningScreen> {
  int _sessionSize = 10;
  bool _quizMode = false;
  bool _unreviewedOnly = true;
  String? _lastQuizFeedback;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AsmaProvider>();
    final scheme = Theme.of(context).colorScheme;
    final english = !context.isArabic;
    final session = provider.session;
    final current = provider.currentLearningName;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('asmaLearningMode')),
        actions: [
          if (session != null)
            IconButton(
              tooltip: context.tr('asmaEndSession'),
              onPressed: provider.endSession,
              icon: const Icon(Icons.close_rounded),
            ),
        ],
      ),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('asmaLearningIntro'),
                          style: TextStyle(
                            height: 1.45,
                            color: scheme.onSurface.withValues(alpha: 0.75),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          context
                              .tr('asmaProgress')
                              .replaceAll(
                                '{reviewed}',
                                '${provider.reviewedCount}',
                              )
                              .replaceAll('{total}', '${provider.totalCount}'),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        if (provider.lifetimeQuizAnswered > 0) ...[
                          const SizedBox(height: 6),
                          Text(
                            context
                                .tr('asmaQuizLifetime')
                                .replaceAll(
                                  '{correct}',
                                  '${provider.lifetimeQuizCorrect}',
                                )
                                .replaceAll(
                                  '{total}',
                                  '${provider.lifetimeQuizAnswered}',
                                ),
                            style: TextStyle(
                              color: scheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (session == null) ...[
                  Text(
                    context.tr('asmaStartSession'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(context.tr('asmaSessionSize')),
                  Slider(
                    value: _sessionSize.toDouble(),
                    min: 5,
                    max: 20,
                    divisions: 3,
                    label: '$_sessionSize',
                    onChanged: (value) {
                      setState(() => _sessionSize = value.round());
                    },
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.tr('asmaQuizMode')),
                    subtitle: Text(context.tr('asmaQuizModeHelp')),
                    value: _quizMode,
                    onChanged: (value) => setState(() => _quizMode = value),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.tr('asmaUnreviewedOnly')),
                    value: _unreviewedOnly,
                    onChanged: (value) =>
                        setState(() => _unreviewedOnly = value),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: () => provider.startSession(
                      size: _sessionSize,
                      quizMode: _quizMode,
                      unreviewedOnly: _unreviewedOnly,
                    ),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text(context.tr('asmaBegin')),
                  ),
                  TextButton(
                    onPressed: provider.clearReviewedProgress,
                    child: Text(context.tr('asmaResetProgress')),
                  ),
                ] else if (session.isComplete || current == null) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.celebration_outlined,
                            size: 40,
                            color: AppTheme.accentGold,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            context.tr('asmaSessionComplete'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                          if (session.quizMode) ...[
                            const SizedBox(height: 8),
                            Text(
                              context
                                  .tr('asmaQuizResult')
                                  .replaceAll(
                                    '{correct}',
                                    '${session.quizCorrect}',
                                  )
                                  .replaceAll(
                                    '{total}',
                                    '${session.quizAnswered}',
                                  ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: provider.restartSession,
                            child: Text(context.tr('asmaRestartSession')),
                          ),
                          TextButton(
                            onPressed: provider.endSession,
                            child: Text(context.tr('asmaEndSession')),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  Text(
                    context
                        .tr('asmaSessionProgress')
                        .replaceAll('{current}', '${session.cursor + 1}')
                        .replaceAll('{total}', '${session.nameIds.length}'),
                    style: TextStyle(
                      color: scheme.onSurface.withValues(alpha: 0.65),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      color: scheme.surface,
                      border: Border.all(
                        color: AppTheme.accentGold.withValues(alpha: 0.28),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          current.arabic,
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            fontSize: 42,
                            fontFamily: 'serif',
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          current.transliteration,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                          ),
                        ),
                        if (!session.quizMode) ...[
                          const SizedBox(height: 16),
                          if (!provider.meaningRevealed)
                            OutlinedButton(
                              onPressed: provider.revealMeaning,
                              child: Text(context.tr('asmaRevealMeaning')),
                            )
                          else ...[
                            Text(
                              current.meaning(english),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.4,
                                color:
                                    scheme.onSurface.withValues(alpha: 0.85),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              current.explanation(english),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                height: 1.45,
                                color:
                                    scheme.onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (session.quizMode) ...[
                    if (_lastQuizFeedback != null) ...[
                      Text(
                        _lastQuizFeedback!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: scheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    ...provider.currentQuizOptions.map(
                      (option) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: OutlinedButton(
                          onPressed: () async {
                            final correct =
                                await provider.answerQuiz(option);
                            setState(() {
                              _lastQuizFeedback = correct
                                  ? context.tr('asmaQuizCorrect')
                                  : context.tr('asmaQuizIncorrect');
                            });
                          },
                          child: Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(option),
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    FilledButton(
                      onPressed: () async {
                        await provider.markCurrentReviewedAndNext();
                        setState(() => _lastQuizFeedback = null);
                      },
                      child: Text(context.tr('asmaMarkReviewedNext')),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () async {
                        await provider.skipToNext();
                        setState(() => _lastQuizFeedback = null);
                      },
                      child: Text(context.tr('asmaSkip')),
                    ),
                  ],
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              AsmaDetailScreen(nameId: current.id),
                        ),
                      );
                    },
                    child: Text(context.tr('asmaOpenDetails')),
                  ),
                ],
              ],
            ),
    );
  }
}
