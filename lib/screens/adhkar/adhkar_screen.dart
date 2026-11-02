import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../data/adhkar_library.dart';
import '../../l10n/app_localizations.dart';
import '../../models/adhkar.dart';
import '../../providers/adhkar_progress_provider.dart';
import 'adhkar_reader_screen.dart';

/// Category library for authentic Adhkar.
class AdhkarScreen extends StatefulWidget {
  const AdhkarScreen({super.key});

  @override
  State<AdhkarScreen> createState() => _AdhkarScreenState();
}

class _AdhkarScreenState extends State<AdhkarScreen>
    with WidgetsBindingObserver {
  final _search = TextEditingController();
  bool _favoritesOnly = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdhkarProgressProvider>().ensureToday();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _search.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<AdhkarProgressProvider>().ensureToday();
    }
  }

  @override
  Widget build(BuildContext context) {
    final english = !context.isArabic;
    final query = _search.text.trim().toLowerCase();
    final scheme = Theme.of(context).colorScheme;
    final progress = context.watch<AdhkarProgressProvider>();
    final categories = AdhkarLibrary.categories.where((category) {
      if (query.isEmpty) return true;
      final haystack = [
        category.displayName(english),
        category.displayName(!english),
        ...category.items.map((item) => item.arabicText),
        ...category.items.map((item) => item.translation),
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('adhkarTitle')),
        actions: [
          IconButton(
            tooltip: context.tr('favorites'),
            onPressed: () => setState(() => _favoritesOnly = !_favoritesOnly),
            icon: Icon(
              _favoritesOnly ? Icons.bookmark : Icons.bookmark_border,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: context.tr('searchAdhkar'),
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: scheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          if (!_favoritesOnly && progress.loaded)
            _TodaySummary(progress: progress),
          Expanded(
            child: _favoritesOnly
                ? _FavoritesList(english: english)
                : categories.isEmpty
                    ? Center(child: Text(context.tr('noResults')))
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        children: [
                          if (progress.loaded &&
                              progress.recentlyViewed().isNotEmpty) ...[
                            _RecentlyViewedSection(english: english),
                            const SizedBox(height: 16),
                          ],
                          Text(
                            context
                                .tr('adhkarCategoryCount')
                                .replaceAll(
                                  '{count}',
                                  '${categories.length}',
                                ),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: scheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 10),
                          for (var i = 0; i < categories.length; i++) ...[
                            if (i > 0) const SizedBox(height: 12),
                            _CategoryCard(
                              category: categories[i],
                              english: english,
                              ratio: progress.progressFor(categories[i]),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AdhkarReaderScreen(
                                      category: categories[i],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}

class _TodaySummary extends StatelessWidget {
  const _TodaySummary({
    required this.progress,
  });

  final AdhkarProgressProvider progress;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final completed = progress.todayCompletedCategoryCount;
    final total = progress.todayTotalCategoryCount;
    final remaining = progress.remainingCategoriesToday.length;
    final ratio = progress.todayOverallProgress;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: scheme.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: scheme.primary.withValues(alpha: 0.16)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.today_rounded, color: scheme.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.tr('adhkarTodayProgress'),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  progress.todayFullyComplete
                      ? context.tr('adhkarTodayComplete')
                      : context.tr('adhkarTodayIncomplete'),
                  style: TextStyle(
                    color: progress.todayFullyComplete
                        ? Colors.green.shade700
                        : scheme.onSurface.withValues(alpha: 0.65),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              borderRadius: BorderRadius.circular(8),
              color: progress.todayFullyComplete
                  ? Colors.green
                  : AppTheme.primaryGreen,
              backgroundColor: scheme.onSurface.withValues(alpha: 0.08),
            ),
            const SizedBox(height: 10),
            Text(
              context
                  .tr('adhkarTodayStats')
                  .replaceAll('{completed}', '$completed')
                  .replaceAll('{total}', '$total')
                  .replaceAll('{remaining}', '$remaining')
                  .replaceAll(
                    '{items}',
                    '${progress.todayCompletedItemCount}/${progress.todayTotalItemCount}',
                  ),
              style: TextStyle(
                fontSize: 13,
                color: scheme.onSurface.withValues(alpha: 0.75),
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final AdhkarCategory category;
  final bool english;
  final double ratio;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.english,
    required this.ratio,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final complete = ratio >= 1;
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(category.icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.displayName(english),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category.displayDescription(english),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: scheme.onSurface.withValues(alpha: 0.65),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${category.displayTime(english)} · '
                      '${context.tr('adhkarItemCount').replaceAll('{count}', '${category.itemCount}')}',
                      style: TextStyle(
                        color: scheme.onSurface.withValues(alpha: 0.55),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: ratio,
                      minHeight: 5,
                      borderRadius: BorderRadius.circular(8),
                      color: complete ? Colors.green : AppTheme.primaryGreen,
                      backgroundColor: scheme.onSurface.withValues(alpha: 0.08),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (complete)
                const Icon(Icons.check_circle, color: Colors.green)
              else
                Text(
                  '${category.itemCount}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: scheme.primary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentlyViewedSection extends StatelessWidget {
  const _RecentlyViewedSection({required this.english});

  final bool english;

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<AdhkarProgressProvider>();
    final recent = progress.recentlyViewed();
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('recentlyViewed'),
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 88,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: recent.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final entry = recent[index];
              final itemIndex = entry.category.items.indexOf(entry.item);
              return InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdhkarReaderScreen(
                        category: entry.category,
                        initialIndex: itemIndex < 0 ? 0 : itemIndex,
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 200,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: scheme.onSurface.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.category.displayName(english),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: scheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Expanded(
                        child: Text(
                          english
                              ? entry.item.translation
                              : entry.item.arabicText,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textDirection:
                              english ? TextDirection.ltr : TextDirection.rtl,
                          style: const TextStyle(fontSize: 13, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FavoritesList extends StatelessWidget {
  final bool english;
  const _FavoritesList({required this.english});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<AdhkarProgressProvider>().favoriteItems();
    if (favorites.isEmpty) {
      return Center(child: Text(context.tr('noResults')));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: favorites.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final entry = favorites[index];
        final itemIndex = entry.category.items.indexOf(entry.item);
        return Card(
          child: ListTile(
            title: Text(
              english ? entry.item.translation : entry.item.arabicText,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textDirection: english ? TextDirection.ltr : TextDirection.rtl,
            ),
            subtitle: Text(entry.category.displayName(english)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AdhkarReaderScreen(
                    category: entry.category,
                    initialIndex: itemIndex < 0 ? 0 : itemIndex,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
