import '../../models/notification_preferences.dart';
import '../../models/prayer_times.dart';

/// A single prayer alert that should be scheduled.
class PlannedPrayerAlert {
  final int id;
  final String prayerKey;
  final DateTime when;

  const PlannedPrayerAlert({
    required this.id,
    required this.prayerKey,
    required this.when,
  });
}

/// Pure scheduling rules so notifications are not duplicated and past
/// prayers roll forward to the next calculated occurrence.
class PrayerNotificationPlanner {
  static const idForPrayer = {
    'fajr': 1,
    'dhuhr': 2,
    'asr': 3,
    'maghrib': 4,
    'isha': 5,
  };

  static List<PlannedPrayerAlert> plan({
    required PrayerTimes today,
    required PrayerTimes tomorrow,
    required DateTime now,
    required NotificationPreferences preferences,
  }) {
    if (!preferences.enabled) return const [];

    final todayMap = _fivePrayers(today);
    final tomorrowMap = _fivePrayers(tomorrow);
    final alerts = <PlannedPrayerAlert>[];

    for (final key in NotificationPreferences.prayerKeys) {
      if (!preferences.isPrayerEnabled(key)) continue;
      final todayTime = todayMap[key]!;
      final when = todayTime.isAfter(now) ? todayTime : tomorrowMap[key]!;
      if (!when.isAfter(now)) continue;
      alerts.add(
        PlannedPrayerAlert(
          id: idForPrayer[key]!,
          prayerKey: key,
          when: when,
        ),
      );
    }
    return alerts;
  }

  static Map<String, DateTime> _fivePrayers(PrayerTimes times) {
    return {
      'fajr': times.fajr,
      'dhuhr': times.dhuhr,
      'asr': times.asr,
      'maghrib': times.maghrib,
      'isha': times.isha,
    };
  }
}
