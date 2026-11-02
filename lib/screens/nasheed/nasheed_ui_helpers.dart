import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../../models/islamic_audio.dart';

String nasheedBadgeLabel(BuildContext context, NasheedTrendBadge badge) {
  switch (badge) {
    case NasheedTrendBadge.trending:
      return context.tr('nasheedBadgeTrending');
    case NasheedTrendBadge.popular:
      return context.tr('nasheedBadgePopular');
    case NasheedTrendBadge.newRelease:
      return context.tr('nasheedBadgeNew');
    case NasheedTrendBadge.recommended:
      return context.tr('nasheedBadgeRecommended');
    case NasheedTrendBadge.shortForm:
      return context.tr('nasheedBadgeShortForm');
  }
}

Future<void> openNasheedExternalSource(
  BuildContext context,
  IslamicAudioTrack track,
) async {
  final raw = track.externalPageUrl?.trim();
  if (raw == null || raw.isEmpty) return;
  final uri = Uri.tryParse(raw);
  if (uri == null) return;
  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.tr('nasheedUnavailableSnack'))),
    );
  }
}

class NasheedBadgeRow extends StatelessWidget {
  const NasheedBadgeRow({
    super.key,
    required this.track,
    this.compact = false,
  });

  final IslamicAudioTrack track;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (track.trendBadges.isEmpty) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        for (final badge in track.trendBadges.take(compact ? 2 : 4))
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 6 : 8,
              vertical: compact ? 2 : 3,
            ),
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              nasheedBadgeLabel(context, badge),
              style: TextStyle(
                fontSize: compact ? 9 : 11,
                fontWeight: FontWeight.w700,
                color: scheme.primary,
              ),
            ),
          ),
      ],
    );
  }
}
