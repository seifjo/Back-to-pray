import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/islamic_motif.dart';

class JourneyIntroScreen extends StatefulWidget {
  final VoidCallback onStart;
  final VoidCallback onSkip;

  const JourneyIntroScreen({
    super.key,
    required this.onStart,
    required this.onSkip,
  });

  @override
  State<JourneyIntroScreen> createState() => _JourneyIntroScreenState();
}

class _JourneyIntroScreenState extends State<JourneyIntroScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _scale = Tween<double>(begin: 0.86, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = isDark ? Colors.white : AppTheme.lightInk;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? const [Color(0xFF122033), Color(0xFF1A1A2E)]
                    : const [Color(0xFFF3EFE6), Color(0xFFE7F3F3)],
              ),
            ),
          ),
          CustomPaint(
            painter: IslamicPatternPainter(
              color: AppTheme.accentGold.withValues(alpha: 0.14),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: TextButton(
                          onPressed: widget.onSkip,
                          child: Text(context.tr('skip')),
                        ),
                      ),
                      const Spacer(),
                      ScaleTransition(
                        scale: _scale,
                        child: Center(
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppTheme.accentGold.withValues(alpha: 0.28),
                                  AppTheme.accentGold.withValues(alpha: 0.0),
                                ],
                              ),
                            ),
                            child: CustomPaint(
                              painter:
                                  CrescentPainter(color: AppTheme.accentGold),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _motifChip(Icons.menu_book_rounded),
                          const SizedBox(width: 10),
                          _motifChip(Icons.favorite_border_rounded),
                          const SizedBox(width: 10),
                          _motifChip(Icons.nightlight_round),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        context.tr('introTitle'),
                        textAlign: TextAlign.center,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: ink,
                                ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        context.tr('introBody'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          height: 1.6,
                          fontSize: 16,
                          color: ink.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        context.tr('introVerse'),
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: GoogleFonts.amiri(
                          fontSize: 26,
                          height: 1.8,
                          color: ink,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.tr('introReference'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppTheme.accentGold),
                      ),
                      const Spacer(),
                      FilledButton(
                        onPressed: widget.onStart,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(context.tr('startYourJourney')),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.tr('journeyIntroPrivate'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: ink.withValues(alpha: 0.55),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _motifChip(IconData icon) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.accentGold.withValues(alpha: 0.35),
        ),
      ),
      child: Icon(icon, color: AppTheme.accentGold, size: 22),
    );
  }
}
