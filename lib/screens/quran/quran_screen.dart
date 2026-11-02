import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/services/islamic_audio_player.dart';
import '../../core/services/quran_audio_catalog.dart';
import '../../core/services/quran_offline_store.dart';
import '../../core/services/quran_service.dart';
import '../../models/islamic_audio.dart';
import '../../models/quran.dart';
import '../../core/theme/app_theme.dart';
import '../../data/quran_data.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/app_settings_provider.dart';
import '../../providers/quran_audio_settings_provider.dart';
import '../../providers/quran_provider.dart';
import '../../providers/daily_achievements_provider.dart';
import '../../providers/quran_race_provider.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  final QuranService _quranService = QuranService();
  late Future<List<Surah>> _surahsFuture;
  final Set<int> _savedSurahs = {};
  int? _savingSurah;
  String? _trackedReciterId;

  @override
  void initState() {
    super.initState();
    _surahsFuture = Future.value(QuranData.surahs);
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshSaved());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reciterId = context.watch<QuranAudioSettingsProvider>().reciterId;
    if (_trackedReciterId != reciterId) {
      _trackedReciterId = reciterId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _refreshSaved();
      });
    }
  }

  Future<void> _refreshSaved() async {
    final reciterId = context.read<QuranAudioSettingsProvider>().reciterId;
    final saved = <int>{};
    for (var number = 1; number <= 114; number++) {
      if (await QuranOfflineStore.isSaved(number, reciterId: reciterId)) {
        saved.add(number);
      }
    }
    if (mounted) {
      setState(() {
        _savedSurahs
          ..clear()
          ..addAll(saved);
      });
    }
  }

  Future<void> _playSurah(Surah surah) async {
    final player = context.read<IslamicAudioPlayer>();
    final audioSettings = context.read<QuranAudioSettingsProvider>();
    final reciter = audioSettings.reciter;
    final currentId = 'quran_surah_${surah.number}';
    final sameReciter =
        player.current?.extras['reciterId'] == reciter.id;

    if (player.isCurrent(currentId) && sameReciter) {
      await player.togglePlayPause();
      return;
    }

    if (!reciter.surahAvailable) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('reciterSurahUnavailable'))),
      );
      return;
    }

    final queue = QuranAudioCatalog.surahQueueFrom(
      QuranData.surahs,
      surah.number,
      reciter: reciter,
      includeFollowing: audioSettings.autoPlayNextSurah,
    );
    if (queue.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('reciterSurahUnavailable'))),
      );
      return;
    }

    final localPaths = <String, String?>{};
    for (final track in queue.take(5)) {
      final number = int.tryParse(track.extras['surahNumber'] ?? '');
      if (number != null &&
          await QuranOfflineStore.isSaved(number, reciterId: reciter.id)) {
        localPaths[track.id] =
            (await QuranOfflineStore.fileFor(number, reciterId: reciter.id))
                .path;
      }
    }
    if (await QuranOfflineStore.isSaved(surah.number, reciterId: reciter.id)) {
      localPaths[currentId] =
          (await QuranOfflineStore.fileFor(surah.number, reciterId: reciter.id))
              .path;
    }
    await player.playQueue(
      queue,
      startIndex: 0,
      localPaths: localPaths,
    );
  }

  Future<void> _saveOne(int number) async {
    if (_savedSurahs.contains(number)) return;
    final audioSettings = context.read<QuranAudioSettingsProvider>();
    if (!audioSettings.offlineDownloadsEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('quranOfflineDisabled'))),
      );
      return;
    }
    if (!audioSettings.reciter.surahAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('reciterSurahUnavailable'))),
      );
      return;
    }
    setState(() => _savingSurah = number);
    try {
      QuranOfflineStore.cancelAll = false;
      await QuranOfflineStore.downloadSurah(
        number,
        reciter: audioSettings.reciter,
      );
      if (mounted) setState(() => _savedSurahs.add(number));
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('error'))),
        );
      }
    } finally {
      if (mounted) setState(() => _savingSurah = null);
    }
  }

  void _stopAudio() {
    context.read<IslamicAudioPlayer>().clear();
  }

  Future<void> _openOfflineSaver() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _QuranDownloadDialog(),
    );
    await _refreshSaved();
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<IslamicAudioPlayer>();
    final playingSurah = player.current?.id.startsWith('quran_surah_') == true
        ? int.tryParse(player.current?.extras['surahNumber'] ?? '')
        : null;
    final isPlayingSurah = playingSurah != null && player.isPlaying;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('quranTitle'), style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: context.tr('saveQuran'),
            onPressed: _openOfflineSaver,
            icon: const Icon(Icons.download_for_offline_outlined),
          ),
        ],
        bottom: playingSurah != null ? PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            color: AppTheme.primaryGreen.withValues(alpha: 0.15),
            child: Row(
              children: [
                Icon(Icons.headphones, size: 16, color: AppTheme.primaryGreen),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'يُشغَّل: ${QuranData.surahs.firstWhere((s) => s.number == playingSurah).name}',
                    style: TextStyle(fontSize: 13, color: AppTheme.primaryGreen, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isPlayingSurah ? Icons.pause_circle : Icons.play_circle,
                    color: AppTheme.primaryGreen,
                  ),
                  onPressed: () => _playSurah(QuranData.surahs.firstWhere((s) => s.number == playingSurah)),
                ),
                IconButton(
                  icon: const Icon(Icons.stop_circle, color: Colors.red),
                  onPressed: _stopAudio,
                ),
              ],
            ),
          ),
        ) : null,
      ),
      body: FutureBuilder<List<Surah>>(
        future: _surahsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('خطأ في تحميل قائمة السور'),
                  ElevatedButton(
                    onPressed: () => setState(() => _surahsFuture = _quranService.getAllSurahs()),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          final surahs = snapshot.data!;
          return Column(
            children: [
              Consumer<QuranProvider>(
                builder: (context, quranProvider, child) {
                  if (quranProvider.lastSurahNumber == null) return const SizedBox.shrink();
                  
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                      child: ListTile(
                        leading: const Icon(Icons.bookmark, color: AppTheme.primaryGreen),
                        title: const Text('مواصلة القراءة', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('سورة ${quranProvider.lastSurahName} - آية ${quranProvider.lastAyahNumber}'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          final surah = QuranData.surahs.firstWhere(
                            (s) => s.number == quranProvider.lastSurahNumber,
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SurahDetailScreen(surah: surah)),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: surahs.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    final surah = surahs[index];
                    final isThisSurahPlaying = playingSurah == surah.number;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isThisSurahPlaying
                              ? AppTheme.accentGold
                              : AppTheme.primaryGreen,
                          child: isThisSurahPlaying && isPlayingSurah
                              ? const Icon(Icons.graphic_eq, color: Colors.white, size: 20)
                              : Text(
                                  '${surah.number}',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                        ),
                        title: Text(
                          context.isArabic ? surah.name : surah.englishName,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.right,
                        ),
                        subtitle: Text(
                          context.isArabic ? surah.englishName : surah.name,
                          textAlign: TextAlign.right,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: _savedSurahs.contains(surah.number)
                                  ? context.tr('audioSaved')
                                  : context.tr('saveQuran'),
                              icon: _savingSurah == surah.number
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : Icon(
                                      _savedSurahs.contains(surah.number)
                                          ? Icons.offline_pin
                                          : Icons.download_outlined,
                                      color: _savedSurahs.contains(surah.number)
                                          ? AppTheme.primaryGreen
                                          : Colors.grey,
                                    ),
                              onPressed: _savingSurah == null
                                  ? () => _saveOne(surah.number)
                                  : null,
                            ),
                            IconButton(
                              icon: Icon(
                                isThisSurahPlaying && isPlayingSurah
                                    ? Icons.pause_circle_filled
                                    : Icons.play_circle_filled,
                                color: isThisSurahPlaying
                                    ? AppTheme.primaryGreen
                                    : Colors.grey.withValues(alpha: 0.5),
                                size: 32,
                              ),
                              onPressed: () => _playSurah(surah),
                            ),
                            const Icon(Icons.keyboard_arrow_left),
                          ],
                        ),
                        onTap: () {
                          _stopAudio(); // stop audio when navigating in
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SurahDetailScreen(surah: surah)),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class SurahDetailScreen extends StatefulWidget {
  final Surah surah;

  const SurahDetailScreen({super.key, required this.surah});

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> with WidgetsBindingObserver {
  final QuranService _quranService = QuranService();
  late Future<Surah> _detailFuture;
  late ScrollController _scrollController;
  bool _isAutoScrolling = false;
  Timer? _scrollDebounce;
  int _ayahCount = 0;

  // Safe reference for dispose()
  late QuranRaceProvider _raceProvider;

  @override
  void initState() {
    super.initState();
    _raceProvider = context.read<QuranRaceProvider>();
    
    WidgetsBinding.instance.addObserver(this);
    _detailFuture = _quranService.getSurahDetail(widget.surah.number);
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    
    // Auto-complete daily reading achievement + sync race progress
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkDailyAchievements();
      // Set status to "Reading Now" for Quran Race
      _raceProvider.setReadingStatus(true);
      // Immediately sync current surah position to race rooms
      _syncInitialProgress();
    });
  }

  @override
  void dispose() {
    _scrollDebounce?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    // User stopped reading
    _raceProvider.setReadingStatus(false);
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _raceProvider.setReadingStatus(false);
    } else if (state == AppLifecycleState.resumed) {
      _raceProvider.setReadingStatus(true);
    }
  }

  /// Sync the user's progress when they first open this surah
  void _syncInitialProgress() {
    if (!mounted) return;
    final quranProvider = Provider.of<QuranProvider>(context, listen: false);
    final ayah = quranProvider.lastAyahNumber ?? 1;
    
    // Broadcast to race rooms that user is reading this surah
    _raceProvider.updateMyProgress(
      surahNumber: widget.surah.number,
      ayahNumber: ayah,
      surahName: widget.surah.name,
    );
  }

  void _onScroll() {
    // Keep empty as we removed auto-save on scroll per user request
    if (_isAutoScrolling || _ayahCount == 0) return;
  }

  void _toggleBookmark(int index, {bool showMessage = false}) {
    if (!mounted) return;
    final quranProvider = Provider.of<QuranProvider>(context, listen: false);
    
    // Check if this ayah is already bookmarked
    final isBookmarked = quranProvider.lastSurahNumber == widget.surah.number && 
                         quranProvider.lastAyahNumber == index + 1;

    if (isBookmarked) {
      quranProvider.clearLastRead();
      if (showMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إزالة العلامة'),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      quranProvider.saveLastRead(
        widget.surah.number,
        index + 1,
        widget.surah.name,
      );
      // Also broadcast bookmark position to race rooms
      if (mounted) {
        context.read<QuranRaceProvider>().updateMyProgress(
          surahNumber: widget.surah.number,
          ayahNumber: index + 1,
          surahName: widget.surah.name,
        );
      }
      if (showMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم حفظ العلامة: آية ${index + 1}'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
      }
    }
  }

  void _checkDailyAchievements() async {
    if (!mounted) return;
    
    try {
      final dailyProvider = Provider.of<DailyAchievementsProvider>(context, listen: false);
      
      // Complete "Daily Read" achievement
      final result = await dailyProvider.completeAchievement('quran_daily_read');
      
      // Show snackbar only if newly completed
      if (result['success'] == true && result['isNewRecord'] == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 إنجاز يومي: قراءة قرآن!'),
            backgroundColor: AppTheme.accentGold,
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error marking achievement: $e');
    }
  }

  /// Play or pause a specific ayah audio via the global player.
  Future<void> _playAyah(int index, int ayahNumber) async {
    final player = context.read<IslamicAudioPlayer>();
    final audioSettings = context.read<QuranAudioSettingsProvider>();
    final reciter = audioSettings.reciter;
    final absolute =
        QuranAudioCatalog.absoluteAyahNumber(widget.surah.number, ayahNumber);
    final trackId = 'quran_ayah_$absolute';
    final sameReciter = player.current?.extras['reciterId'] == reciter.id;

    if (player.isCurrent(trackId) && sameReciter) {
      await player.togglePlayPause();
      return;
    }

    if (!reciter.hasAyahAudio) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('reciterAyahUnavailable'))),
      );
      return;
    }

    final quality = reciter.resolveAyahBitrate(audioSettings.ayahQualityKbps) ??
        audioSettings.ayahQualityKbps;
    final track = QuranAudioCatalog.ayah(
      surahNumber: widget.surah.number,
      surahNameEn: widget.surah.englishName,
      surahNameAr: widget.surah.name,
      ayahNumber: ayahNumber,
      absoluteAyah: absolute,
      reciter: reciter,
      qualityKbps: quality,
    );
    if (track == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('reciterAyahUnavailable'))),
      );
      return;
    }

    String? localPath;
    if (await QuranOfflineStore.isAyahSaved(
      absolute,
      reciterId: reciter.id,
      qualityKbps: quality,
    )) {
      localPath = (await QuranOfflineStore.ayahFile(
        absolute,
        reciterId: reciter.id,
        qualityKbps: quality,
      ))
          .path;
    } else if (audioSettings.offlineDownloadsEnabled) {
      QuranOfflineStore.downloadAyah(
        absolute,
        reciter: reciter,
        qualityKbps: quality,
      );
    }
    await player.playTrack(track, localFilePath: localPath);
  }

  void _stopAudio() {
    context.read<IslamicAudioPlayer>().clear();
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<IslamicAudioPlayer>();
    final currentAyah = player.current?.kind == IslamicAudioKind.quran
        ? int.tryParse(player.current?.extras['ayahNumber'] ?? '')
        : null;
    final currentSurah = int.tryParse(player.current?.extras['surahNumber'] ?? '');
    final playingAyahIndex =
        currentSurah == widget.surah.number && currentAyah != null
            ? currentAyah - 1
            : null;
    final isAudioPlaying = playingAyahIndex != null && player.isPlaying;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.surah.name),
        bottom: playingAyahIndex != null ? PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.headphones, size: 16, color: AppTheme.primaryGreen),
                const SizedBox(width: 8),
                Text(
                  'يُشغَّل: الآية ${playingAyahIndex + 1}',
                  style: TextStyle(fontSize: 13, color: AppTheme.primaryGreen, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    isAudioPlaying ? Icons.pause_circle : Icons.play_circle,
                    color: AppTheme.primaryGreen,
                  ),
                  onPressed: () => _playAyah(playingAyahIndex, playingAyahIndex + 1),
                ),
                IconButton(
                  icon: const Icon(Icons.stop_circle, color: Colors.red),
                  onPressed: _stopAudio,
                ),
              ],
            ),
          ),
        ) : null,
      ),
      body: FutureBuilder<Surah>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('خطأ في تحميل السورة'));
          }

          final fullSurah = snapshot.data!;
          
          final lastAyah = Provider.of<QuranProvider>(context, listen: false).lastAyahNumber;
          final lastSurah = Provider.of<QuranProvider>(context, listen: false).lastSurahNumber;
          
          if (lastSurah == widget.surah.number && lastAyah != null && !_isAutoScrolling) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients) {
                _isAutoScrolling = true;
                final targetIndex = lastAyah - 1;
                _scrollController.jumpTo(targetIndex * 200.0);
                _isAutoScrolling = false;
              }
            });
          }

          // Store ayah count for scroll-based tracking
          _ayahCount = fullSurah.ayahs.length;
          
          return ListView.builder(
            controller: _scrollController,
            itemCount: fullSurah.ayahs.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final ayah = fullSurah.ayahs[index];
              return Consumer<QuranProvider>(
                  builder: (context, quranProvider, child) {
                    final isBookmarked = quranProvider.lastSurahNumber == widget.surah.number && 
                                         quranProvider.lastAyahNumber == index + 1;
                                         
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isBookmarked ? AppTheme.primaryGreen.withValues(alpha: 0.1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isBookmarked ? AppTheme.primaryGreen.withValues(alpha: 0.3) : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Bookmark + Audio buttons
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                      size: 24,
                                      color: isBookmarked ? AppTheme.accentGold : Colors.grey.withValues(alpha: 0.5),
                                    ),
                                    onPressed: () => _toggleBookmark(index, showMessage: true),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      playingAyahIndex == index && isAudioPlaying
                                          ? Icons.pause_circle_filled
                                          : Icons.play_circle_filled,
                                      size: 28,
                                      color: playingAyahIndex == index
                                          ? AppTheme.primaryGreen
                                          : Colors.grey.withValues(alpha: 0.5),
                                    ),
                                    onPressed: () => _playAyah(index, ayah.number),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentGold.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  'الآية ${ayah.number}',
                                  style: const TextStyle(
                                    color: AppTheme.accentGold,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            ayah.text,
                            style: GoogleFonts.amiri(
                              fontSize: context.watch<AppSettingsProvider>().adhkarFontSize,
                              height: 1.9,
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                          ),
                        ],
                      ),
                    );
                  },
                );
            },
          );
        },
      ),
    );
  }
}

