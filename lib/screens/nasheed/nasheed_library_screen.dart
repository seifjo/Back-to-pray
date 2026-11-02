import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/services/islamic_audio_player.dart';
import '../../data/nasheed_catalog.dart';
import '../../l10n/app_localizations.dart';
import '../../models/islamic_audio.dart';
import '../../providers/nasheed_library_provider.dart';
import '../../widgets/islamic_motif.dart';
import 'nasheed_detail_screen.dart';
import 'nasheed_ui_helpers.dart';

class NasheedLibraryScreen extends StatefulWidget {
  const NasheedLibraryScreen({super.key});

  @override
  State<NasheedLibraryScreen> createState() => _NasheedLibraryScreenState();
}

class _NasheedLibraryScreenState extends State<NasheedLibraryScreen> {
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final library = context.read<NasheedLibraryProvider>();
      final player = context.read<IslamicAudioPlayer>();
      library.attachPlayer(player);
      if (library.loading || library.error != null) {
        library.initialize();
      }
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final library = context.watch<NasheedLibraryProvider>();
    final scheme = Theme.of(context).colorScheme;
    final english = !context.isArabic;
    final browsingHome = library.query.isEmpty && library.categoryFilter == null;

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
            onRefresh: library.initialize,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                SliverAppBar(
                  pinned: true,
                  title: Text(context.tr('nasheedTitle')),
                ),
                if (library.loading)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (library.error != null && library.filtered.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(context.tr('nasheedLoadError')),
                            const SizedBox(height: 12),
                            FilledButton(
                              onPressed: library.initialize,
                              child: Text(context.tr('retry')),
                            ),
                          ],
                        ),
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
                            context.tr('nasheedSubtitle'),
                            style: TextStyle(
                              color: scheme.onSurface.withValues(alpha: 0.72),
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _search,
                            onChanged: library.setQuery,
                            decoration: InputDecoration(
                              hintText: context.tr('nasheedSearchHint'),
                              prefixIcon: const Icon(Icons.search_rounded),
                              suffixIcon: library.query.isEmpty
                                  ? null
                                  : IconButton(
                                      onPressed: () {
                                        _search.clear();
                                        library.setQuery('');
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
                          const SizedBox(height: 10),
                          _SortRow(library: library),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              FilterChip(
                                selected: library.favoritesOnly,
                                label: Text(context.tr('nasheedFavoritesFilter')),
                                onSelected: library.setFavoritesOnly,
                              ),
                              FilterChip(
                                selected: library.playableOnly,
                                label: Text(context.tr('nasheedPlayableFilter')),
                                onSelected: library.setPlayableOnly,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            english
                                ? library.attributionEn
                                : library.attributionAr,
                            style: TextStyle(
                              fontSize: 11,
                              color: scheme.onSurface.withValues(alpha: 0.55),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (browsingHome) ...[
                    if (library.trending.isNotEmpty)
                      _HorizontalSection(
                        title: context.tr('nasheedTrending'),
                        tracks: library.trending,
                        english: english,
                        showTrendBadges: true,
                      ),
                    if (library.continueListening.isNotEmpty)
                      _HorizontalSection(
                        title: context.tr('nasheedContinue'),
                        tracks: library.continueListening,
                        english: english,
                      ),
                    if (library.featured.isNotEmpty)
                      _HorizontalSection(
                        title: context.tr('nasheedFeatured'),
                        tracks: library.featured,
                        english: english,
                        showTrendBadges: true,
                      ),
                    if (library.mostPopular.isNotEmpty)
                      _HorizontalSection(
                        title: context.tr('nasheedMostPopular'),
                        tracks: library.mostPopular,
                        english: english,
                        showTrendBadges: true,
                      ),
                    if (library.recommended.isNotEmpty)
                      _HorizontalSection(
                        title: context.tr('nasheedRecommended'),
                        tracks: library.recommended,
                        english: english,
                      ),
                    if (library.shortFormFavorites.isNotEmpty)
                      _HorizontalSection(
                        title: context.tr('nasheedShortForm'),
                        tracks: library.shortFormFavorites,
                        english: english,
                        showTrendBadges: true,
                      ),
                    if (library.newReleases.isNotEmpty)
                      _HorizontalSection(
                        title: context.tr('nasheedNewReleases'),
                        tracks: library.newReleases,
                        english: english,
                        showTrendBadges: true,
                      ),
                    if (library.recent.isNotEmpty)
                      _HorizontalSection(
                        title: context.tr('nasheedRecent'),
                        tracks: library.recent,
                        english: english,
                      ),
                    if (library.favoriteTracks.isNotEmpty)
                      _HorizontalSection(
                        title: context.tr('nasheedFavorites'),
                        tracks: library.favoriteTracks,
                        english: english,
                      ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                        child: Text(
                          context.tr('nasheedCategories'),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 44,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: FilterChip(
                                selected: library.categoryFilter == null,
                                label: Text(context.tr('nasheedAll')),
                                onSelected: (_) =>
                                    library.setCategoryFilter(null),
                              ),
                            ),
                            for (final category in library.categories)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: FilterChip(
                                  selected:
                                      library.categoryFilter == category.id,
                                  label: Text(category.name(english)),
                                  onSelected: (selected) {
                                    library.setCategoryFilter(
                                      selected ? category.id : null,
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                        child: Text(
                          context.tr('nasheedBrowseAll'),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ),
                  ] else ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            FilterChip(
                              selected: library.categoryFilter == null,
                              label: Text(context.tr('nasheedAll')),
                              onSelected: (_) =>
                                  library.setCategoryFilter(null),
                            ),
                            for (final category in library.categories)
                              FilterChip(
                                selected:
                                    library.categoryFilter == category.id,
                                label: Text(category.name(english)),
                                onSelected: (selected) {
                                  library.setCategoryFilter(
                                    selected ? category.id : null,
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (library.filtered.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyState(),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                      sliver: SliverList.separated(
                        itemCount: library.filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final track = library.filtered[index];
                          return _NasheedTile(
                            track: track,
                            english: english,
                          );
                        },
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

class _SortRow extends StatelessWidget {
  const _SortRow({required this.library});

  final NasheedLibraryProvider library;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          context.tr('nasheedSort'),
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final entry in {
                  NasheedSort.titleAsc: 'nasheedSortTitle',
                  NasheedSort.artistAsc: 'nasheedSortArtist',
                  NasheedSort.durationAsc: 'nasheedSortDurationAsc',
                  NasheedSort.durationDesc: 'nasheedSortDurationDesc',
                }.entries)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 6),
                    child: ChoiceChip(
                      selected: library.sort == entry.key,
                      label: Text(context.tr(entry.value)),
                      onSelected: (_) => library.setSort(entry.key),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HorizontalSection extends StatelessWidget {
  const _HorizontalSection({
    required this.title,
    required this.tracks,
    required this.english,
    this.showTrendBadges = false,
  });

  final String title;
  final List<IslamicAudioTrack> tracks;
  final bool english;
  final bool showTrendBadges;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
          SizedBox(
            height: showTrendBadges ? 196 : 168,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: tracks.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final track = tracks[index];
                return _FeatureCard(
                  track: track,
                  english: english,
                  showTrendBadges: showTrendBadges,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.track,
    required this.english,
    this.showTrendBadges = false,
  });

  final IslamicAudioTrack track;
  final bool english;
  final bool showTrendBadges;

  @override
  Widget build(BuildContext context) {
    final player = context.watch<IslamicAudioPlayer>();
    final scheme = Theme.of(context).colorScheme;
    final category = NasheedCatalog.categoryById(track.categoryId ?? '');
    final playing = player.isPlayingTrack(track.id);

    return SizedBox(
      width: 132,
      child: Material(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => NasheedDetailScreen(trackId: track.id),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: ColoredBox(
                          color: Color(category?.accent ?? 0xFF0D7377)
                              .withValues(alpha: 0.18),
                          child: Center(
                            child: track.coverAsset == null
                                ? Icon(
                                    Icons.music_note_rounded,
                                    color: scheme.primary,
                                    size: 36,
                                  )
                                : Image.asset(
                                    track.coverAsset!,
                                    fit: BoxFit.contain,
                                    width: 56,
                                    height: 56,
                                  ),
                          ),
                        ),
                      ),
                      if (playing)
                        Positioned(
                          right: 6,
                          top: 6,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: scheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.equalizer_rounded,
                              size: 14,
                              color: scheme.onPrimary,
                            ),
                          ),
                        ),
                      if (!track.audioAvailable)
                        Positioned(
                          left: 6,
                          top: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: scheme.surface.withValues(alpha: 0.92),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              context.tr('nasheedAudioUnavailable'),
                              style: const TextStyle(fontSize: 9),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  track.title(english),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  track.artist(english).trim().isEmpty
                      ? context.tr('nasheedArtistUnknown')
                      : track.artist(english),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurface.withValues(alpha: 0.65),
                  ),
                ),
                Text(
                  track.formattedDuration,
                  style: TextStyle(
                    fontSize: 11,
                    color: scheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                if (showTrendBadges) ...[
                  const SizedBox(height: 4),
                  NasheedBadgeRow(track: track, compact: true),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NasheedTile extends StatelessWidget {
  const _NasheedTile({required this.track, required this.english});

  final IslamicAudioTrack track;
  final bool english;

  @override
  Widget build(BuildContext context) {
    final library = context.watch<NasheedLibraryProvider>();
    final player = context.watch<IslamicAudioPlayer>();
    final scheme = Theme.of(context).colorScheme;
    final category = NasheedCatalog.categoryById(track.categoryId ?? '');
    final isCurrent = player.isCurrent(track.id);
    final isPlaying = player.isPlayingTrack(track.id);
    final favorite = library.isFavorite(track.id);
    final downloaded = library.isDownloaded(track.id);
    final downloading = library.downloadingId == track.id;

    return Material(
      color: isCurrent
          ? scheme.primary.withValues(alpha: 0.10)
          : scheme.surfaceContainerHighest.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => NasheedDetailScreen(trackId: track.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: ColoredBox(
                    color: Color(category?.accent ?? 0xFF0D7377)
                        .withValues(alpha: 0.18),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (track.coverAsset != null)
                          Image.asset(
                            track.coverAsset!,
                            width: 34,
                            height: 34,
                            fit: BoxFit.contain,
                          )
                        else
                          Icon(Icons.music_note_rounded, color: scheme.primary),
                        if (isPlaying)
                          Container(
                            color: Colors.black.withValues(alpha: 0.28),
                            child: Icon(
                              Icons.equalizer_rounded,
                              color: scheme.onPrimary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.title(english),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        track.artist(english).trim().isEmpty
                            ? context.tr('nasheedArtistUnknown')
                            : track.artist(english),
                        if (category != null) category.name(english),
                        track.formattedDuration,
                      ].join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurface.withValues(alpha: 0.65),
                      ),
                    ),
                    if (track.trendBadges.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: NasheedBadgeRow(track: track, compact: true),
                      ),
                    if (!track.audioAvailable)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          context.tr('nasheedAudioUnavailable'),
                          style: TextStyle(
                            fontSize: 11,
                            color: scheme.onSurface.withValues(alpha: 0.55),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    else if (isCurrent)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          context.tr(
                            isPlaying
                                ? 'nasheedNowPlaying'
                                : 'nasheedPaused',
                          ),
                          style: TextStyle(
                            fontSize: 11,
                            color: scheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                tooltip: context.tr('nasheedFavorite'),
                onPressed: () => library.toggleFavorite(track.id),
                icon: Icon(
                  favorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: favorite ? const Color(0xFFB42318) : null,
                ),
              ),
              if (track.downloadAllowed && track.audioAvailable)
                IconButton(
                  tooltip: downloaded
                      ? context.tr('nasheedDownloaded')
                      : context.tr('nasheedDownload'),
                  onPressed: downloading
                      ? null
                      : () async {
                          if (downloaded) {
                            await library.removeDownload(track.id);
                          } else {
                            await library.download(track);
                          }
                        },
                  icon: downloading
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            value: library.downloadProgress > 0
                                ? library.downloadProgress
                                : null,
                          ),
                        )
                      : Icon(
                          downloaded
                              ? Icons.download_done_rounded
                              : Icons.download_rounded,
                        ),
                ),
              if (track.hasExternalSource && !track.audioAvailable)
                IconButton(
                  tooltip: context.tr('nasheedExternalSource'),
                  onPressed: () => openNasheedExternalSource(context, track),
                  icon: const Icon(Icons.open_in_new_rounded),
                ),
              if (track.audioAvailable)
                IconButton.filledTonal(
                  tooltip: context.tr('nasheedPlay'),
                  onPressed: () async {
                    if (isPlaying) {
                      await player.pause();
                    } else if (isCurrent) {
                      await player.resume();
                    } else {
                      await library.play(track);
                    }
                  },
                  icon: Icon(
                    isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                  ),
                )
              else
                IconButton.filledTonal(
                  tooltip: context.tr('nasheedOpenDetails'),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            NasheedDetailScreen(trackId: track.id),
                      ),
                    );
                  },
                  icon: const Icon(Icons.info_outline_rounded),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.library_music_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              context.tr('nasheedEmptyTitle'),
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              context.tr('nasheedEmptyBody'),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
