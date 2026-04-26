import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import '../../core/services/quran_service.dart';
import '../../models/quran.dart';
import '../../core/theme/app_theme.dart';
import '../../data/quran_data.dart';
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

  // Audio player for full surah playback
  final AudioPlayer _audioPlayer = AudioPlayer();
  int? _playingSurahNumber;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _surahsFuture = Future.value(QuranData.surahs);
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playSurah(Surah surah) async {
    // Same surah: toggle pause/resume
    if (_playingSurahNumber == surah.number) {
      if (_isPlaying) {
        await _audioPlayer.pause();
        setState(() => _isPlaying = false);
      } else {
        await _audioPlayer.play();
        setState(() => _isPlaying = true);
      }
      return;
    }

    setState(() { _playingSurahNumber = surah.number; _isPlaying = true; });

    try {
      // CDN full surah MP3: everyayah.com / mp3quran.net
      final paddedNum = surah.number.toString().padLeft(3, '0');
      final url = 'https://server8.mp3quran.net/afs/$paddedNum.mp3';
      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();

      _audioPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          if (mounted) setState(() => _isPlaying = false);
        }
      });
    } catch (e) {
      debugPrint('Surah audio error: $e');
      if (mounted) setState(() { _playingSurahNumber = null; _isPlaying = false; });
    }
  }

  void _stopAudio() {
    _audioPlayer.stop();
    setState(() { _playingSurahNumber = null; _isPlaying = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('القرآن الكريم', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: _playingSurahNumber != null ? PreferredSize(
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
                    'يُشغَّل: ${QuranData.surahs.firstWhere((s) => s.number == _playingSurahNumber).name}',
                    style: TextStyle(fontSize: 13, color: AppTheme.primaryGreen, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.pause_circle : Icons.play_circle,
                    color: AppTheme.primaryGreen,
                  ),
                  onPressed: () => _playSurah(QuranData.surahs.firstWhere((s) => s.number == _playingSurahNumber)),
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
                    final isThisSurahPlaying = _playingSurahNumber == surah.number;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isThisSurahPlaying
                              ? AppTheme.accentGold
                              : AppTheme.primaryGreen,
                          child: isThisSurahPlaying && _isPlaying
                              ? const Icon(Icons.graphic_eq, color: Colors.white, size: 20)
                              : Text(
                                  '${surah.number}',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                        ),
                        title: Text(
                          surah.name,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.right,
                        ),
                        subtitle: Text(surah.englishName, textAlign: TextAlign.right),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Audio play button
                            IconButton(
                              icon: Icon(
                                isThisSurahPlaying && _isPlaying
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
  
  // Audio player
  final AudioPlayer _audioPlayer = AudioPlayer();
  int? _playingAyahIndex;
  bool _isAudioPlaying = false;

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
    _audioPlayer.stop();
    _audioPlayer.dispose();
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

  /// Play or pause a specific ayah audio
  Future<void> _playAyah(int index, int ayahNumber) async {
    if (_playingAyahIndex == index && _isAudioPlaying) {
      await _audioPlayer.pause();
      setState(() => _isAudioPlaying = false);
      return;
    }
    if (_playingAyahIndex == index && !_isAudioPlaying) {
      await _audioPlayer.play();
      setState(() => _isAudioPlaying = true);
      return;
    }

    setState(() { _playingAyahIndex = index; _isAudioPlaying = true; });

    try {
      final absolute = _getAbsoluteAyahNumber(widget.surah.number, ayahNumber);
      final url = 'https://cdn.islamic.network/quran/audio/128/ar.alafasy/$absolute.mp3';
      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();

      _audioPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          if (mounted) setState(() => _isAudioPlaying = false);
        }
      });
    } catch (e) {
      debugPrint('Audio error: $e');
      if (mounted) setState(() { _playingAyahIndex = null; _isAudioPlaying = false; });
    }
  }

  int _getAbsoluteAyahNumber(int surahNumber, int ayahNumber) {
    const ayahsPerSurah = [
      7,286,200,176,120,165,206,75,129,109,123,111,43,52,99,128,111,110,98,135,
      112,78,118,64,77,227,93,88,69,60,34,30,73,54,45,83,182,88,75,85,
      54,53,89,59,37,35,38,29,18,45,60,49,62,55,78,96,29,22,24,13,
      14,11,11,18,12,12,30,52,52,44,28,28,20,56,40,31,50,40,46,42,
      29,19,36,25,22,17,19,26,30,20,15,21,11,8,8,19,5,8,8,11,
      11,8,3,9,5,4,7,3,6,3,5,4,5,6,
    ];
    int absolute = 0;
    for (int i = 0; i < surahNumber - 1; i++) absolute += ayahsPerSurah[i];
    return absolute + ayahNumber;
  }

  void _stopAudio() {
    _audioPlayer.stop();
    setState(() { _playingAyahIndex = null; _isAudioPlaying = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.surah.name),
        bottom: _playingAyahIndex != null ? PreferredSize(
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
                  'يُشغَّل: الآية ${_playingAyahIndex! + 1}',
                  style: TextStyle(fontSize: 13, color: AppTheme.primaryGreen, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    _isAudioPlaying ? Icons.pause_circle : Icons.play_circle,
                    color: AppTheme.primaryGreen,
                  ),
                  onPressed: () => _playAyah(_playingAyahIndex!, _playingAyahIndex! + 1),
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
                                      _playingAyahIndex == index && _isAudioPlaying
                                          ? Icons.pause_circle_filled
                                          : Icons.play_circle_filled,
                                      size: 28,
                                      color: _playingAyahIndex == index
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
                            style: AppTheme.quranArabic,
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
