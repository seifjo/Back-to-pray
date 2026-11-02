import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../data/asma_ul_husna.dart';
import '../../l10n/app_localizations.dart';
import '../../models/asma.dart';
import '../../providers/asma_provider.dart';
import '../../widgets/islamic_motif.dart';
import 'asma_artwork_screen.dart';
import 'asma_detail_screen.dart';
import 'asma_learning_screen.dart';

class AsmaLibraryScreen extends StatefulWidget {
  const AsmaLibraryScreen({super.key});

  @override
  State<AsmaLibraryScreen> createState() => _AsmaLibraryScreenState();
}

class _AsmaLibraryScreenState extends State<AsmaLibraryScreen> {
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AsmaProvider>();
      if (provider.loading) provider.initialize();
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _open(DivineName name) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => AsmaDetailScreen(nameId: name.id),
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

  void _openLearning() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const AsmaLearningScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 260),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AsmaProvider>();
    final scheme = Theme.of(context).colorScheme;
    final english = !context.isArabic;
    final names = provider.filtered;
    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width >= 900 ? 3 : width >= 600 ? 2 : 1;

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
                  title: Text(context.tr('asmaTitle')),
                  actions: [
                    IconButton(
                      tooltip: context.tr('asmaArtwork'),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AsmaArtworkScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.grid_view_rounded),
                    ),
                    IconButton(
                      tooltip: context.tr('asmaLearningMode'),
                      onPressed: _openLearning,
                      icon: const Icon(Icons.school_rounded),
                    ),
                  ],
                ),
                if (provider.loading)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (provider.error != null)
                  SliverFillRemaining(
                    child: Center(child: Text(context.tr('asmaLoadError'))),
                  )
                else ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('asmaSubtitle'),
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
                            decoration: InputDecoration(
                              hintText: context.tr('asmaSearchHint'),
                              prefixIcon: const Icon(Icons.search_rounded),
                              suffixIcon: _search.text.isEmpty
                                  ? null
                                  : IconButton(
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
                          const SizedBox(height: 14),
                          _ProgressBanner(
                            reviewed: provider.reviewedCount,
                            total: provider.totalCount,
                            onLearn: _openLearning,
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
                            label: context.tr('asmaAll'),
                            selected: provider.themeFilter == null &&
                                !provider.favoritesOnly &&
                                provider.sourceFilter == null &&
                                provider.collectionFilter == null,
                            onSelected: (_) {
                              _search.clear();
                              provider.clearFilters();
                              setState(() {});
                            },
                          ),
                          _chip(
                            label: context.tr('asmaPrimary99'),
                            selected: provider.collectionFilter ==
                                AsmaCollectionKind.primary,
                            onSelected: (selected) =>
                                provider.setCollectionFilter(
                              selected ? AsmaCollectionKind.primary : null,
                            ),
                          ),
                          _chip(
                            label: context.tr('asmaCompound'),
                            selected: provider.collectionFilter ==
                                AsmaCollectionKind.quranCompound,
                            onSelected: (selected) =>
                                provider.setCollectionFilter(
                              selected
                                  ? AsmaCollectionKind.quranCompound
                                  : null,
                            ),
                          ),
                          _chip(
                            label: context.tr('asmaSunnahExtra'),
                            selected: provider.collectionFilter ==
                                AsmaCollectionKind.sunnahExtra,
                            onSelected: (selected) =>
                                provider.setCollectionFilter(
                              selected ? AsmaCollectionKind.sunnahExtra : null,
                            ),
                          ),
                          _chip(
                            label: context.tr('asmaFavorites'),
                            selected: provider.favoritesOnly,
                            onSelected: provider.setFavoritesOnly,
                          ),
                          _chip(
                            label: context.tr('asmaArtwork'),
                            selected: false,
                            onSelected: (_) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const AsmaArtworkScreen(),
                                ),
                              );
                            },
                          ),
                          for (final theme in provider.themes)
                            _chip(
                              label: theme.name(english),
                              selected: provider.themeFilter == theme.id,
                              onSelected: (selected) =>
                                  provider.setThemeFilter(
                                selected ? theme.id : null,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  ..._bodySlivers(
                    context: context,
                    provider: provider,
                    english: english,
                    names: names,
                    crossAxisCount: crossAxisCount,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Home browse: artwork for 1–99, then titled compound + Sunnah sections.
  /// Search / favorites / theme filters keep a flat filtered grid.
  List<Widget> _bodySlivers({
    required BuildContext context,
    required AsmaProvider provider,
    required bool english,
    required List<DivineName> names,
    required int crossAxisCount,
  }) {
    final searching = provider.query.trim().isNotEmpty;
    final specialized = provider.favoritesOnly ||
        provider.themeFilter != null ||
        provider.sourceFilter != null ||
        searching;
    final primaryOnly =
        provider.collectionFilter == AsmaCollectionKind.primary;
    final compoundOnly =
        provider.collectionFilter == AsmaCollectionKind.quranCompound;
    final sunnahOnly =
        provider.collectionFilter == AsmaCollectionKind.sunnahExtra;
    final homeBrowse = !specialized && provider.collectionFilter == null;

    if (specialized) {
      if (names.isEmpty) return [_emptySliver(context)];
      return [_namesGrid(names, provider, english, crossAxisCount)];
    }

    if (primaryOnly) {
      return [
        _artworkPreview(context),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            child: Text(
              context.tr('asmaPrimaryInArtwork'),
              textAlign: TextAlign.center,
              style: TextStyle(
                height: 1.45,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.7),
              ),
            ),
          ),
        ),
      ];
    }

    if (compoundOnly) {
      if (names.isEmpty) return [_emptySliver(context)];
      return [
        _sectionHeader(context, context.tr('asmaCompound')),
        _namesGrid(names, provider, english, crossAxisCount),
      ];
    }

    if (sunnahOnly) {
      if (names.isEmpty) return [_emptySliver(context)];
      return [
        _sectionHeader(context, context.tr('asmaSunnahExtra')),
        _namesGrid(names, provider, english, crossAxisCount),
      ];
    }

    if (homeBrowse) {
      const compound = AsmaUlHusna.compoundQuran;
      const sunnah = AsmaUlHusna.sunnahExtra;
      return [
        _artworkPreview(context),
        _sectionHeader(context, context.tr('asmaCompound')),
        _namesGrid(compound, provider, english, crossAxisCount),
        _sectionHeader(context, context.tr('asmaSunnahExtra')),
        _namesGrid(sunnah, provider, english, crossAxisCount),
      ];
    }

    if (names.isEmpty) return [_emptySliver(context)];
    return [_namesGrid(names, provider, english, crossAxisCount)];
  }

  Widget _emptySliver(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Text(
            context.tr('asmaEmpty'),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    final scheme = Theme.of(context).colorScheme;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            height: 1.4,
            color: scheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _artworkPreview(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.tr('asmaPrimary99'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            Material(
              color: const Color(0xFF4A1C1C),
              borderRadius: BorderRadius.circular(18),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AsmaArtworkScreen(),
                    ),
                  );
                },
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset(
                    AsmaUlHusna.artworkAsset,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          context.tr('asmaArtworkMissing'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xFFE8D5A3)),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr('asmaPrimaryInArtwork'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                color: scheme.onSurface.withValues(alpha: 0.62),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _namesGrid(
    List<DivineName> names,
    AsmaProvider provider,
    bool english,
    int crossAxisCount,
  ) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: crossAxisCount == 1 ? 2.35 : 1.35,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final name = names[index];
            return _NameCard(
              name: name,
              english: english,
              favorite: provider.isFavorite(name.id),
              reviewed: provider.isReviewed(name.id),
              onTap: () => _open(name),
            );
          },
          childCount: names.length,
        ),
      ),
    );
  }

  Widget _chip({
    required String label,
    required bool selected,
    required ValueChanged<bool> onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: onSelected,
      ),
    );
  }
}

