/// User preferences for the five daily prayer notifications.
enum AdhanSoundMode {
  silent,
  shortTone,
  adhan,
}

class NotificationPreferences {
  static const prayerKeys = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];

  final bool enabled;
  final Map<String, bool> prayers;
  final AdhanSoundMode soundMode;

  const NotificationPreferences({
    this.enabled = true,
    this.prayers = const {
      'fajr': true,
      'dhuhr': true,
      'asr': true,
      'maghrib': true,
      'isha': true,
    },
    this.soundMode = AdhanSoundMode.adhan,
  });

  bool isPrayerEnabled(String key) => enabled && (prayers[key] ?? false);

  NotificationPreferences copyWith({
    bool? enabled,
    Map<String, bool>? prayers,
    AdhanSoundMode? soundMode,
  }) {
    return NotificationPreferences(
      enabled: enabled ?? this.enabled,
      prayers: prayers ?? this.prayers,
      soundMode: soundMode ?? this.soundMode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'prayers': prayers,
      'soundMode': soundMode.name,
    };
  }

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    final raw = json['prayers'];
    final prayers = <String, bool>{
      for (final key in prayerKeys) key: true,
    };
    if (raw is Map) {
      for (final key in prayerKeys) {
        final value = raw[key];
        if (value is bool) prayers[key] = value;
      }
    }
    final modeName = json['soundMode'] as String?;
    final mode = AdhanSoundMode.values.firstWhere(
      (mode) => mode.name == modeName,
      orElse: () => AdhanSoundMode.adhan,
    );
    return NotificationPreferences(
      enabled: json['enabled'] as bool? ?? true,
      prayers: prayers,
      soundMode: mode,
    );
  }
}
