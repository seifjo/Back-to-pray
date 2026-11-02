import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../models/notification_preferences.dart';
import '../../models/prayer_times.dart';
import 'notification_preferences_store.dart';
import 'prayer_notification_planner.dart';

/// Schedules the five daily prayer reminders from calculated prayer times.
class NotificationService {
  static final NotificationService instance = NotificationService._();

  factory NotificationService({NotificationPreferencesStore? preferencesStore}) {
    return instance;
  }

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final NotificationPreferencesStore _preferencesStore;

  static const String _channelName = 'Prayer times';
  static const String _channelDescription =
      'Reminders at calculated prayer times';

  bool _timezoneReady = false;
  bool _initialized = false;

  NotificationService._({NotificationPreferencesStore? preferencesStore})
      : _preferencesStore =
            preferencesStore ?? NotificationPreferencesStore();

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      await _ensureLocalTimezone();

      const androidSettings =
          AndroidInitializationSettings('@drawable/ic_stat_alnoor');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      await _notifications.initialize(
        const InitializationSettings(
          android: androidSettings,
          iOS: iosSettings,
        ),
      );
      await requestPermissions();
      _initialized = true;
    } catch (e) {
      // Keep the app usable if notifications cannot start.
      // ignore: avoid_print
      print('Error initializing NotificationService: $e');
    }
  }

  Future<bool> requestPermissions() async {
    try {
      var granted = true;
      final android = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        final requested = await android.requestNotificationsPermission();
        if (requested != null) granted = requested;
        try {
          await android.requestExactAlarmsPermission();
        } catch (_) {
          // Exact alarms are optional. Scheduling falls back to inexact alarms.
        }
      }

      final ios = _notifications.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (ios != null) {
        granted = await ios.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            false;
      }
      return granted;
    } catch (_) {
      // Tests / unsupported hosts have no plugin implementation.
      return false;
    }
  }

  Future<bool?> notificationsEnabled() async {
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      return android.areNotificationsEnabled();
    }
    final ios = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final options = await ios.checkPermissions();
      return options?.isEnabled;
    }
    return null;
  }

  /// Replace prayer alerts without touching other reminders.
  Future<void> reschedulePrayerNotifications({
    required PrayerTimes today,
    required PrayerTimes tomorrow,
    DateTime? now,
  }) async {
    await initialize();
    final preferences = await _preferencesStore.load();
    final language = await _languageCode();
    final alerts = PrayerNotificationPlanner.plan(
      today: today,
      tomorrow: tomorrow,
      now: now ?? DateTime.now(),
      preferences: preferences,
    );

    for (final id in PrayerNotificationPlanner.idForPrayer.values) {
      try {
        await _notifications.cancel(id);
      } catch (_) {}
    }

    final stop = language == 'en' ? 'Stop' : 'إيقاف';
    final payload = [
      for (final alert in alerts)
        {
          'id': alert.id,
          'when': alert.when.millisecondsSinceEpoch,
          'title': NotificationCopy.prayerTitle(alert.prayerKey, language),
          'body': NotificationCopy.prayerBody(alert.prayerKey, language),
          'mode': preferences.soundMode.name,
          'sound': alert.prayerKey == 'fajr' ? 'fajr' : 'adhan',
          'stop': stop,
        },
    ];

    try {
      final scheduled = await const MethodChannel('alnoor/device').invokeMethod<bool>(
        'schedulePrayerAlerts',
        {'alerts': payload},
      );
      if (scheduled == true) return;
    } catch (_) {}

    for (final alert in alerts) {
      try {
        await _schedule(
          id: alert.id,
          title: NotificationCopy.prayerTitle(alert.prayerKey, language),
          body: NotificationCopy.prayerBody(alert.prayerKey, language),
          when: alert.when,
          payload: alert.prayerKey,
          soundMode: preferences.soundMode,
        );
      } catch (_) {}
    }
  }

  /// Used when only today's calculated times are available.
  Future<void> schedulePrayerNotifications(PrayerTimes prayerTimes) async {
    final tomorrow = prayerTimes.date.add(const Duration(days: 1));
    await reschedulePrayerNotifications(
      today: prayerTimes,
      tomorrow: PrayerTimes(
        fajr: prayerTimes.fajr.add(const Duration(days: 1)),
        sunrise: prayerTimes.sunrise.add(const Duration(days: 1)),
        dhuhr: prayerTimes.dhuhr.add(const Duration(days: 1)),
        asr: prayerTimes.asr.add(const Duration(days: 1)),
        maghrib: prayerTimes.maghrib.add(const Duration(days: 1)),
        isha: prayerTimes.isha.add(const Duration(days: 1)),
        date: tomorrow,
      ),
    );
  }

  Future<void> cancelPrayerNotifications() async {
    for (final id in PrayerNotificationPlanner.idForPrayer.values) {
      await _notifications.cancel(id);
    }
    try {
      await const MethodChannel('alnoor/device').invokeMethod<bool>(
        'schedulePrayerAlerts',
        {'alerts': <Map<String, Object>>[]},
      );
    } catch (_) {}
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<void> showTestNotification({AdhanSoundMode? soundMode}) async {
    await initialize();
    final preferences = await _preferencesStore.load();
    final language = await _languageCode();
    final mode = soundMode ?? preferences.soundMode;
    final title =
        language == 'en' ? 'Al Noor notification test' : 'تجربة تنبيه النور';
    final body = language == 'en'
        ? 'This is a preview of your selected prayer alert.'
        : 'هذه معاينة لتنبيه الصلاة حسب إعدادك.';
    final stop = language == 'en' ? 'Stop' : 'إيقاف';
    final posted = await const MethodChannel('alnoor/device').invokeMethod<bool>(
      'previewPrayerAlert',
      {
        'id': 9001,
        'title': title,
        'body': body,
        'mode': mode.name,
        'sound': 'adhan',
        'stop': stop,
      },
    );
    if (posted != true) {
      throw Exception('notification');
    }
  }

  static const _worshipReminderBaseId = 4100;

  int _worshipReminderId(String activityId) {
    return _worshipReminderBaseId + (activityId.hashCode & 0x3ff);
  }

  Future<void> cancelWorshipTrackerReminder(String activityId) async {
    try {
      await _notifications.cancel(_worshipReminderId(activityId));
    } catch (_) {}
  }

  static const _hijriReminderBaseId = 5300;

  int _hijriReminderId(String occurrenceId) {
    return _hijriReminderBaseId + (occurrenceId.hashCode & 0x3ff);
  }

  Future<void> cancelHijriEventReminders(String eventDefinitionId) async {
    // Cancel a band of ids derived from definition so re-sync does not duplicate.
    for (var i = 0; i < 64; i++) {
      final probe = '${eventDefinitionId}_$i';
      try {
        await _notifications.cancel(_hijriReminderId(probe));
      } catch (_) {}
    }
  }

  Future<void> cancelHijriOccurrenceReminder(String occurrenceId) async {
    try {
      await _notifications.cancel(_hijriReminderId(occurrenceId));
    } catch (_) {}
  }

  /// Schedules one local reminder for an Islamic calendar occurrence.
  Future<void> scheduleHijriEventReminder({
    required String occurrenceId,
    required String eventDefinitionId,
    required String titleEn,
    required String titleAr,
    required DateTime when,
  }) async {
    await _ensureLocalTimezone();
    await cancelHijriOccurrenceReminder(occurrenceId);
    final language = await _languageCode();
    final title = NotificationCopy.pick(language, en: titleEn, ar: titleAr);
    final body = NotificationCopy.hijriBody(language);

    const androidDetails = AndroidNotificationDetails(
      'hijri_events',
      'Islamic calendar events',
      channelDescription: 'Optional reminders for Islamic calendar occasions',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    try {
      await _zonedSchedule(
        id: _hijriReminderId(occurrenceId),
        title: title,
        body: body,
        scheduledTime: tz.TZDateTime.from(when, tz.local),
        details: const NotificationDetails(
          android: androidDetails,
          iOS: DarwinNotificationDetails(),
        ),
        payload: 'hijri_event:$eventDefinitionId:$occurrenceId',
      );
    } catch (_) {}
  }

  /// Gentle optional checklist / journey reminder. Does not mark anything complete.
  Future<void> scheduleWorshipTrackerReminder({
    required String activityId,
    required String titleEn,
    required String titleAr,
    required int hour,
    required int minute,
  }) async {
    await _ensureLocalTimezone();
    final now = DateTime.now();
    var when = DateTime(now.year, now.month, now.day, hour, minute);
    if (!when.isAfter(now)) {
      when = when.add(const Duration(days: 1));
    }
    final language = await _languageCode();
    final title = NotificationCopy.pick(language, en: titleEn, ar: titleAr);
    final isJourney = activityId.startsWith('journey_');
    final body = isJourney
        ? NotificationCopy.journeyBody(language)
        : NotificationCopy.worshipBody(language);

    const androidDetails = AndroidNotificationDetails(
      'worship_tracker',
      'Worship Tracker',
      channelDescription: 'Optional personal worship checklist reminders',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    await cancelWorshipTrackerReminder(activityId);
    try {
      await _zonedSchedule(
        id: _worshipReminderId(activityId),
        title: title,
        body: body,
        scheduledTime: tz.TZDateTime.from(when, tz.local),
        details: const NotificationDetails(
          android: androidDetails,
          iOS: DarwinNotificationDetails(),
        ),
        payload: 'worship_tracker:$activityId',
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (_) {}
  }

  Future<void> scheduleEndOfDayReminder({int hour = 22, int minute = 0}) async {
    await _ensureLocalTimezone();
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);
    if (!scheduledDate.isAfter(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    final language = await _languageCode();
    final copy = NotificationCopy.endOfDay(language);

    const androidDetails = AndroidNotificationDetails(
      'daily_reminder',
      'Daily reminders',
      channelDescription: 'Daily check-in reminders',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    await _zonedSchedule(
      id: 1000,
      title: copy.title,
      body: copy.body,
      scheduledTime: tz.TZDateTime.from(scheduledDate, tz.local),
      details: const NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      ),
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> showAchievementUnlocked({
    required String titleEn,
    required String titleAr,
    required int xpReward,
  }) async {
    final language = await _languageCode();
    final title = NotificationCopy.achievementTitle(
      language,
      titleEn: titleEn,
      titleAr: titleAr,
    );
    final body = NotificationCopy.achievementBody(language, xpReward);
    await _notifications.show(
      2000,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'achievements',
          'Achievements',
          icon: '@drawable/ic_stat_alnoor',
          importance: Importance.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> rememberTimezone(String locationName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('device_timezone', locationName);
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(locationName));
    _timezoneReady = true;
  }

  Future<void> _schedule({
    required int id,
    required String title,
    required String body,
    required DateTime when,
    required String payload,
    required AdhanSoundMode soundMode,
  }) async {
    await _ensureLocalTimezone();
    final scheduledTime = tz.TZDateTime.from(when, tz.local);
    var details = _details(soundMode, prayerKey: payload);
    try {
      await _zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledTime: scheduledTime,
        details: details,
        payload: payload,
      );
    } catch (_) {
      await _zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledTime: scheduledTime,
        details: _plainDetails(),
        payload: payload,
      );
    }
  }

  Future<void> _zonedSchedule({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledTime,
    required NotificationDetails details,
    String? payload,
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    try {
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        scheduledTime,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
        matchDateTimeComponents: matchDateTimeComponents,
      );
    } catch (_) {
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        scheduledTime,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
        matchDateTimeComponents: matchDateTimeComponents,
      );
    }
  }

  NotificationDetails _details(AdhanSoundMode mode, {String? prayerKey}) {
    final fajr = prayerKey == 'fajr';
    final channelId = switch (mode) {
      AdhanSoundMode.silent => 'prayer_silent_v5',
      AdhanSoundMode.shortTone => 'prayer_short_v5',
      AdhanSoundMode.adhan => fajr ? 'prayer_fajr_adhan_v5' : 'prayer_adhan_v5',
    };
    final playSound = mode != AdhanSoundMode.silent;
    final AndroidNotificationSound? sound = mode == AdhanSoundMode.adhan
        ? RawResourceAndroidNotificationSound(fajr ? 'fajr' : 'adhan')
        : null;

    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.max,
        icon: '@drawable/ic_stat_alnoor',
        playSound: playSound,
        enableVibration: playSound,
        sound: sound,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: playSound,
      ),
    );
  }

  NotificationDetails _plainDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'prayer_plain_v5',
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.max,
        icon: '@drawable/ic_stat_alnoor',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  Future<void> _ensureLocalTimezone() async {
    if (_timezoneReady) return;
    tz_data.initializeTimeZones();
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('device_timezone');
      if (saved != null && saved.isNotEmpty) {
        tz.setLocalLocation(tz.getLocation(saved));
        _timezoneReady = true;
        return;
      }
    } catch (_) {}
    tz.setLocalLocation(tz.UTC);
    _timezoneReady = true;
  }

  Future<String> _languageCode() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('app_locale') ?? 'ar';
    return code == 'en' ? 'en' : 'ar';
  }
}

/// Locale-strict notification copy used at schedule time.
class NotificationCopy {
  NotificationCopy._();

  static String pick(
    String language, {
    required String en,
    required String ar,
  }) {
    return language == 'en' ? en : ar;
  }

  static String prayerTitle(String prayerKey, String language) {
    const english = {
      'fajr': 'Time for Fajr',
      'dhuhr': 'Time for Dhuhr',
      'asr': 'Time for Asr',
      'maghrib': 'Time for Maghrib',
      'isha': 'Time for Isha',
    };
    const arabic = {
      'fajr': 'حان وقت صلاة الفجر',
      'dhuhr': 'حان وقت صلاة الظهر',
      'asr': 'حان وقت صلاة العصر',
      'maghrib': 'حان وقت صلاة المغرب',
      'isha': 'حان وقت صلاة العشاء',
    };
    final names = language == 'en' ? english : arabic;
    return names[prayerKey] ?? names['fajr']!;
  }

  static String prayerBody(String prayerKey, String language) {
    if (language == 'en') {
      const english = {
        'fajr': 'It is time for the Fajr prayer.',
        'dhuhr': 'It is time for the Dhuhr prayer.',
        'asr': 'It is time for the Asr prayer.',
        'maghrib': 'It is time for the Maghrib prayer.',
        'isha': 'It is time for the Isha prayer.',
      };
      return english[prayerKey] ?? english['isha']!;
    }
    const arabic = {
      'fajr':
          '﴿وَقُرْآنَ الْفَجْرِ إِنَّ قُرْآنَ الْفَجْرِ كَانَ مَشْهُودًا﴾ الإسراء: 78',
      'dhuhr':
          '﴿حَافِظُوا عَلَى الصَّلَوَاتِ وَالصَّلَاةِ الْوُسْطَىٰ﴾ البقرة: 238',
      'asr':
          '﴿وَأَقِمِ الصَّلَاةَ طَرَفَيِ النَّهَارِ وَزُلَفًا مِّنَ اللَّيْلِ﴾ هود: 114',
      'maghrib': '﴿وَأَقِمِ الصَّلَاةَ لِذِكْرِي﴾ طه: 14',
      'isha':
          '﴿إِنَّ الصَّلَاةَ كَانَتْ عَلَى الْمُؤْمِنِينَ كِتَابًا مَّوْقُوتًا﴾ النساء: 103',
    };
    return arabic[prayerKey] ?? arabic['isha']!;
  }

  static String hijriBody(String language) => pick(
        language,
        en: 'Reminder for an upcoming Islamic occasion.',
        ar: 'تذكير بمناسبة إسلامية قادمة.',
      );

  static String worshipBody(String language) => pick(
        language,
        en:
            'A gentle reminder for your personal checklist. Mark it only when you are ready.',
        ar:
            'تذكير لطيف بقائمتك الشخصية. سجّلها فقط عندما تكون مستعدًا.',
      );

  static String journeyBody(String language) => pick(
        language,
        en: 'A gentle reminder for your spiritual journey.',
        ar: 'تذكير لطيف برحلتك الروحية.',
      );

  static ({String title, String body}) endOfDay(String language) {
    return (
      title: pick(
        language,
        en: 'End of day reminder',
        ar: 'تذكير نهاية اليوم',
      ),
      body: pick(
        language,
        en: 'Did you complete your commitment today? Record your progress now.',
        ar: 'هل أكملت التزامك اليوم؟ سجّل تقدمك الآن',
      ),
    );
  }

  static String achievementTitle(
    String language, {
    required String titleEn,
    required String titleAr,
  }) {
    final name = pick(language, en: titleEn, ar: titleAr);
    return pick(
      language,
      en: 'New achievement: $name',
      ar: 'إنجاز جديد: $name',
    );
  }

  static String achievementBody(String language, int xpReward) => pick(
        language,
        en: '+$xpReward XP',
        ar: '+$xpReward نقطة',
      );
}