class _ProgressBanner extends StatelessWidget {
  final int reviewed;
  final int total;
  final VoidCallback onLearn;

  const _ProgressBanner({
    required this.reviewed,
    required this.total,
    required this.onLearn,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final progress = total == 0 ? 0.0 : reviewed / total;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            AppTheme.accentGold.withValues(alpha: 0.18),
            scheme.surface,
          ],
        ),
        border: Border.all(
          color: AppTheme.accentGold.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context
                      .tr('asmaProgress')
                      .replaceAll('{reviewed}', '$reviewed')
                      .replaceAll('{total}', '$total'),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              TextButton(
                onPressed: onLearn,
                child: Text(context.tr('asmaLearningMode')),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: scheme.onSurface.withValues(alpha: 0.08),
              color: AppTheme.accentGold,
            ),
          ),
        ],
      ),
    );
  }
}

class _NameCard extends StatelessWidget {
  final DivineName name;
  final bool english;
  final bool favorite;
  final bool reviewed;
  final VoidCallback onTap;

  const _NameCard({
    required this.name,
    required this.english,
    required this.favorite,
    required this.reviewed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(
                    '${name.index}',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.accentGold.withValues(alpha: 0.9),
                    ),
                  ),
                  const Spacer(),
                  if (reviewed)
                    Icon(
                      Icons.check_circle_outline,
                      size: 16,
                      color: scheme.primary,
                    ),
                  if (favorite) ...[
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.favorite,
                      size: 16,
                      color: AppTheme.accentGold,
                    ),
                  ],
                ],
              ),
              const Spacer(),
              Text(
                name.arabic,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontSize: 28,
                  height: 1.3,
                  fontFamily: 'serif',
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                name.transliteration,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface.withValues(alpha: 0.78),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                name.meaning(english),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  height: 1.3,
                  color: scheme.onSurface.withValues(alpha: 0.62),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
