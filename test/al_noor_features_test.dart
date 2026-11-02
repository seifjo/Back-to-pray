import 'package:back_to_prayer/core/services/prayer_notification_planner.dart';
import 'package:back_to_prayer/core/services/qibla_service.dart';
import 'package:back_to_prayer/l10n/app_localizations.dart';
import 'package:back_to_prayer/models/notification_preferences.dart';
import 'package:back_to_prayer/models/prayer_times.dart';
import 'package:back_to_prayer/models/spiritual_journey.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('prayer clock switches between 24-hour and 12-hour', () {
    final afternoon = DateTime(2026, 10, 2, 15, 5);
    final midnight = DateTime(2026, 10, 2, 0, 7);
    expect(
      PrayerClock.format(afternoon, use24Hour: true, arabic: false),
      '15:05',
    );
    expect(
      PrayerClock.format(afternoon, use24Hour: false, arabic: false),
      '3:05 PM',
    );
    expect(
      PrayerClock.format(afternoon, use24Hour: false, arabic: true),
      '3:05 م',
    );
    expect(
      PrayerClock.format(midnight, use24Hour: false, arabic: true),
      '12:07 ص',
    );
  });

  test('Qibla bearing from London points southeast toward Makkah', () {
    final bearing = QiblaService().bearingFrom(51.5074, -0.1278);
    expect(bearing, closeTo(118.99, 0.2));
  });

  test('Qibla alignment uses the shortest turn', () {
    expect(QiblaService.angularDifference(10, 20), closeTo(10, 0.001));
    expect(QiblaService.angularDifference(10, 350), closeTo(20, 0.001));
    expect(QiblaService.isAligned(118, 120), isTrue);
    expect(QiblaService.isAligned(90, 120), isFalse);
  });

  test('prayer alerts skip disabled prayers and move past times to tomorrow', () {
    final today = _times(DateTime(2026, 10, 1));
    final tomorrow = _times(DateTime(2026, 10, 2));
    final now = DateTime(2026, 10, 1, 13, 0);
    final alerts = PrayerNotificationPlanner.plan(
      today: today,
      tomorrow: tomorrow,
      now: now,
      preferences: const NotificationPreferences(
        prayers: {
          'fajr': false,
          'dhuhr': true,
          'asr': true,
          'maghrib': true,
          'isha': true,
        },
      ),
    );

    expect(alerts.map((alert) => alert.prayerKey), [
      'dhuhr',
      'asr',
      'maghrib',
      'isha',
    ]);
    expect(alerts.first.when.day, 2);
    expect(alerts[1].when.day, 1);
    expect(alerts.map((alert) => alert.id).toSet().length, alerts.length);
  });

  test('disabled notifications schedule nothing', () {
    final day = DateTime(2026, 10, 1);
    final alerts = PrayerNotificationPlanner.plan(
      today: _times(day),
      tomorrow: _times(day.add(const Duration(days: 1))),
      now: DateTime(2026, 10, 1, 1),
      preferences: const NotificationPreferences(enabled: false),
    );
    expect(alerts, isEmpty);
  });

  test('spiritual journey day index and missed days stay calendar based', () {
    final start = DateTime(2026, 10, 1, 22);
    final now = DateTime(2026, 10, 4, 8);
    expect(spiritualDayIndex(start, now, 7), 3);
    expect(
      hasEarlierUnmarkedDay(
        start: start,
        now: now,
        durationDays: 7,
        completedDays: ['2026-10-01'],
      ),
      isTrue,
    );
    expect(
      hasEarlierUnmarkedDay(
        start: start,
        now: now,
        durationDays: 7,
        completedDays: ['2026-10-01', '2026-10-02', '2026-10-03'],
      ),
      isFalse,
    );
  });

  testWidgets('language lookup switches without restarting', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Text(context.tr('navQibla')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Qibla'), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Text(context.tr('navQibla')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('القبلة'), findsOneWidget);
  });
}

PrayerTimes _times(DateTime day) {
  DateTime at(int hour, int minute) =>
      DateTime(day.year, day.month, day.day, hour, minute);
  return PrayerTimes(
    fajr: at(5, 0),
    sunrise: at(6, 15),
    dhuhr: at(12, 10),
    asr: at(15, 40),
    maghrib: at(18, 5),
    isha: at(19, 30),
    date: DateTime(day.year, day.month, day.day),
  );
}
