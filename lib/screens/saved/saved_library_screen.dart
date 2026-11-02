import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../data/adhkar_library.dart';
import '../../data/quran_data.dart';
import '../../l10n/app_localizations.dart';
import '../../models/saved_library.dart';
import '../../providers/adhkar_progress_provider.dart';
import '../../providers/asma_provider.dart';
import '../../providers/dua_provider.dart';
import '../../providers/hadith_explanation_provider.dart';
import '../../providers/hadith_provider.dart';
import '../../providers/quran_provider.dart';
import '../../providers/saved_library_provider.dart';
import '../../widgets/islamic_motif.dart';
import '../adhkar/adhkar_reader_screen.dart';
import '../adhkar/adhkar_screen.dart';
import '../asma/asma_detail_screen.dart';
import '../asma/asma_library_screen.dart';
import '../dua/dua_detail_screen.dart';
import '../dua/dua_library_screen.dart';
import '../hadith/hadith_detail_screen.dart';
import '../hadith/hadith_explanation_screen.dart';
import '../hadith/hadith_library_screen.dart';
import '../quran/quran_screen.dart';

class SavedLibraryScreen extends StatefulWidget {
  const SavedLibraryScreen({super.key});

  @override
  State<SavedLibraryScreen> createState() => _SavedLibraryScreenState();
}

