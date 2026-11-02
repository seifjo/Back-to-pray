import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/hadith_locale.dart';
import '../../l10n/app_localizations.dart';
import '../../models/hadith.dart';
import '../../models/hadith_explanation.dart';
import '../../providers/app_settings_provider.dart';
import '../../providers/hadith_explanation_provider.dart';
import '../../providers/hadith_provider.dart';
import '../../widgets/islamic_motif.dart';

class HadithExplanationScreen extends StatefulWidget {
  final String hadithId;

  const HadithExplanationScreen({super.key, required this.hadithId});

  @override
  State<HadithExplanationScreen> createState() =>
      _HadithExplanationScreenState();
}

class _HadithExplanationScreenState extends State<HadithExplanationScreen> {
  late String _hadithId;

  @override
  void initState() {
    super.initState();
    _hadithId = widget.hadithId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<HadithExplanationProvider>();
      if (provider.loading && provider.supportedIds.isEmpty) {
        provider.initialize();
      }
    });
  }

  void _open(String id) {
    setState(() => _hadithId = id);
  }

  @override
  Widget build(BuildContext context) {
    final explanations = context.watch<HadithExplanationProvider>();
    final hadiths = context.watch<HadithProvider>();
    final settings = context.watch<AppSettingsProvider>();
    final scheme = Theme.of(context).colorScheme;
    final english = !context.isArabic;
    final hadith = hadiths.byId(_hadithId);
    final explanation = explanations.forHadith(_hadithId);
    final arabicSize = settings.adhkarFontSize;
    final previous = explanations.previousId(_hadithId);
    final next = explanations.nextId(_hadithId);
    final bookmarked = explanations.isBookmarked(_hadithId);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('hadithExplanationTitle')),
        actions: [
          IconButton(
            tooltip: context.tr('hadithExplanationBookmark'),
            onPressed: explanation.available
                ? () => explanations.toggleBookmark(_hadithId)
                : null,
            icon: Icon(
              bookmarked ? Icons.bookmark : Icons.bookmark_border,
            ),
          ),
          IconButton(
            tooltip: context.tr('hadithCopy'),
            onPressed: () => _copy(hadith, explanation, english),
            icon: const Icon(Icons.copy_rounded),
          ),
          IconButton(
            tooltip: context.tr('hadithShare'),
            onPressed: () => _share(hadith, explanation, english),
            icon: const Icon(Icons.share_outlined),
          ),
        ],
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
          if (explanations.loading)
            const Center(child: CircularProgressIndicator())
          else if (explanations.error != null)
            Center(child: Text(context.tr('hadithExplanationLoadError')))
          else
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
              children: [
                if (hadith != null)
                  _HadithReferenceCard(hadith: hadith, english: english),
                const SizedBox(height: 14),
                if (!explanation.available ||
                    explanation.scholarlyBody(english).trim().isEmpty)
                  const _UnavailableCard()
                else ...[
                  if (explanation.summaryNote(english).isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        explanation.summaryNote(english),
                        style: TextStyle(
                          height: 1.45,
                          color: scheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  _SectionCard(
                    title: context.tr('hadithExplanationBody'),
                    child: Text(
                      explanation.scholarlyBody(english),
                      textAlign:
                          english ? TextAlign.start : TextAlign.justify,
                      textDirection:
                          english ? TextDirection.ltr : TextDirection.rtl,
                      style: TextStyle(
                        fontFamily: english ? null : 'serif',
                        fontSize: english ? 15.5 : arabicSize,
                        height: english ? 1.55 : 1.85,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                  if (english && explanation.vocabulary.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _SectionCard(
                      title: context.tr('hadithExplanationVocabulary'),
                      child: Column(
                        children: [
                          for (final entry in explanation.vocabulary)
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                entry.term,
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                              subtitle: Text(entry.definition),
                            ),
                        ],
                      ),
                    ),
                  ],
                  if (explanation.context(english).trim().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _SectionCard(
                      title: context.tr('hadithExplanationContext'),
                      child: Text(
                        explanation.context(english),
                        style: const TextStyle(height: 1.5),
                      ),
                    ),
                  ],
                  if (explanation.lessons(english).isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _SectionCard(
                      title: context.tr('hadithExplanationLessons'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final lesson in explanation.lessons(english))
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('• '),
                                  Expanded(child: Text(lesson)),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                  if (explanation.application(english).trim().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _SectionCard(
                      title: context.tr('hadithExplanationApplication'),
                      child: Text(
                        explanation.application(english),
                        style: const TextStyle(height: 1.5),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  _SectionCard(
                    title: context.tr('hadithExplanationAttribution'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (explanation.author(english).isNotEmpty)
                          Text(
                            '${context.tr('hadithExplanationAuthor')}: ${explanation.author(english)}',
                          ),
                        if (explanation.sourceBook(english).isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            '${context.tr('hadithExplanationSource')}: ${explanation.sourceBook(english)}',
                          ),
                        ],
                        if (english &&
                            explanation.sourceReference.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(explanation.sourceReference),
                        ],
                        if (english && explanation.licenseNote.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(
                            explanation.licenseNote,
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.4,
                              color: scheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: previous == null ? null : () => _open(previous),
                        icon: const Icon(Icons.chevron_left),
                        label: Text(context.tr('previous')),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: next == null ? null : () => _open(next),
                        icon: const Icon(Icons.chevron_right),
                        label: Text(context.tr('next')),
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _copy(
    HadithItem? hadith,
    HadithExplanation explanation,
    bool english,
  ) async {
    final text = _shareText(hadith, explanation, english);
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.tr('hadithCopied'))),
    );
  }

  Future<void> _share(
    HadithItem? hadith,
    HadithExplanation explanation,
    bool english,
  ) async {
    await Share.share(_shareText(hadith, explanation, english));
  }

  String _shareText(
    HadithItem? hadith,
    HadithExplanation explanation,
    bool english,
  ) {
    final l10n = context.l10n;
    return [
      if (hadith != null) ...[
        HadithLocale.body(hadith, english: english),
        HadithLocale.referenceLabel(hadith, l10n),
      ],
      if (explanation.available) ...[
        explanation.scholarlyBody(english),
        if (explanation.author(english).isNotEmpty ||
            explanation.sourceBook(english).isNotEmpty)
          '${explanation.author(english)} — ${explanation.sourceBook(english)}',
      ] else
        l10n.tr('hadithExplanationUnavailable'),
    ].where((line) => line.trim().isNotEmpty).join('\n\n');
  }
}

class _HadithReferenceCard extends StatelessWidget {
  final HadithItem hadith;
  final bool english;

  const _HadithReferenceCard({
    required this.hadith,
    required this.english,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final body = HadithLocale.body(hadith, english: english);
    final narrator = HadithLocale.narrator(hadith, english: english);
    return Card(
      color: AppTheme.primaryGreen.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('hadithExplanationSelected'),
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryGreen,
              ),
            ),
            const SizedBox(height: 8),
            if (body.isNotEmpty)
              Text(
                body,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                textAlign: english ? TextAlign.start : TextAlign.center,
                textDirection:
                    english ? TextDirection.ltr : TextDirection.rtl,
                style: TextStyle(
                  fontFamily: english ? null : 'serif',
                  fontSize: english ? 16 : 20,
                  height: english ? 1.45 : 1.7,
                  color: scheme.onSurface,
                ),
              )
            else
              Text(context.tr('hadithTextUnavailable')),
            const SizedBox(height: 10),
            Text(
              HadithLocale.referenceLabel(hadith, context.l10n),
              style: const TextStyle(
                color: AppTheme.accentGold,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (narrator != null) ...[
              const SizedBox(height: 4),
              Text(
                '${context.tr('hadithNarrator')}: $narrator',
                style: TextStyle(
                  color: scheme.onSurface.withValues(alpha: 0.65),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _UnavailableCard extends StatelessWidget {
  const _UnavailableCard();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Icon(
              Icons.menu_book_outlined,
              size: 40,
              color: scheme.onSurface.withValues(alpha: 0.45),
            ),
            const SizedBox(height: 12),
            Text(
              context.tr('hadithExplanationUnavailable'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr('hadithExplanationUnavailableBody'),
              textAlign: TextAlign.center,
              style: TextStyle(
                height: 1.45,
                color: scheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}
