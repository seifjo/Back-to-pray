import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/services/notification_preferences_store.dart';
import '../models/notification_preferences.dart';

class AppSettingsProvider extends ChangeNotifier {
  static const _localeKey = 'app_locale';
  static const _themeKey = 'app_theme_mode';
  static const _introSoundKey = 'intro_sound_enabled';
  static const _hapticKey = 'haptic_enabled';
  static const _feedbackDefaultsKey = 'feedback_defaults_v1';
  static const _fontKey = 'adhkar_font_size';
  static const _introSeenKey = 'journey_intro_seen';
  static const _showTranslationKey = 'adhkar_show_translation';
  static const _hour24Key = 'prayer_clock_24';

  final NotificationPreferencesStore _notificationStore;

  Locale _locale = const Locale('ar');
  ThemeMode _themeMode = ThemeMode.dark;
  bool _introSoundEnabled = true;
  bool _hapticEnabled = true;
  double _adhkarFontSize = 26;
  bool _journeyIntroSeen = false;
  bool _showTranslation = true;
  bool _use24HourClock = true;
  bool _loaded = false;
  NotificationPreferences _notifications = const NotificationPreferences();

  AppSettingsProvider({NotificationPreferencesStore? notificationStore})
      : _notificationStore = notificationStore ?? NotificationPreferencesStore() {
    load();
  }

  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;
  bool get introSoundEnabled => _introSoundEnabled;
  bool get hapticEnabled => _hapticEnabled;
  double get adhkarFontSize => _adhkarFontSize;
  bool get journeyIntroSeen => _journeyIntroSeen;
  bool get showTranslation => _showTranslation;
  bool get use24HourClock => _use24HourClock;
  bool get isLoaded => _loaded;
  bool get isArabic => _locale.languageCode == 'ar';
  NotificationPreferences get notifications => _notifications;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_localeKey) ?? 'ar';
    _locale = Locale(code == 'en' ? 'en' : 'ar');
    _themeMode = _themeFromName(prefs.getString(_themeKey));
    // Stay ON until the user explicitly turns them off in Settings.
    // One-time migration: older builds defaulted these off or muted by ringer.
    if (!(prefs.getBool(_feedbackDefaultsKey) ?? false)) {
      await prefs.setBool(_introSoundKey, true);
      await prefs.setBool(_hapticKey, true);
      await prefs.setBool(_feedbackDefaultsKey, true);
    }
    _introSoundEnabled = await _boolPref(prefs, _introSoundKey, true);
    _hapticEnabled = await _boolPref(prefs, _hapticKey, true);
    _adhkarFontSize = prefs.getDouble(_fontKey) ?? 26;
    _journeyIntroSeen = prefs.getBool(_introSeenKey) ?? false;
    _showTranslation = prefs.getBool(_showTranslationKey) ?? true;
    _use24HourClock = prefs.getBool(_hour24Key) ?? true;
    _notifications = await _notificationStore.load();
    _loaded = true;
    notifyListeners();
  }

  /// Reads a bool preference, writing [fallback] the first time so the choice
  /// persists across launches until the user changes it.
  Future<bool> _boolPref(
    SharedPreferences prefs,
    String key,
    bool fallback,
  ) async {
    final stored = prefs.getBool(key);
    if (stored != null) return stored;
    await prefs.setBool(key, fallback);
    return fallback;
  }

  Future<void> setLocale(Locale locale) async {
    _locale = Locale(locale.languageCode == 'en' ? 'en' : 'ar');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, _locale.languageCode);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode.name);
    notifyListeners();
  }

  Future<void> setIntroSoundEnabled(bool value) async {
    _introSoundEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_introSoundKey, value);
    notifyListeners();
  }

  Future<void> setHapticEnabled(bool value) async {
    _hapticEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hapticKey, value);
    notifyListeners();
  }

  Future<void> setAdhkarFontSize(double value) async {
    // Presets: Small 20 · Medium 26 · Large 32 · Extra Large 40
    _adhkarFontSize = value.clamp(20, 40);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontKey, _adhkarFontSize);
    notifyListeners();
  }

  /// Named accessibility sizes for Adhkar Arabic text.
  static const double fontSmall = 20;
  static const double fontMedium = 26;
  static const double fontLarge = 32;
  static const double fontExtraLarge = 40;

  String adhkarFontSizeLabel(bool arabic) {
    if (_adhkarFontSize <= 22) return arabic ? 'صغير' : 'Small';
    if (_adhkarFontSize <= 28) return arabic ? 'متوسط' : 'Medium';
    if (_adhkarFontSize <= 35) return arabic ? 'كبير' : 'Large';
    return arabic ? 'كبير جداً' : 'Extra Large';
  }

  Future<void> setShowTranslation(bool value) async {
    _showTranslation = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showTranslationKey, value);
    notifyListeners();
  }

  Future<void> setUse24HourClock(bool value) async {
    _use24HourClock = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hour24Key, value);
    notifyListeners();
  }

  Future<void> setJourneyIntroSeen(bool seen) async {
    _journeyIntroSeen = seen;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_introSeenKey, seen);
    notifyListeners();
  }

  Future<void> updateNotifications(NotificationPreferences preferences) async {
    _notifications = preferences;
    await _notificationStore.save(preferences);
    notifyListeners();
  }

  ThemeMode _themeFromName(String? name) {
    switch (name) {
      case 'light':
        return ThemeMode.light;
      case 'system':
        return ThemeMode.system;
      case 'dark':
      default:
        return ThemeMode.dark;
    }
  }
}
