import 'package:shared_preferences/shared_preferences.dart';

/// Local favorites, recently viewed duas, and Arabic font size.
class DuaPreferencesStore {
  static const _favoritesKey = 'dua_favorites_v1';
  static const _recentKey = 'dua_recent_v1';
  static const _fontSizeKey = 'dua_arabic_font_size_v1';
  static const defaultArabicFontSize = 26.0;
  static const minArabicFontSize = 18.0;
  static const maxArabicFontSize = 40.0;

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

  Future<double> loadArabicFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getDouble(_fontSizeKey);
    if (value == null) return defaultArabicFontSize;
    return value.clamp(minArabicFontSize, maxArabicFontSize);
  }

  Future<void> saveArabicFontSize(double size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(
      _fontSizeKey,
      size.clamp(minArabicFontSize, maxArabicFontSize),
    );
  }
}
