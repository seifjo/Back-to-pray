import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../data/dua_library.dart';
import '../../l10n/app_localizations.dart';
import '../../models/dua.dart';
import '../../providers/dua_provider.dart';
import '../../widgets/islamic_motif.dart';
import 'dua_detail_screen.dart';

class DuaLibraryScreen extends StatefulWidget {
  const DuaLibraryScreen({super.key});

  @override
  State<DuaLibraryScreen> createState() => _DuaLibraryScreenState();
}

class _DuaLibraryScreenState extends State<DuaLibraryScreen> {
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<DuaProvider>();
      if (provider.loading) {
        provider.initialize();
      }
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _open(DuaItem item) {
    context.read<DuaProvider>().markViewed(item.id);
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => DuaDetailScreen(duaId: item.id),
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
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DuaProvider>();
    final scheme = Theme.of(context).colorScheme;
    final english = !context.isArabic;
    final browsingHome = provider.query.isEmpty &&
        provider.categoryFilter == null &&
        !provider.favoritesOnly;
    final recent = provider.recentDuas;
    final favorites = provider.favoriteDuas;
    final page = provider.visiblePage;

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
          RefreshIndicator(
            onRefresh: provider.initialize,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                SliverAppBar(
                  pinned: true,
                  title: Text(context.tr('duaLibraryTitle')),
                ),
                if (provider.loading)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (provider.error != null)
                  SliverFillRemaining(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(context.tr('duaLoadError')),
                      ),
                    ),
                  )
                else ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('duaLibrarySubtitle'),
                            style: TextStyle(
                              height: 1.45,
                              color: scheme.onSurface.withValues(alpha: 0.68),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _search,
                            onChanged: (value) {
                              provider.setQuery(value);
                              setState(() {});
                            },
                            textInputAction: TextInputAction.search,
                            decoration: InputDecoration(
                              hintText: context.tr('duaSearchHint'),
                              prefixIcon: const Icon(Icons.search_rounded),
                              suffixIcon: _search.text.isEmpty
                                  ? null
                                  : IconButton(
                                      tooltip: context.tr('clearSearch'),
                                      onPressed: () {
                                        _search.clear();
                                        provider.setQuery('');
                                        setState(() {});
                                      },
                                      icon: const Icon(Icons.close_rounded),
                                    ),
                              filled: true,
                              fillColor: scheme.surface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
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
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 46,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        children: [
                          _chip(
                            label: context.tr('duaAllCategories'),
                            selected: browsingHome,
                            onSelected: (_) {
                              _search.clear();
                              provider.clearFilters();
                              setState(() {});
                            },
                          ),
                          _chip(
                            label: context.tr('duaFavorites'),
                            selected: provider.favoritesOnly,
                            avatar: Icon(
                              provider.favoritesOnly
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: 16,
                            ),
                            onSelected: (selected) =>
                                provider.setFavoritesOnly(selected),
                          ),
                          for (final category in provider.categories)
                            _chip(
                              label: category.name(english),
                              selected:
                                  provider.categoryFilter == category.id,
                              onSelected: (selected) {
                                provider.setCategoryFilter(
                                  selected ? category.id : null,
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (browsingHome && favorites.isNotEmpty)
                    _section(
                      title: context.tr('duaFavorites'),
                      children: [
                        for (final item in favorites.take(6))
                          _DuaTile(
                            item: item,
                            english: english,
                            favorite: true,
                            onTap: () => _open(item),
                          ),
                      ],
                    ),
                  if (browsingHome && recent.isNotEmpty)
                    _section(
                      title: context.tr('duaRecent'),
                      children: [
                        for (final item in recent.take(6))
                          _DuaTile(
                            item: item,
                            english: english,
                            favorite: provider.isFavorite(item.id),
                            onTap: () => _open(item),
                          ),
                      ],
                    ),
                  if (browsingHome) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
                        child: Text(
                          context.tr('duaBrowseCategories'),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                      sliver: SliverList.separated(
                        itemCount: provider.categories.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final category = provider.categories[index];
                          final count =
                              DuaLibrary.byCategory(category.id).length;
                          return Material(
                            color: scheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () =>
                                  provider.setCategoryFilter(category.id),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryGreen
                                            .withValues(alpha: 0.12),
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.menu_book_rounded,
                                        color: AppTheme.primaryGreen,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            category.name(english),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15.5,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            category.description(english),
                                            style: TextStyle(
                                              height: 1.35,
                                              color: scheme.onSurface
                                                  .withValues(alpha: 0.62),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            context
                                                .tr('duaItemCount')
                                                .replaceAll(
                                                  '{count}',
                                                  '$count',
                                                ),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: scheme.onSurface
                                                  .withValues(alpha: 0.45),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      color: scheme.onSurface
                                          .withValues(alpha: 0.35),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ] else ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
                        child: Text(
                          provider.favoritesOnly
                              ? context.tr('duaFavorites')
                              : provider.categoryFilter != null
                                  ? provider
                                      .categoryMeta(provider.categoryFilter!)!
                                      .name(english)
                                  : context.tr('duaSearchResults'),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    if (page.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _EmptyState(
                          onClear: () {
                            _search.clear();
                            provider.clearFilters();
                            setState(() {});
                          },
                        ),
                      )
                    else ...[
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        sliver: SliverList.separated(
                          itemCount: page.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final item = page[index];
                            return _DuaTile(
                              item: item,
                              english: english,
                              favorite: provider.isFavorite(item.id),
                              onTap: () => _open(item),
                            );
                          },
                        ),
                      ),
                      if (provider.canLoadMore)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                            child: OutlinedButton(
                              onPressed: provider.loadMore,
                              child: Text(context.tr('duaLoadMore')),
                            ),
                          ),
                        )
                      else
                        const SliverToBoxAdapter(
                          child: SizedBox(height: 28),
                        ),
                    ],
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip({
    required String label,
    required bool selected,
    required ValueChanged<bool> onSelected,
    Widget? avatar,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        avatar: avatar,
        label: Text(label),
        selected: selected,
        onSelected: onSelected,
      ),
    );
  }

  Widget _section({
    required String title,
    required List<Widget> children,
  }) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            ...[
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) const SizedBox(height: 10),
                children[i],
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _DuaTile extends StatelessWidget {
  final DuaItem item;
  final bool english;
  final bool favorite;
  final VoidCallback onTap;

  const _DuaTile({
    required this.item,
    required this.english,
    required this.favorite,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final category = DuaLibrary.categoryById(item.categoryId);
    final sourceLabel = item.isQuranic
        ? context.tr('duaSourceQuranic')
        : context.tr('duaSourceProphetic');

    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      [
                        if (category != null) category.name(english),
                        sourceLabel,
                        item.reference,
                      ].join(' · '),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.accentGold.withValues(alpha: 0.95),
                      ),
                    ),
                  ),
                  if (favorite)
                    const Icon(
                      Icons.favorite,
                      size: 16,
                      color: AppTheme.accentGold,
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                item.arabic,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 20,
                  height: 1.75,
                  fontFamily: 'serif',
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.translation(english),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  height: 1.4,
                  color: scheme.onSurface.withValues(alpha: 0.72),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onClear;

  const _EmptyState({required this.onClear});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 52,
            color: scheme.onSurface.withValues(alpha: 0.35),
          ),
          const SizedBox(height: 14),
          Text(
            context.tr('duaEmpty'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.tr('duaEmptyHelp'),
            textAlign: TextAlign.center,
            style: TextStyle(
              height: 1.4,
              color: scheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: onClear,
            child: Text(context.tr('clearSearch')),
          ),
        ],
      ),
    );
  }
}
