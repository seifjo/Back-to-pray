import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_theme.dart';
import '../../data/asma_ul_husna.dart';
import '../../l10n/app_localizations.dart';
import '../../models/asma.dart';
import '../../providers/asma_provider.dart';

class AsmaDetailScreen extends StatelessWidget {
  final String nameId;

  const AsmaDetailScreen({super.key, required this.nameId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AsmaProvider>();
    final name = provider.byId(nameId);
    final scheme = Theme.of(context).colorScheme;
    final english = !context.isArabic;

    if (name == null) {
      return Scaffold(
        appBar: AppBar(title: Text(context.tr('asmaTitle'))),
        body: Center(child: Text(context.tr('asmaMissing'))),
      );
    }

    final related = provider.related(name);
    final favorite = provider.isFavorite(name.id);
    final sourceLabel = name.fromQuran
        ? context.tr('asmaSourceQuran')
        : context.tr('asmaSourceSunnah');
    final collectionLabel = switch (name.collection) {
      AsmaCollectionKind.primary => context.tr('asmaPrimary99'),
      AsmaCollectionKind.quranCompound => context.tr('asmaCompound'),
      AsmaCollectionKind.sunnahExtra => context.tr('asmaSunnahExtra'),
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(name.transliteration),
        actions: [
          IconButton(
            tooltip: context.tr('asmaFavorite'),
            onPressed: () => provider.toggleFavorite(name.id),
            icon: Icon(favorite ? Icons.favorite : Icons.favorite_border),
          ),
          IconButton(
            tooltip: context.tr('asmaShare'),
            onPressed: () => _share(name, english),
            icon: const Icon(Icons.share_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.accentGold.withValues(alpha: 0.16),
                  scheme.surface,
                ],
              ),
              border: Border.all(
                color: AppTheme.accentGold.withValues(alpha: 0.22),
              ),
            ),
            child: Column(
              children: [
                Text(
                  '${name.index}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppTheme.accentGold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  name.arabic,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontSize: 48,
                    height: 1.35,
                    fontFamily: 'serif',
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  name.transliteration,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  name.meaning(english),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    height: 1.4,
                    fontSize: 16,
                    color: scheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text(collectionLabel)),
              Chip(label: Text(sourceLabel)),
              for (final themeId in name.themeIds)
                if (AsmaUlHusna.themeById(themeId) != null)
                  Chip(
                    label: Text(
                      AsmaUlHusna.themeById(themeId)!.name(english),
                    ),
                  ),
              if (provider.isReviewed(name.id))
                Chip(
                  avatar: const Icon(Icons.check, size: 16),
                  label: Text(context.tr('asmaReviewed')),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('asmaExplanation'),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  // Full Arabic explanation is the primary educational text.
                  if (name.explanationAr.trim().isNotEmpty) ...[
                    Text(
                      name.explanationAr,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        height: 1.7,
                        fontSize: 16,
                        color: scheme.onSurface.withValues(alpha: 0.92),
                      ),
                    ),
                    if (english && name.explanationEn.trim().isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        name.explanationEn,
                        style: TextStyle(
                          height: 1.5,
                          color: scheme.onSurface.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ] else
                    Text(
                      name.explanation(english),
                      textDirection:
                          english ? TextDirection.ltr : TextDirection.rtl,
                      style: TextStyle(
                        height: 1.55,
                        color: scheme.onSurface.withValues(alpha: 0.88),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('asmaSource'),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    name.evidenceNote(english),
                    style: TextStyle(
                      height: 1.45,
                      color: scheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    english
                        ? provider.attributionEn
                        : provider.attributionAr,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: scheme.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final uri = Uri.parse(AsmaUlHusna.sourceUrl);
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    },
                    icon: const Icon(Icons.open_in_new_rounded),
                    label: Text(context.tr('asmaOpenSourcePage')),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: () => provider.markReviewed(name.id),
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(context.tr('asmaMarkReviewed')),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                tooltip: context.tr('asmaCopy'),
                onPressed: () => _copy(context, name, english),
                icon: const Icon(Icons.copy_rounded),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            context.tr('asmaRelated'),
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 8),
          if (related.isEmpty)
            Text(context.tr('asmaNoRelated'))
          else
            ...related.map(
              (item) => Card(
                child: ListTile(
                  leading: Text(
                    '${item.index}',
                    style: const TextStyle(
                      color: AppTheme.accentGold,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  title: Text(
                    item.arabic,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(fontFamily: 'serif', fontSize: 20),
                  ),
                  subtitle: Text(item.meaning(english)),
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) =>
                            AsmaDetailScreen(nameId: item.id),
                        transitionsBuilder: (_, animation, __, child) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                        transitionDuration: const Duration(milliseconds: 220),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _copy(
    BuildContext context,
    DivineName name,
    bool english,
  ) async {
    await Clipboard.setData(ClipboardData(text: _format(name, english)));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.tr('asmaCopied'))),
    );
  }

  Future<void> _share(DivineName name, bool english) {
    return Share.share(_format(name, english));
  }

  String _format(DivineName name, bool english) {
    return '${name.arabic}\n${name.transliteration}\n${name.meaning(english)}\n\n${name.explanation(english)}';
  }
}