class _QuranDownloadDialog extends StatefulWidget {
  const _QuranDownloadDialog();

  @override
  State<_QuranDownloadDialog> createState() => _QuranDownloadDialogState();
}

class _QuranDownloadDialogState extends State<_QuranDownloadDialog> {
  bool _running = false;
  int _done = 0;
  int _current = 0;
  double _fraction = 0;
  bool _finished = false;

  Future<void> _start() async {
    final audioSettings = context.read<QuranAudioSettingsProvider>();
    if (!audioSettings.offlineDownloadsEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('quranOfflineDisabled'))),
      );
      return;
    }
    if (!audioSettings.reciter.surahAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('reciterSurahUnavailable'))),
      );
      return;
    }
    final reciter = audioSettings.reciter;
    setState(() {
      _running = true;
      _finished = false;
      _done = 0;
    });
    QuranOfflineStore.cancelAll = false;
    for (var number = 1; number <= 114; number++) {
      if (!mounted || QuranOfflineStore.cancelAll) break;
      setState(() {
        _current = number;
        _fraction = 0;
      });
      if (await QuranOfflineStore.isSaved(number, reciterId: reciter.id)) {
        setState(() => _done++);
        continue;
      }
      try {
        await QuranOfflineStore.downloadSurah(
          number,
          reciter: reciter,
          onProgress: (progress) {
            if (mounted) setState(() => _fraction = progress);
          },
        );
      } catch (_) {
        if (mounted) {
          setState(() => _running = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.tr('error'))),
          );
        }
        return;
      }
      if (mounted && !QuranOfflineStore.cancelAll) {
        setState(() => _done++);
      }
    }
    if (mounted) {
      setState(() {
        _running = false;
        _finished = !QuranOfflineStore.cancelAll;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.tr('saveQuran')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.tr('quranTextReady')),
          const SizedBox(height: 12),
          Text(context.tr('saveAudioHelp')),
          if (_running || _finished) ...[
            const SizedBox(height: 16),
            Text('${context.tr('savingSurah')} $_current  •  $_done / 114'),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: _running ? _fraction : 1),
          ],
          if (_finished) ...[
            const SizedBox(height: 12),
            Text(context.tr('audioSaved')),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            QuranOfflineStore.cancelAll = true;
            Navigator.pop(context);
          },
          child: Text(_running ? context.tr('cancelDownload') : context.tr('close')),
        ),
        if (!_running && !_finished)
          FilledButton(
            onPressed: _start,
            child: Text(context.tr('saveAudio')),
          ),
      ],
    );
  }
}
