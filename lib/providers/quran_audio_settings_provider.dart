import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/quran_reciters_catalog.dart';
import '../models/quran_reciter.dart';

/// Persists Quran playback preferences: reciter, ayah quality, auto-play next.
class QuranAudioSettingsProvider extends ChangeNotifier {
  static const _reciterKey = 'quran_audio_reciter_id';
  static const _qualityKey = 'quran_audio_quality_kbps';
  static const _autoPlayKey = 'quran_audio_autoplay_next_surah';
  static const _offlinePromptKey = 'quran_audio_offline_enabled';

  String _reciterId = QuranRecitersCatalog.defaultReciterId;
  int _ayahQualityKbps = 128;
  bool _autoPlayNextSurah = true;
  bool _offlineDownloadsEnabled = true;
  bool _loaded = false;

  String get reciterId => _reciterId;
  QuranReciter get reciter => QuranRecitersCatalog.byId(_reciterId);
  int get ayahQualityKbps => _ayahQualityKbps;
  bool get autoPlayNextSurah => _autoPlayNextSurah;
  bool get offlineDownloadsEnabled => _offlineDownloadsEnabled;
  bool get isLoaded => _loaded;

  QuranAudioSettingsProvider() {
    load();
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final storedId = prefs.getString(_reciterKey);
    if (storedId != null && QuranRecitersCatalog.isKnown(storedId)) {
      _reciterId = storedId;
    } else {
      _reciterId = QuranRecitersCatalog.defaultReciterId;
    }
    final quality = prefs.getInt(_qualityKey) ?? 128;
    _ayahQualityKbps = quality == 64 ? 64 : 128;
    _autoPlayNextSurah = prefs.getBool(_autoPlayKey) ?? true;
    _offlineDownloadsEnabled = prefs.getBool(_offlinePromptKey) ?? true;
    _loaded = true;
    notifyListeners();
  }

  Future<void> setReciterId(String id) async {
    if (!QuranRecitersCatalog.isKnown(id)) return;
    if (_reciterId == id) return;
    _reciterId = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_reciterKey, id);
    // Clamp quality to what this reciter supports for ayah audio.
    final resolved = reciter.resolveAyahBitrate(_ayahQualityKbps);
    if (resolved != null && resolved != _ayahQualityKbps) {
      _ayahQualityKbps = resolved;
      await prefs.setInt(_qualityKey, _ayahQualityKbps);
    }
    notifyListeners();
  }

  Future<void> setAyahQualityKbps(int kbps) async {
    if (kbps != 64 && kbps != 128) return;
    if (!reciter.supportsAyahQuality(kbps) && reciter.hasAyahAudio) {
      // Do not apply unsupported quality; keep current preference visible.
      return;
    }
    if (_ayahQualityKbps == kbps) return;
    _ayahQualityKbps = kbps;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_qualityKey, kbps);
    notifyListeners();
  }

  Future<void> setAutoPlayNextSurah(bool value) async {
    if (_autoPlayNextSurah == value) return;
    _autoPlayNextSurah = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoPlayKey, value);
    notifyListeners();
  }

  Future<void> setOfflineDownloadsEnabled(bool value) async {
    if (_offlineDownloadsEnabled == value) return;
    _offlineDownloadsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_offlinePromptKey, value);
    notifyListeners();
  }
}
