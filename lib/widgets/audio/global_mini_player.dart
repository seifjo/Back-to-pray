import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/navigation/app_navigator.dart';
import '../../core/services/islamic_audio_player.dart';
import '../../l10n/app_localizations.dart';
import '../../models/islamic_audio.dart';
import '../../screens/audio/full_audio_player_screen.dart';

/// Persistent mini player shown above the bottom navigation across the app.
class GlobalMiniPlayer extends StatelessWidget {
  const GlobalMiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<IslamicAudioPlayer>();
    final track = player.current;
    if (track == null || player.phase == IslamicPlaybackPhase.idle) {
      return const SizedBox.shrink();
    }

    final english = !context.isArabic;
    final scheme = Theme.of(context).colorScheme;
    final total = player.duration ?? Duration.zero;
    final progress = total.inMilliseconds <= 0
        ? 0.0
        : (player.position.inMilliseconds / total.inMilliseconds)
            .clamp(0.0, 1.0);

    return Material(
      elevation: 10,
      color: scheme.surface,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LinearProgressIndicator(
              value: player.loading ? null : progress,
              minHeight: 2,
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              onTap: _openFull,
              leading: _CoverThumb(track: track),
              title: Text(
                track.title(english),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                '${track.artist(english)} · '
                '${IslamicAudioPlayer.formatClock(player.position)} / '
                '${IslamicAudioPlayer.formatClock(total)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (player.loading)
                    const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    IconButton(
                      tooltip: context.tr(
                        player.isPlaying ? 'audioPause' : 'audioPlay',
                      ),
                      onPressed: player.togglePlayPause,
                      icon: Icon(
                        player.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                      ),
                    ),
                  IconButton(
                    tooltip: context.tr('audioExpand'),
                    onPressed: _openFull,
                    icon: const Icon(Icons.open_in_full_rounded),
                  ),
                  IconButton(
                    tooltip: context.tr('audioClose'),
                    onPressed: player.clear,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openFull() {
    final nav = appNavigatorKey.currentState;
    if (nav == null) return;
    if (FullAudioPlayerScreen.isVisible) return;
    nav.push(
      PageRouteBuilder<void>(
        settings: const RouteSettings(name: FullAudioPlayerScreen.routeName),
        pageBuilder: (_, __, ___) => const FullAudioPlayerScreen(),
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.08),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 320),
      ),
    );
  }
}

class _CoverThumb extends StatelessWidget {
  const _CoverThumb({required this.track});

  final IslamicAudioTrack track;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: ColoredBox(
        color: scheme.primary.withValues(alpha: 0.12),
        child: SizedBox(
          width: 48,
          height: 48,
          child: track.coverAsset != null
              ? Image.asset(track.coverAsset!, fit: BoxFit.contain)
              : Icon(Icons.music_note_rounded, color: scheme.primary),
        ),
      ),
    );
  }
}

/// Wraps a route child with the persistent mini player docked at the bottom.
class GlobalAudioShell extends StatelessWidget {
  const GlobalAudioShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final player = context.watch<IslamicAudioPlayer>();

    return ValueListenableBuilder<bool>(
      valueListenable: FullAudioPlayerScreen.visible,
      builder: (context, fullVisible, _) {
        final showMini = player.hasTrack &&
            player.phase != IslamicPlaybackPhase.idle &&
            !fullVisible;

        return Column(
          children: [
            Expanded(child: child),
            if (showMini) const GlobalMiniPlayer(),
          ],
        );
      },
    );
  }
}
