import 'package:shared_preferences/shared_preferences.dart';

/// Persistent favorites and recently played nasheed IDs.
class NasheedPreferencesStore {
  static const _favoritesKey = 'nasheed_favorites_v1';
  static const _recentKey = 'nasheed_recent_v1';

  Future<Set<String>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoritesKey)?.toSet() ?? {};
  }

  Future<void> saveFavorites(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, ids.toList());
  }

  Future<List<String>> loadRecent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_recentKey) ?? [];
  }

  Future<void> saveRecent(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_recentKey, ids);
  }
}
