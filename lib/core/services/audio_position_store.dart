import 'package:shared_preferences/shared_preferences.dart';

/// Persists last playback position per track id for resume.
class AudioPositionStore {
  static const _prefix = 'islamic_audio_pos_v1_';

  Future<Duration?> load(String trackId) async {
    final prefs = await SharedPreferences.getInstance();
    final ms = prefs.getInt('$_prefix$trackId');
    if (ms == null || ms < 5000) return null;
    return Duration(milliseconds: ms);
  }

  Future<void> save(String trackId, Duration position) async {
    final prefs = await SharedPreferences.getInstance();
    if (position.inMilliseconds < 5000) {
      await prefs.remove('$_prefix$trackId');
      return;
    }
    await prefs.setInt('$_prefix$trackId', position.inMilliseconds);
  }

  Future<void> clear(String trackId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefix$trackId');
  }
}
