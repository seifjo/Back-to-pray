import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';
import '../../data/spiritual_journey_catalog.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/islamic_motif.dart';

class JourneyCompletionScreen extends StatelessWidget {
  final String journeyId;

  const JourneyCompletionScreen({super.key, required this.journeyId});

  @override
  Widget build(BuildContext context) {
    final journey = SpiritualJourneyCatalog.byId(journeyId);
    final english = !context.isArabic;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.primaryGreen.withValues(alpha: 0.18),
                  scheme.surface,
                ],
              ),
            ),
          ),
          CustomPaint(
            painter: IslamicPatternPainter(
              color: scheme.onSurface.withValues(alpha: 0.04),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Spacer(),
                  Text(
                    journey?.icon ?? '✦',
                    style: const TextStyle(fontSize: 56),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.tr('journeyCompletedTitle'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    journey?.title(english) ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.accentGold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.tr('journeyCompletedBody'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      height: 1.55,
                      color: scheme.onSurface.withValues(alpha: 0.75),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    context.tr('introVerse'),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: GoogleFonts.amiri(fontSize: 24, height: 1.7),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(context.tr('backToJourneys')),
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
