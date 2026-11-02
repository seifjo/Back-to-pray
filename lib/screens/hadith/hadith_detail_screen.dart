import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/hadith_locale.dart';
import '../../l10n/app_localizations.dart';
import '../../models/hadith.dart';
import '../../providers/hadith_provider.dart';
import 'hadith_explanation_screen.dart';

class HadithDetailScreen extends StatelessWidget {
  final String hadithId;

  const HadithDetailScreen({super.key, required this.hadithId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HadithProvider>();
    final hadith = provider.byId(hadithId);
    final scheme = Theme.of(context).colorScheme;
    final english = !context.isArabic;
    final l10n = context.l10n;

    if (hadith == null) {
      return Scaffold(
        appBar: AppBar(title: Text(context.tr('hadithLibraryTitle'))),
        body: Center(child: Text(context.tr('hadithMissing'))),
      );
    }

    final related = provider.related(hadith);
    final favorite = provider.isFavorite(hadith.id);
    final body = HadithLocale.body(hadith, english: english);
    final narrator = HadithLocale.narrator(hadith, english: english);
    final topic = HadithLocale.topicLabel(hadith, l10n);
    final grade = HadithLocale.primaryGradeLabel(hadith, l10n);

    return Scaffold(
      appBar: AppBar(
        title: Text(HadithLocale.collectionName(hadith, l10n)),
        actions: [
          IconButton(
            tooltip: context.tr('hadithFavorite'),
            onPressed: () => provider.toggleFavorite(hadith.id),
            icon: Icon(
              favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: favorite ? const Color(0xFFB42318) : null,
            ),
          ),
          IconButton(
            tooltip: context.tr('hadithCopy'),
            onPressed: () => _copy(context, hadith, english: english),
            icon: const Icon(Icons.copy_rounded),
          ),
          IconButton(
            tooltip: context.tr('hadithShare'),
            onPressed: () => _share(context, hadith, english: english),
            icon: const Icon(Icons.share_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
        children: [
          if (topic != null) ...[
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  topic.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    letterSpacing: 0.6,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Text(
            HadithLocale.referenceLabel(hadith, l10n),
            style: const TextStyle(
              color: AppTheme.accentGold,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          if (narrator != null) ...[
            const SizedBox(height: 8),
            Text(
              '${context.tr('hadithNarrator')}: $narrator',
              style: TextStyle(
                color: scheme.onSurface.withValues(alpha: 0.68),
                height: 1.4,
              ),
            ),
          ],
          if (grade != null) ...[
            const SizedBox(height: 6),
            Text(
              '${context.tr('hadithGrading')}: $grade',
              style: TextStyle(
                color: scheme.onSurface.withValues(alpha: 0.68),
              ),
            ),
          ],
          const SizedBox(height: 18),
          Divider(color: scheme.onSurface.withValues(alpha: 0.08)),
          const SizedBox(height: 18),
          if (body.isNotEmpty)
            Text(
              body,
              textAlign: english ? TextAlign.start : TextAlign.center,
              textDirection: english ? TextDirection.ltr : TextDirection.rtl,
              style: TextStyle(
                fontSize: english ? 17 : 27,
                height: english ? 1.6 : 1.95,
                fontFamily: english ? null : 'serif',
                color: scheme.onSurface,
              ),
            )
          else
            Text(context.tr('hadithTextUnavailable')),
          const SizedBox(height: 22),
          Divider(color: scheme.onSurface.withValues(alpha: 0.08)),
          if (hadith.hasGrades) ...[
            const SizedBox(height: 16),
            Text(
              context.tr('hadithGrading'),
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
            ),
            const SizedBox(height: 8),
            for (final gradeItem in hadith.grades)
              if (gradeItem.grade.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    english
                        ? '${HadithLocale.gradeLabel(gradeItem.grade, l10n)}${gradeItem.name.trim().isEmpty ? '' : ' — ${gradeItem.name}'}'
                        : HadithLocale.gradeLabel(gradeItem.grade, l10n),
                    style: TextStyle(
                      color: scheme.onSurface.withValues(alpha: 0.85),
                    ),
                  ),
                ),
            Text(
              context.tr('hadithGradingSource'),
              style: TextStyle(
                fontSize: 12,
                color: scheme.onSurface.withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 8),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) =>
                      HadithExplanationScreen(hadithId: hadith.id),
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
            },
            icon: const Icon(Icons.lightbulb_outline_rounded),
            label: Text(context.tr('hadithExplain')),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      _copy(context, hadith, english: english),
                  icon: const Icon(Icons.copy_rounded),
                  label: Text(context.tr('hadithCopy')),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      _share(context, hadith, english: english),
                  icon: const Icon(Icons.share_outlined),
                  label: Text(context.tr('hadithShare')),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            context.tr('hadithRelated'),
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 10),
          if (related.isEmpty)
            Text(
              context.tr('hadithNoRelated'),
              style: TextStyle(
                color: scheme.onSurface.withValues(alpha: 0.6),
              ),
            )
          else
            ...related.map((item) {
              final relatedHeading =
                  HadithLocale.heading(item, english: english);
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color:
                      scheme.surfaceContainerHighest.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      provider.markViewed(item.id);
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) =>
                              HadithDetailScreen(hadithId: item.id),
                          transitionsBuilder: (_, animation, __, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                          transitionDuration:
                              const Duration(milliseconds: 240),
                        ),
                      );
                    },
                    child: ListTile(
                      title: Text(
                        relatedHeading ??
                            context.tr('hadithTextUnavailable'),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textDirection: english
                            ? TextDirection.ltr
                            : TextDirection.rtl,
                      ),
                      subtitle: Text(
                        HadithLocale.referenceLabel(item, l10n),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                    ),
                  ),
                ),
              );
            }),
          const SizedBox(height: 18),
          Text(
            HadithLocale.attribution(l10n),
            style: TextStyle(
              fontSize: 11,
              height: 1.45,
              color: scheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _copy(
    BuildContext context,
    HadithItem hadith, {
    required bool english,
  }) async {
    final text = HadithLocale.shareText(
      hadith,
      context.l10n,
      english: english,
    );
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.tr('hadithCopied'))),
    );
  }

  Future<void> _share(
    BuildContext context,
    HadithItem hadith, {
    required bool english,
  }) async {
    await Share.share(
      HadithLocale.shareText(hadith, context.l10n, english: english),
    );
  }
}
