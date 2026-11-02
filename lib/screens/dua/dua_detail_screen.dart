import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/services/dua_preferences_store.dart';
import '../../core/theme/app_theme.dart';
import '../../data/dua_library.dart';
import '../../l10n/app_localizations.dart';
import '../../models/dua.dart';
import '../../providers/dua_provider.dart';

class DuaDetailScreen extends StatelessWidget {
  final String duaId;

  const DuaDetailScreen({super.key, required this.duaId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DuaProvider>();
    final dua = provider.byId(duaId);
    final scheme = Theme.of(context).colorScheme;
    final english = !context.isArabic;

    if (dua == null) {
      return Scaffold(
        appBar: AppBar(title: Text(context.tr('duaLibraryTitle'))),
        body: Center(child: Text(context.tr('duaMissing'))),
      );
    }

    final related = provider.related(dua);
    final favorite = provider.isFavorite(dua.id);
    final category = provider.categoryMeta(dua.categoryId);
    final sourceLabel = dua.isQuranic
        ? context.tr('duaSourceQuranic')
        : context.tr('duaSourceProphetic');
    final explanation = dua.explanation(english);
    final shared = DuaLibrary.sharedAdhkar(dua);

    return Scaffold(
      appBar: AppBar(
        title: Text(category?.name(english) ?? context.tr('duaLibraryTitle')),
        actions: [
          IconButton(
            tooltip: context.tr('duaFavorite'),
            onPressed: () => provider.toggleFavorite(dua.id),
            icon: Icon(favorite ? Icons.favorite : Icons.favorite_border),
          ),
          IconButton(
            tooltip: context.tr('duaCopy'),
            onPressed: () => _copy(context, dua, english),
            icon: const Icon(Icons.copy_rounded),
          ),
          IconButton(
            tooltip: context.tr('duaShare'),
            onPressed: () => _share(dua, english),
            icon: const Icon(Icons.share_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(
                label: Text(sourceLabel),
                visualDensity: VisualDensity.compact,
              ),
              Chip(
                label: Text(dua.reference),
                visualDensity: VisualDensity.compact,
                backgroundColor: AppTheme.accentGold.withValues(alpha: 0.15),
              ),
              if (shared != null)
                Chip(
                  avatar: const Icon(Icons.link_rounded, size: 16),
                  label: Text(context.tr('duaSharedWithAdhkar')),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    dua.arabic,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontSize: provider.arabicFontSize,
                      height: 1.9,
                      fontFamily: 'serif',
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.text_fields_rounded,
                        size: 18,
                        color: scheme.onSurface.withValues(alpha: 0.55),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        context.tr('duaArabicSize'),
                        style: TextStyle(
                          fontSize: 13,
                          color: scheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: provider.arabicFontSize,
                    min: DuaPreferencesStore.minArabicFontSize,
                    max: DuaPreferencesStore.maxArabicFontSize,
                    divisions: ((DuaPreferencesStore.maxArabicFontSize -
                                DuaPreferencesStore.minArabicFontSize) /
                            2)
                        .round(),
                    label: provider.arabicFontSize.round().toString(),
                    onChanged: provider.setArabicFontSize,
                  ),
                ],
              ),
            ),
          ),
          if (dua.translation(english).trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('duaTranslation'),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dua.translation(english),
                      textDirection:
                          english ? TextDirection.ltr : TextDirection.rtl,
                      style: TextStyle(
                        height: 1.55,
                        fontSize: 15.5,
                        color: scheme.onSurface.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('duaSource'),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${context.tr('duaReference')}: ${dua.reference}',
                    style: TextStyle(
                      height: 1.45,
                      color: scheme.onSurface.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    sourceLabel,
                    style: TextStyle(
                      color: scheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (explanation != null && explanation.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('duaExplanation'),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      explanation,
                      textDirection: _looksArabic(explanation)
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      style: TextStyle(
                        height: 1.5,
                        color: scheme.onSurface.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          Text(
            context.tr('duaRelated'),
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 8),
          if (related.isEmpty)
            Text(
              context.tr('duaNoRelated'),
              style: TextStyle(
                color: scheme.onSurface.withValues(alpha: 0.6),
              ),
            )
          else
            ...related.map(
              (item) => Card(
                child: ListTile(
                  title: Text(
                    item.arabic,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontFamily: 'serif', height: 1.5),
                  ),
                  subtitle: Text(
                    item.reference,
                    style: const TextStyle(color: AppTheme.accentGold),
                  ),
                  onTap: () {
                    provider.markViewed(item.id);
                    Navigator.of(context).pushReplacement(
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) =>
                            DuaDetailScreen(duaId: item.id),
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

  bool _looksArabic(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }

  Future<void> _copy(
    BuildContext context,
    DuaItem dua,
    bool english,
  ) async {
    final text = _format(dua, english);
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.tr('duaCopied'))),
    );
  }

  Future<void> _share(DuaItem dua, bool english) {
    return Share.share(_format(dua, english));
  }

  String _format(DuaItem dua, bool english) {
    return '${dua.arabic}\n\n${dua.translation(english)}\n\n${dua.reference}';
  }
}
