import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/services/islamic_audio_player.dart';
import '../../core/theme/app_theme.dart';
import '../../data/nasheed_catalog.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/nasheed_library_provider.dart';
import 'nasheed_ui_helpers.dart';

/// Detail page for a single nasheed — plays through the shared audio player.
class NasheedDetailScreen extends StatelessWidget {
  const NasheedDetailScreen({super.key, required this.trackId});

  final String trackId;

  @override
  Widget build(BuildContext context) {
    final library = context.watch<NasheedLibraryProvider>();
    final player = context.watch<IslamicAudioPlayer>();
    final track = library.byId(trackId);
    final english = !context.isArabic;
    final scheme = Theme.of(context).colorScheme;

    if (track == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(context.tr('nasheedEmptyTitle'))),
      );
    }

    final category = NasheedCatalog.categoryById(track.categoryId ?? '');
    final favorite = library.isFavorite(track.id);
    final isCurrent = player.isCurrent(track.id);
    final isPlaying = player.isPlayingTrack(track.id);
    final related = library.related(track);
    final artistLabel = track.artist(english).trim().isEmpty
        ? context.tr('nasheedArtistUnknown')
        : track.artist(english);

    return Scaffold(
      appBar: AppBar(
        title: Text(track.title(english)),
        actions: [
          IconButton(
            tooltip: context.tr('nasheedFavorite'),
            onPressed: () => library.toggleFavorite(track.id),
            icon: Icon(
              favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: favorite ? const Color(0xFFB42318) : null,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Color(category?.accent ?? 0xFF0D7377)
                    .withValues(alpha: 0.16),
                border: Border.all(
                  color: scheme.onSurface.withValues(alpha: 0.06),
                ),
              ),
              child: Center(
                child: track.coverAsset == null
                    ? Icon(Icons.music_note_rounded,
                        size: 88, color: scheme.primary)
                    : Image.asset(
                        track.coverAsset!,
                        width: 140,
                        height: 140,
                        fit: BoxFit.contain,
                      ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            track.title(english),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            artistLabel,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: scheme.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Center(child: NasheedBadgeRow(track: track)),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              if (category != null) Chip(label: Text(category.name(english))),
              Chip(label: Text(track.formattedDuration)),
              Chip(
                avatar: Icon(
                  track.audioAvailable
                      ? Icons.check_circle_outline
                      : Icons.hourglass_empty_rounded,
                  size: 18,
                ),
                label: Text(
                  track.audioAvailable
                      ? context.tr('nasheedLicensedPlayable')
                      : context.tr('nasheedAudioUnavailable'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: track.audioAvailable
                      ? () async {
                          if (isPlaying) {
                            await player.pause();
                            return;
                          }
                          if (isCurrent) {
                            await player.resume();
                            return;
                          }
                          final error = await library.play(track);
                          if (error != null && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  context.tr('nasheedUnavailableSnack'),
                                ),
                              ),
                            );
                          }
                        }
                      : null,
                  icon: Icon(
                    isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                  ),
                  label: Text(
                    !track.audioAvailable
                        ? context.tr('nasheedAudioUnavailable')
                        : isPlaying
                            ? context.tr('audioPause')
                            : context.tr('nasheedPlay'),
                  ),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              ),
              if (track.hasExternalSource) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        openNasheedExternalSource(context, track),
                    icon: const Icon(Icons.open_in_new_rounded),
                    label: Text(context.tr('nasheedExternalSource')),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (track.description(english).trim().isNotEmpty) ...[
            const SizedBox(height: 22),
            Text(
              context.tr('nasheedDescription'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              track.description(english),
              style: TextStyle(
                height: 1.45,
                color: scheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ],
          if (track.discoveryEvidence(english).trim().isNotEmpty) ...[
            const SizedBox(height: 22),
            Text(
              context.tr('nasheedDiscoveryEvidence'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              track.discoveryEvidence(english),
              style: TextStyle(
                height: 1.45,
                color: scheme.onSurface.withValues(alpha: 0.75),
              ),
            ),
          ],
          const SizedBox(height: 22),
          Text(
            context.tr('nasheedSourceLicense'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          _InfoRow(
            label: context.tr('nasheedSource'),
            value: track.sourceProvider(english).isEmpty
                ? context.tr('nasheedSourceUnknown')
                : track.sourceProvider(english),
          ),
          _InfoRow(
            label: context.tr('reference'),
            value: track.license(english),
          ),
          if (!track.audioAvailable)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                context.tr('nasheedPendingHelp'),
                style: TextStyle(
                  color: AppTheme.accentGold.withValues(alpha: 0.95),
                  height: 1.4,
                ),
              ),
            ),
          if (track.hasExternalSource && !track.audioAvailable)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                context.tr('nasheedExternalHelp'),
                style: TextStyle(
                  color: scheme.onSurface.withValues(alpha: 0.65),
                  height: 1.4,
                ),
              ),
            ),
          if (related.isNotEmpty) ...[
            const SizedBox(height: 28),
            Text(
              context.tr('nasheedRelated'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            for (final item in related.take(6))
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: scheme.primary.withValues(alpha: 0.12),
                  child: Icon(Icons.music_note, color: scheme.primary),
                ),
                title: Text(item.title(english)),
                subtitle: Text(
                  [
                    item.artist(english).trim().isEmpty
                        ? context.tr('nasheedArtistUnknown')
                        : item.artist(english),
                    item.audioAvailable
                        ? item.formattedDuration
                        : context.tr('nasheedAudioUnavailable'),
                  ].join(' · '),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => NasheedDetailScreen(trackId: item.id),
                    ),
                  );
                },
              ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: scheme.onSurface.withValues(alpha: 0.55),
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(height: 1.35)),
          ),
        ],
      ),
    );
  }
}
