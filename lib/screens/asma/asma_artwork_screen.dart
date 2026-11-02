import 'package:flutter/material.dart';

import '../../data/asma_ul_husna.dart';
import '../../l10n/app_localizations.dart';

/// Full-screen decorative grid artwork for the Beautiful Names.
class AsmaArtworkScreen extends StatelessWidget {
  const AsmaArtworkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4A1C1C),
      appBar: AppBar(
        title: Text(context.tr('asmaArtworkTitle')),
        backgroundColor: Colors.black.withValues(alpha: 0.25),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              context.tr('asmaArtworkHelp'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFE8D5A3),
                height: 1.4,
              ),
            ),
          ),
          Expanded(
            child: InteractiveViewer(
              minScale: 0.8,
              maxScale: 4,
              child: Center(
                child: Image.asset(
                  AsmaUlHusna.artworkAsset,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Padding(
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
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Text(
                context.tr('asmaArtworkNote'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: const Color(0xFFE8D5A3).withValues(alpha: 0.75),
                  height: 1.35,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
