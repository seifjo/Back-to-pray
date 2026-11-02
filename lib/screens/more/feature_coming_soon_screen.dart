import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/more_features_catalog.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/islamic_motif.dart';

/// Temporary destination for features that are not built yet.
class FeatureComingSoonScreen extends StatelessWidget {
  final MoreFeature feature;

  const FeatureComingSoonScreen({super.key, required this.feature});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(context.tr(feature.nameKey))),
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: IslamicPatternPainter(
                color: scheme.onSurface.withValues(alpha: 0.035),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 78,
                    height: 78,
                    decoration: BoxDecoration(
                      color: feature.accent.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(feature.icon, size: 36, color: feature.accent),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    context.tr('featureComingSoon'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    context.tr('featureComingSoonBody'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      height: 1.5,
                      color: scheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.tr('featureDevPlaceholder'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.accentGold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