class _SavedLibraryScreenState extends State<SavedLibraryScreen> {
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<SavedLibraryProvider>();
      // Refresh on open so favorites saved in other modules appear promptly.
      provider.refresh();
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _open(SavedLibraryItem item) async {
    final library = context.read<SavedLibraryProvider>();
    if (!item.available) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(context.tr('savedUnavailableTitle')),
          content: Text(context.tr('savedUnavailableBody')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(context.tr('ok')),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await _remove(item);
              },
              child: Text(context.tr('savedRemove')),
            ),
          ],
        ),
      );
      return;
    }

    await library.markOpened(item);
    if (!mounted) return;

    final page = _pageFor(item);
    if (page == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('savedUnavailableBody'))),
      );
      return;
    }

    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
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
    if (mounted) await library.refresh();
  }

  Widget? _pageFor(SavedLibraryItem item) {
    switch (item.type) {
      case SavedContentType.hadith:
        return HadithDetailScreen(hadithId: item.sourceId);
      case SavedContentType.hadithExplanation:
        return HadithExplanationScreen(hadithId: item.sourceId);
      case SavedContentType.dua:
        return DuaDetailScreen(duaId: item.sourceId);
      case SavedContentType.namesOfAllah:
        return AsmaDetailScreen(nameId: item.sourceId);
      case SavedContentType.adhkar:
        final categoryId = item.routeArgs['categoryId'];
        final index = int.tryParse(item.routeArgs['index'] ?? '') ?? 0;
        if (categoryId == null) return null;
        final category = AdhkarLibrary.byId(categoryId);
        if (category == null) return null;
        return AdhkarReaderScreen(category: category, initialIndex: index);
      case SavedContentType.quranBookmark:
        final surahNumber =
            int.tryParse(item.routeArgs['surahNumber'] ?? '') ?? 0;
        for (final s in QuranData.surahs) {
          if (s.number == surahNumber) {
            return SurahDetailScreen(surah: s);
          }
        }
        return null;
    }
  }

  Future<void> _remove(SavedLibraryItem item) async {
    final library = context.read<SavedLibraryProvider>();
    await library.remove(item);
    if (!mounted) return;

    // Keep in-memory source providers aligned with SharedPreferences.
    switch (item.type) {
      case SavedContentType.hadith:
        await context.read<HadithProvider>().initialize();
      case SavedContentType.hadithExplanation:
        await context.read<HadithExplanationProvider>().initialize();
      case SavedContentType.adhkar:
        await context.read<AdhkarProgressProvider>().load();
      case SavedContentType.dua:
        await context.read<DuaProvider>().initialize();
      case SavedContentType.namesOfAllah:
        await context.read<AsmaProvider>().initialize();
      case SavedContentType.quranBookmark:
        await context.read<QuranProvider>().clearLastRead();
    }
  }

  void _browseShortcut(SavedContentType? type) {
    final Widget page = switch (type) {
      SavedContentType.hadith ||
      SavedContentType.hadithExplanation =>
        const HadithLibraryScreen(),
      SavedContentType.adhkar => const AdhkarScreen(),
      SavedContentType.dua => const DuaLibraryScreen(),
      SavedContentType.namesOfAllah => const AsmaLibraryScreen(),
      SavedContentType.quranBookmark => const QuranScreen(),
      null => const HadithLibraryScreen(),
    };
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SavedLibraryProvider>();
    final scheme = Theme.of(context).colorScheme;
    final english = !context.isArabic;
    final items = provider.filtered;

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
            Center(child: Text(context.tr('savedLoadError')))
          else
            RefreshIndicator(
              onRefresh: provider.refresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    title: Text(context.tr('savedTitle')),
                    actions: [
                      PopupMenuButton<SavedLibrarySort>(
                        tooltip: context.tr('savedSort'),
                        initialValue: provider.sort,
                        onSelected: provider.setSort,
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: SavedLibrarySort.dateSavedNewest,
                            child: Text(context.tr('savedSortNewest')),
                          ),
                          PopupMenuItem(
                            value: SavedLibrarySort.dateSavedOldest,
                            child: Text(context.tr('savedSortOldest')),
                          ),
                        ],
                        icon: const Icon(Icons.sort_rounded),
                      ),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('savedSubtitle'),
                            style: TextStyle(
                              height: 1.45,
                              color: scheme.onSurface.withValues(alpha: 0.68),
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: _search,
                            onChanged: provider.setQuery,
                            decoration: InputDecoration(
                              hintText: context.tr('savedSearchHint'),
                              prefixIcon: const Icon(Icons.search_rounded),
                              suffixIcon: provider.query.isEmpty
                                  ? null
                                  : IconButton(
                                      onPressed: () {
                                        _search.clear();
                                        provider.setQuery('');
                                      },
                                      icon: const Icon(Icons.clear_rounded),
                                    ),
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _TypeFilters(provider: provider),
                          if (provider.recentlyViewed.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Text(
                              context.tr('savedRecentlyViewed'),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 104,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: provider.recentlyViewed.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 10),
                                itemBuilder: (context, index) {
                                  final item = provider.recentlyViewed[index];
                                  return _RecentChip(
                                    item: item,
                                    english: english,
                                    onTap: () => _open(item),
                                  );
                                },
                              ),
                            ),
                          ],
                          if (provider.allItems.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Text(
                              context.tr('savedRecentlySaved'),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              context
                                  .tr('savedCount')
                                  .replaceAll('{count}', '${items.length}'),
                              style: TextStyle(
                                color:
                                    scheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (items.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyState(
                        filter: provider.typeFilter,
                        onBrowse: () => _browseShortcut(provider.typeFilter),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                      sliver: SliverList.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _SavedTile(
                            item: item,
                            english: english,
                            onOpen: () => _open(item),
                            onRemove: () => _remove(item),
                          );
                        },
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

class _TypeFilters extends StatelessWidget {
  const _TypeFilters({required this.provider});

  final SavedLibraryProvider provider;

  @override
  Widget build(BuildContext context) {
    final chips = <({SavedContentType? type, String labelKey})>[
      (type: null, labelKey: 'savedFilterAll'),
      (type: SavedContentType.hadith, labelKey: 'savedFilterHadith'),
      (
        type: SavedContentType.hadithExplanation,
        labelKey: 'savedFilterExplanations'
      ),
      (type: SavedContentType.adhkar, labelKey: 'savedFilterAdhkar'),
      (type: SavedContentType.dua, labelKey: 'savedFilterDuas'),
      (type: SavedContentType.quranBookmark, labelKey: 'savedFilterQuran'),
      (type: SavedContentType.namesOfAllah, labelKey: 'savedFilterAsma'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final chip in chips) ...[
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: FilterChip(
                label: Text(
                  chip.type == null
                      ? context.tr(chip.labelKey)
                      : '${context.tr(chip.labelKey)} (${provider.countFor(chip.type!)})',
                ),
                selected: provider.typeFilter == chip.type,
                onSelected: (_) => provider.setTypeFilter(chip.type),
                selectedColor: AppTheme.primaryGreen.withValues(alpha: 0.2),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RecentChip extends StatelessWidget {
  const _RecentChip({
    required this.item,
    required this.english,
    required this.onTap,
  });

  final SavedLibraryItem item;
  final bool english;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: 180,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: scheme.outline.withValues(alpha: 0.14)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _typeLabel(context, item.type),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                item.title(english),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700, height: 1.25),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SavedTile extends StatelessWidget {
  const _SavedTile({
    required this.item,
    required this.english,
    required this.onOpen,
    required this.onRemove,
  });

  final SavedLibraryItem item;
  final bool english;
  final VoidCallback onOpen;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final preview = item.preview(english);

    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onOpen,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: item.available
                  ? scheme.outline.withValues(alpha: 0.14)
                  : scheme.error.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_iconFor(item.type), color: AppTheme.primaryGreen),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _typeLabel(context, item.type),
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.title(english),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle(english),
                      style: TextStyle(
                        height: 1.35,
                        color: scheme.onSurface.withValues(alpha: 0.65),
                      ),
                    ),
                    if (preview != null && preview.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        preview,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          height: 1.4,
                          color: scheme.onSurface.withValues(alpha: 0.72),
                        ),
                      ),
                    ],
                    if (!item.available) ...[
                      const SizedBox(height: 6),
                      Text(
                        context.tr('savedUnavailableBadge'),
                        style: TextStyle(
                          color: scheme.error,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                tooltip: context.tr('savedRemove'),
                onPressed: onRemove,
                icon: const Icon(Icons.bookmark_remove_outlined),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.filter,
    required this.onBrowse,
  });

  final SavedContentType? filter;
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmarks_outlined,
            size: 48,
            color: scheme.onSurface.withValues(alpha: 0.35),
          ),
          const SizedBox(height: 14),
          Text(
            context.tr('savedEmptyTitle'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            context.tr('savedEmptyBody'),
            textAlign: TextAlign.center,
            style: TextStyle(
              height: 1.45,
              color: scheme.onSurface.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onBrowse,
            icon: const Icon(Icons.explore_rounded),
            label: Text(context.tr('savedBrowse')),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }
}

IconData _iconFor(SavedContentType type) {
  return switch (type) {
    SavedContentType.hadith => Icons.history_edu_rounded,
    SavedContentType.hadithExplanation => Icons.menu_book_rounded,
    SavedContentType.adhkar => Icons.auto_stories_rounded,
    SavedContentType.dua => Icons.volunteer_activism_rounded,
    SavedContentType.quranBookmark => Icons.menu_book_outlined,
    SavedContentType.namesOfAllah => Icons.brightness_5_rounded,
  };
}

String _typeLabel(BuildContext context, SavedContentType type) {
  return switch (type) {
    SavedContentType.hadith => context.tr('savedFilterHadith'),
    SavedContentType.hadithExplanation =>
      context.tr('savedFilterExplanations'),
    SavedContentType.adhkar => context.tr('savedFilterAdhkar'),
    SavedContentType.dua => context.tr('savedFilterDuas'),
    SavedContentType.quranBookmark => context.tr('savedFilterQuran'),
    SavedContentType.namesOfAllah => context.tr('savedFilterAsma'),
  };
}
