import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';

/// Quran Audio Service
/// Handles Quran recitation audio using Quran.com API.
class QuranAudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool get isPlaying => _audioPlayer.playing;
  Stream<bool> get playingStream => _audioPlayer.playingStream;
  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;

  /// Play a specific ayah recitation
  Future<void> playAyah(int surahNumber, int ayahNumber) async {
    try {
      final url =
          'https://cdn.islamic.network/quran/audio/128/ar.alafasy/${_getAbsoluteAyahNumber(surahNumber, ayahNumber)}.mp3';

      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();
    } catch (e) {
      debugPrint('Audio Error: $e');
    }
  }

  /// Play full surah recitation
  Future<void> playSurah(int surahNumber) async {
    try {
      // Using everyayah.com CDN for full surah
      final paddedSurah = surahNumber.toString().padLeft(3, '0');
      final url = 'https://server8.mp3quran.net/afs/$paddedSurah.mp3';

      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();
    } catch (e) {
      debugPrint('Surah Audio Error: $e');
    }
  }

  /// Pause playback
  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  /// Resume playback
  Future<void> resume() async {
    await _audioPlayer.play();
  }

  /// Stop playback
  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  /// Toggle play/pause
  Future<void> togglePlayPause() async {
    if (_audioPlayer.playing) {
      await pause();
    } else {
      await resume();
    }
  }

  /// Calculate absolute ayah number (1-indexed across entire Quran)
  int _getAbsoluteAyahNumber(int surahNumber, int ayahNumber) {
    // Ayahs per surah (Al-Fatiha = index 0)
    const ayahsPerSurah = [
      7,
      286,
      200,
      176,
      120,
      165,
      206,
      75,
      129,
      109,
      123,
      111,
      43,
      52,
      99,
      128,
      111,
      110,
      98,
      135,
      112,
      78,
      118,
      64,
      77,
      227,
      93,
      88,
      69,
      60,
      34,
      30,
      73,
      54,
      45,
      83,
      182,
      88,
      75,
      85,
      54,
      53,
      89,
      59,
      37,
      35,
      38,
      29,
      18,
      45,
      60,
      49,
      62,
      55,
      78,
      96,
      29,
      22,
      24,
      13,
      14,
      11,
      11,
      18,
      12,
      12,
      30,
      52,
      52,
      44,
      28,
      28,
      20,
      56,
      40,
      31,
      50,
      40,
      46,
      42,
      29,
      19,
      36,
      25,
      22,
      17,
      19,
      26,
      30,
      20,
      15,
      21,
      11,
      8,
      8,
      19,
      5,
      8,
      8,
      11,
      11,
      8,
      3,
      9,
      5,
      4,
      7,
      3,
      6,
      3,
      5,
      4,
      5,
      6,
    ];

    int absolute = 0;
    for (int i = 0; i < surahNumber - 1; i++) {
      absolute += ayahsPerSurah[i];
    }
    absolute += ayahNumber;
    return absolute;
  }

  /// Dispose the audio player
  void dispose() {
    _audioPlayer.dispose();
  }
}
