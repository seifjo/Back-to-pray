import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/services/islamic_audio_player.dart';
import '../../l10n/app_localizations.dart';
import '../../models/islamic_audio.dart';
import '../../providers/nasheed_library_provider.dart';
import '../../widgets/islamic_motif.dart';

class FullAudioPlayerScreen extends StatefulWidget {
  const FullAudioPlayerScreen({super.key});

  static const routeName = '/full-audio-player';
  static final ValueNotifier<bool> visible = ValueNotifier(false);

  static bool get isVisible => visible.value;

  @override
  State<FullAudioPlayerScreen> createState() => _FullAudioPlayerScreenState();
}

class _FullAudioPlayerScreenState extends State<FullAudioPlayerScreen> {
  @override
  void initState() {
    super.initState();
    FullAudioPlayerScreen.visible.value = true;
  }

  @override
  void dispose() {
    FullAudioPlayerScreen.visible.value = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<IslamicAudioPlayer>();
    final track = player.current;
    final scheme = Theme.of(context).colorScheme;
    final english = !context.isArabic;

    if (track == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(context.tr('audioNothingPlaying'))),
      );
    }

    final totalMs = (player.duration ?? Duration.zero).inMilliseconds;
    final posMs = player.position.inMilliseconds.clamp(0, totalMs == 0 ? 0 : totalMs);
    final progress = totalMs <= 0 ? 0.0 : posMs / totalMs;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: IslamicPatternPainter(
                color: scheme.onSurface.withValues(alpha: 0.04),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  title: Text(context.tr('audioNowPlayingTitle')),
                  actions: [
                    if (track.kind == IslamicAudioKind.nasheed)
                      IconButton(
                        tooltip: context.tr('nasheedFavorite'),
                        onPressed: () {
                          context
                              .read<NasheedLibraryProvider>()
                              .toggleFavorite(track.id);
                        },
                        icon: Icon(
                          context.watch<NasheedLibraryProvider>().isFavorite(track.id)
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                        ),
                      ),
                  ],
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    children: [
                      AspectRatio(
                        aspectRatio: 1,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOutCubic,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            color: scheme.primary.withValues(alpha: 0.12),
                            boxShadow: [
                              BoxShadow(
                                color: scheme.primary.withValues(alpha: 0.18),
                                blurRadius: player.isPlaying ? 28 : 12,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Center(
                            child: track.coverAsset == null
                                ? Icon(
                                    Icons.menu_book_rounded,
                                    size: 96,
                                    color: scheme.primary,
                                  )
                                : Image.asset(
                                    track.coverAsset!,
                                    width: 160,
                                    height: 160,
                                    fit: BoxFit.contain,
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        track.title(english),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        track.artist(english),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: scheme.onSurface.withValues(alpha: 0.65),
                        ),
                      ),
                      if (player.phase == IslamicPlaybackPhase.error)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            player.error ?? context.tr('audioError'),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: scheme.error),
                          ),
                        ),
                      const SizedBox(height: 24),
                      Slider(
                        value: progress.clamp(0.0, 1.0),
                        onChanged: totalMs <= 0
                            ? null
                            : (value) {
                                player.seek(
                                  Duration(
                                    milliseconds: (value * totalMs).round(),
                                  ),
                                );
                              },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(IslamicAudioPlayer.formatClock(player.position)),
                          Text(
                            IslamicAudioPlayer.formatClock(
                              player.duration ?? Duration.zero,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            tooltip: context.tr('audioShuffle'),
                            onPressed: () => player
                                .setShuffleEnabled(!player.shuffleEnabled),
                            icon: Icon(
                              Icons.shuffle_rounded,
                              color: player.shuffleEnabled
                                  ? scheme.primary
                                  : null,
                            ),
                          ),
                          IconButton(
                            tooltip: context.tr('audioPrevious'),
                            onPressed: player.skipToPrevious,
                            icon: const Icon(Icons.skip_previous_rounded, size: 36),
                          ),
                          FilledButton(
                            style: FilledButton.styleFrom(
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(18),
                            ),
                            onPressed: player.loading
                                ? null
                                : player.togglePlayPause,
                            child: player.loading
                                ? const SizedBox(
                                    width: 28,
                                    height: 28,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Icon(
                                    player.isPlaying
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    size: 36,
                                  ),
                          ),
                          IconButton(
                            tooltip: context.tr('audioNext'),
                            onPressed: player.skipToNext,
                            icon: const Icon(Icons.skip_next_rounded, size: 36),
                          ),
                          IconButton(
                            tooltip: context.tr('audioRepeat'),
                            onPressed: player.cycleRepeatMode,
                            icon: Icon(
                              switch (player.repeatMode) {
                                IslamicRepeatMode.one => Icons.repeat_one_rounded,
                                IslamicRepeatMode.all => Icons.repeat_rounded,
                                IslamicRepeatMode.none => Icons.repeat_rounded,
                              },
                              color: player.repeatMode == IslamicRepeatMode.none
                                  ? null
                                  : scheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            tooltip: context.tr('audioSeekBack'),
                            onPressed: () => player.seekBackward(),
                            icon: const Icon(Icons.replay_10_rounded),
                          ),
                          IconButton(
                            tooltip: context.tr('audioReplay'),
                            onPressed: player.replay,
                            icon: const Icon(Icons.restart_alt_rounded),
                          ),
                          IconButton(
                            tooltip: context.tr('audioSeekForward'),
                            onPressed: () => player.seekForward(),
                            icon: const Icon(Icons.forward_10_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(context.tr('audioSleepTimer'),
                          style: Theme.of(context).textTheme.titleSmall),
                      Wrap(
                        spacing: 8,
                        children: [
                          for (final minutes in const [5, 15, 30, 45])
                            ActionChip(
                              label: Text('$minutes ${context.tr('audioMinutes')}'),
                              onPressed: () => player.startSleepTimer(
                                Duration(minutes: minutes),
                              ),
                            ),
                          if (player.sleepTimerActive)
                            ActionChip(
                              label: Text(
                                '${context.tr('audioCancelTimer')} · '
                                '${IslamicAudioPlayer.formatClock(player.sleepRemaining!)}',
                              ),
                              onPressed: player.cancelSleepTimer,
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(context.tr('audioQueue'),
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      ...List.generate(player.queue.length, (index) {
                        final item = player.queue[index];
                        final selected = index == player.queueIndex;
                        return ListTile(
                          selected: selected,
                          leading: Icon(
                            selected
                                ? Icons.equalizer_rounded
                                : Icons.music_note_outlined,
                          ),
                          title: Text(
                            item.title(english),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(item.artist(english)),
                          onTap: () => player.skipToQueueIndex(index),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
