import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/hadith_locale.dart';
import '../../data/hadith_categories.dart';
import '../../l10n/app_localizations.dart';
import '../../models/hadith.dart';
import '../../providers/hadith_provider.dart';
import '../../widgets/islamic_motif.dart';
import 'hadith_detail_screen.dart';

class HadithLibraryScreen extends StatefulWidget {
  const HadithLibraryScreen({super.key});

  @override
  State<HadithLibraryScreen> createState() => _HadithLibraryScreenState();
}

class _HadithLibraryScreenState extends State<HadithLibraryScreen> {
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<HadithProvider>();
      if (provider.loading || provider.hadithOfTheDay() == null) {
        provider.initialize();
      }
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _open(HadithItem item) {
    context.read<HadithProvider>().markViewed(item.id);
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => HadithDetailScreen(hadithId: item.id),
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
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HadithProvider>();
    final scheme = Theme.of(context).colorScheme;
    final english = !context.isArabic;
    final ofTheDay = provider.hadithOfTheDay();
    final featured = provider.featuredHadith();
    final page = provider.visiblePage;
    final home = provider.isBrowsingHome;

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
                  title: Text(context.tr('hadithLibraryTitle')),
                ),
                if (provider.loading)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (provider.error != null && ofTheDay == null)
                  SliverFillRemaining(
                    child: _ErrorState(
                      message: context.tr('hadithLoadError'),
                      onRetry: provider.initialize,
                    ),
                  )
                else ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('hadithLibrarySubtitle'),
                            style: TextStyle(
                              height: 1.5,
                              color: scheme.onSurface.withValues(alpha: 0.68),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _search,
                            onChanged: (value) {
                              provider.setQuery(value);
                              setState(() {});
                            },
                            decoration: InputDecoration(
                              hintText: context.tr('hadithSearchHint'),
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
                              fillColor: scheme.surfaceContainerHighest
                                  .withValues(alpha: 0.45),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (home && ofTheDay != null)
                    SliverToBoxAdapter(
                      child: _SpotlightCard(
                        badge: context.tr('hadithOfTheDay'),
                        hadith: ofTheDay,
                        english: english,
                        onOpen: () => _open(ofTheDay),
                        onFavorite: () =>
                            provider.toggleFavorite(ofTheDay.id),
                        favorite: provider.isFavorite(ofTheDay.id),
                      ),
                    ),
                  if (home &&
                      featured != null &&
                      featured.id != ofTheDay?.id)
                    SliverToBoxAdapter(
                      child: _SpotlightCard(
                        badge: context.tr('hadithFeatured'),
                        hadith: featured,
                        english: english,
                        tone: AppTheme.accentGold,
                        onOpen: () => _open(featured),
                        onFavorite: () =>
                            provider.toggleFavorite(featured.id),
                        favorite: provider.isFavorite(featured.id),
                      ),
                    ),
                  if (home && provider.recentHadiths.isNotEmpty)
                    SliverToBoxAdapter(
                      child: _HorizontalSection(
                        title: context.tr('hadithRecent'),
                        items: provider.recentHadiths.take(10).toList(),
                        english: english,
                        onOpen: _open,
                      ),
                    ),
                  if (home && provider.favoriteHadiths.isNotEmpty)
                    SliverToBoxAdapter(
                      child: _HorizontalSection(
                        title: context.tr('hadithFavorites'),
                        items: provider.favoriteHadiths.take(10).toList(),
                        english: english,
                        onOpen: _open,
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: _CategoryRow(
                      selected: provider.categoryFilter,
                      onSelected: (id) {
                        provider.setCategoryFilter(
                          provider.categoryFilter == id ? null : id,
                        );
                      },
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _FilterBar(provider: provider),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              context.tr('hadithBrowseAll'),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 17,
                              ),
                            ),
                          ),
                          Text(
                            '${page.length}/${provider.filtered.length}',
                            style: TextStyle(
                              color: scheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (page.isEmpty)
                    SliverToBoxAdapter(
                      child: _EmptyState(
                        onClear: () {
                          _search.clear();
                          provider.clearFilters();
                          setState(() {});
                        },
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      sliver: SliverList.separated(
                        itemCount: page.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final item = page[index];
                          return _HadithCard(
                            hadith: item,
                            english: english,
                            favorite: provider.isFavorite(item.id),
                            onOpen: () => _open(item),
                            onFavorite: () =>
                                provider.toggleFavorite(item.id),
                          );
                        },
                      ),
                    ),
                  if (provider.canLoadMore)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        child: OutlinedButton(
                          onPressed: provider.loadMore,
                          child: Text(context.tr('hadithLoadMore')),
                        ),
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: _CollectionsPanel(provider: provider),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                      child: Text(
                        HadithLocale.attribution(context.l10n),
                        style: TextStyle(
                          fontSize: 11,
                          height: 1.45,
                          color: scheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
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

class _SpotlightCard extends StatelessWidget {
  const _SpotlightCard({
    required this.badge,
    required this.hadith,
    required this.english,
    required this.onOpen,
    required this.onFavorite,
    required this.favorite,
    this.tone = AppTheme.primaryGreen,
  });

  final String badge;
  final HadithItem hadith;
  final bool english;
  final VoidCallback onOpen;
  final VoidCallback onFavorite;
  final bool favorite;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final topic = HadithLocale.topicLabel(hadith, l10n);
    final heading = HadithLocale.heading(hadith, english: english);
    final preview = HadithLocale.preview(hadith, english: english);
    final narrator = HadithLocale.narrator(hadith, english: english);
    final grade = HadithLocale.primaryGradeLabel(hadith, l10n);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Material(
        color: tone.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onOpen,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 12, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      badge,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: tone,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: onFavorite,
                      icon: Icon(
                        favorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: favorite ? const Color(0xFFB42318) : null,
                      ),
                    ),
                  ],
                ),
                if (topic != null) ...[
                  _TopicChip(label: topic, color: tone),
                  const SizedBox(height: 10),
                ],
                if (heading != null)
                  Text(
                    heading,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textDirection:
                        english ? TextDirection.ltr : TextDirection.rtl,
                    style: TextStyle(
                      fontSize: english ? 17 : 20,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                      fontFamily: english ? null : 'serif',
                    ),
                  ),
                if (preview != null && preview != heading) ...[
                  const SizedBox(height: 8),
                  Text(
                    preview,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    textAlign: english ? TextAlign.start : TextAlign.center,
                    textDirection:
                        english ? TextDirection.ltr : TextDirection.rtl,
                    style: TextStyle(
                      fontSize: english ? 14.5 : 18,
                      height: english ? 1.45 : 1.7,
                      fontFamily: english ? null : 'serif',
                      color: scheme.onSurface.withValues(alpha: 0.82),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                _MetaLine(
                  narrator: narrator,
                  source: HadithLocale.referenceLabel(hadith, l10n),
                  grade: grade,
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton.icon(
                    onPressed: onOpen,
                    icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                    label: Text(context.tr('hadithOpenDetails')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HadithCard extends StatelessWidget {
  const _HadithCard({
    required this.hadith,
    required this.english,
    required this.favorite,
    required this.onOpen,
    required this.onFavorite,
  });

  final HadithItem hadith;
  final bool english;
  final bool favorite;
  final VoidCallback onOpen;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final topic = HadithLocale.topicLabel(hadith, l10n);
    final heading = HadithLocale.heading(hadith, english: english);
    final preview = HadithLocale.preview(hadith, english: english);
    final narrator = HadithLocale.narrator(hadith, english: english);
    final grade = HadithLocale.primaryGradeLabel(hadith, l10n);

    return Material(
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.42),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (topic != null) ...[
                          _TopicChip(label: topic),
                          const SizedBox(height: 10),
                        ],
                        if (heading != null)
                          Text(
                            heading,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textDirection: english
                                ? TextDirection.ltr
                                : TextDirection.rtl,
                            style: TextStyle(
                              fontSize: english ? 16.5 : 19,
                              fontWeight: FontWeight.w700,
                              height: 1.35,
                              fontFamily: english ? null : 'serif',
                            ),
                          )
                        else
                          Text(
                            context.tr('hadithTextUnavailable'),
                            style: TextStyle(
                              color:
                                  scheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: context.tr('hadithFavorite'),
                    onPressed: onFavorite,
                    icon: Icon(
                      favorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: favorite ? const Color(0xFFB42318) : null,
                    ),
                  ),
                ],
              ),
              if (preview != null) ...[
                const SizedBox(height: 10),
                Divider(
                  height: 1,
                  color: scheme.onSurface.withValues(alpha: 0.08),
                ),
                const SizedBox(height: 10),
                Text(
                  preview,
                  maxLines: english ? 3 : 4,
                  overflow: TextOverflow.ellipsis,
                  textAlign: english ? TextAlign.start : TextAlign.center,
                  textDirection:
                      english ? TextDirection.ltr : TextDirection.rtl,
                  style: TextStyle(
                    fontSize: english ? 14 : 17.5,
                    height: english ? 1.45 : 1.75,
                    fontFamily: english ? null : 'serif',
                    color: scheme.onSurface.withValues(alpha: 0.84),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              _MetaLine(
                narrator: narrator,
                source: HadithLocale.referenceLabel(hadith, l10n),
                grade: grade,
              ),
              const SizedBox(height: 4),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: onOpen,
                  child: Text(context.tr('hadithOpenDetails')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopicChip extends StatelessWidget {
  const _TopicChip({
    required this.label,
    this.color = AppTheme.primaryGreen,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          letterSpacing: 0.6,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({
    required this.source,
    this.narrator,
    this.grade,
  });

  final String source;
  final String? narrator;
  final String? grade;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final style = TextStyle(
      fontSize: 12.5,
      height: 1.4,
      color: scheme.onSurface.withValues(alpha: 0.62),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (narrator != null)
          Text(
            '${context.tr('hadithNarrator')}: $narrator',
            style: style,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        Text(
          '${context.tr('hadithSourceLabel')}: $source',
          style: style.copyWith(
            color: AppTheme.accentGold.withValues(alpha: 0.95),
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (grade != null && grade!.trim().isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              '${context.tr('hadithGrading')}: $grade',
              style: style,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelected;

  const _CategoryRow({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Text(
            context.tr('hadithTopics'),
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          ),
        ),
        SizedBox(
          height: 52,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            scrollDirection: Axis.horizontal,
            itemCount: HadithCategories.all.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final category = HadithCategories.all[index];
              final active = selected == category.id;
              return FilterChip(
                label: Text(context.tr(category.nameKey)),
                selected: active,
                onSelected: (_) => onSelected(category.id),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FilterBar extends StatelessWidget {
  final HadithProvider provider;

  const _FilterBar({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: provider.collectionFilter,
              hint: Text(context.tr('hadithFilterCollection')),
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text(context.tr('hadithAllCollections')),
                ),
                ...HadithCollections.available.map(
                  (c) => DropdownMenuItem(
                    value: c.id,
                    child: Text(context.tr(c.nameKey)),
                  ),
                ),
              ],
              onChanged: provider.setCollectionFilter,
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: provider.gradeFilter,
              hint: Text(context.tr('hadithFilterGrade')),
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text(context.tr('hadithAllGrades')),
                ),
                DropdownMenuItem(
                  value: 'sahih',
                  child: Text(context.tr('hadithGradeSahih')),
                ),
                DropdownMenuItem(
                  value: 'hasan',
                  child: Text(context.tr('hadithGradeHasan')),
                ),
                DropdownMenuItem(
                  value: 'daif',
                  child: Text(context.tr('hadithGradeDaif')),
                ),
              ],
              onChanged: provider.setGradeFilter,
            ),
          ),
          if (provider.collectionFilter != null ||
              provider.gradeFilter != null ||
              provider.categoryFilter != null)
            TextButton(
              onPressed: provider.clearFilters,
              child: Text(context.tr('clearSearch')),
            ),
        ],
      ),
    );
  }
}

class _HorizontalSection extends StatelessWidget {
  final String title;
  final List<HadithItem> items;
  final bool english;
  final ValueChanged<HadithItem> onOpen;

  const _HorizontalSection({
    required this.title,
    required this.items,
    required this.english,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
        ),
        SizedBox(
          height: 158,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final item = items[index];
              final heading = HadithLocale.heading(item, english: english);
              final topic = HadithLocale.topicLabel(item, context.l10n);
              return SizedBox(
                width: 250,
                child: Material(
                  color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(18),
                  child: InkWell(
                    onTap: () => onOpen(item),
                    borderRadius: BorderRadius.circular(18),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (topic != null) ...[
                            _TopicChip(label: topic),
                            const SizedBox(height: 8),
                          ],
                          Expanded(
                            child: Text(
                              heading ??
                                  context.tr('hadithTextUnavailable'),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              textDirection: english
                                  ? TextDirection.ltr
                                  : TextDirection.rtl,
                              style: TextStyle(
                                height: 1.35,
                                fontSize: english ? 13.5 : 15,
                                fontFamily: english ? null : 'serif',
                              ),
                            ),
                          ),
                          Text(
                            HadithLocale.referenceLabel(item, context.l10n),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.accentGold,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.menu_book_outlined,
            size: 42,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            context.tr('hadithEmpty'),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          FilledButton.tonal(
            onPressed: onClear,
            child: Text(context.tr('clearSearch')),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onRetry,
              child: Text(context.tr('retry')),
            ),
          ],
        ),
      ),
    );
  }
}

class _CollectionsPanel extends StatelessWidget {
  final HadithProvider provider;

  const _CollectionsPanel({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('hadithDownloadCollections'),
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            context.tr('hadithDownloadHelp'),
            style: TextStyle(
              height: 1.45,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 10),
          for (final collection in HadithCollections.available)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(context.tr(collection.nameKey)),
              subtitle: Text(
                provider.cachedCollections.contains(collection.id)
                    ? context.tr('hadithCollectionReady')
                    : context.tr('hadithCollectionNeedDownload'),
              ),
              trailing: provider.downloadingId == collection.id
                  ? SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        value: provider.downloadProgress == 0
                            ? null
                            : provider.downloadProgress,
                        strokeWidth: 2.5,
                      ),
                    )
                  : IconButton(
                      onPressed:
                          provider.cachedCollections.contains(collection.id)
                              ? null
                              : () =>
                                  provider.downloadCollection(collection.id),
                      icon: Icon(
                        provider.cachedCollections.contains(collection.id)
                            ? Icons.offline_pin
                            : Icons.download_outlined,
                      ),
                    ),
            ),
        ],
      ),
    );
  }
}
