import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../../models/prayer_times.dart';

/// Notification Service for Prayer Times
/// Schedules and manages prayer notifications with Qur'anic reminders
class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'prayer_times_channel';
  static const String _channelName = 'Prayer Times';
  static const String _channelDescription = 'Notifications for prayer times';

  /// Initialize notification service
  Future<void> initialize() async {
    try {
      // Initialize timezone database
      tz.initializeTimeZones();

      // Android initialization settings
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      final iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      final initializationSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      // Request permissions
      await _requestPermissions();
    } catch (e) {
      print('Error initializing NotificationService: $e');
      // Don't rethrow, just log it so the app can continue
    }
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }

    final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    
    if (iosPlugin != null) {
      await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  /// Handle notification tap
  void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap - can navigate to prayer times screen
    print('Notification tapped: ${response.payload}');
  }

  /// Schedule all prayer notifications for today
  Future<void> schedulePrayerNotifications(PrayerTimes prayerTimes) async {
    // Cancel existing notifications
    await _notifications.cancelAll();

    // Schedule notifications for each prayer (excluding Sunrise)
    await _schedulePrayerNotification(
      id: 1,
      prayerName: 'الفجر',
      prayerTime: prayerTimes.fajr,
      message: 'قال تعالى: ﴿وَقُرْآنَ الْفَجْرِ إِنَّ قُرْآنَ الْفَجْرِ كَانَ مَشْهُودًا﴾',
      emoji: '☀️',
    );

    await _schedulePrayerNotification(
      id: 2,
      prayerName: 'الظهر',
      prayerTime: prayerTimes.dhuhr,
      message: 'قال تعالى: ﴿حَافِظُوا عَلَى الصَّلَوَاتِ وَالصَّلَاةِ الْوُسْطَىٰ﴾',
      emoji: '🕌',
    );

    await _schedulePrayerNotification(
      id: 3,
      prayerName: 'العصر',
      prayerTime: prayerTimes.asr,
      message: 'قال تعالى: ﴿وَأَقِمِ الصَّلَاةَ طَرَفَيِ النَّهَارِ وَزُلَفًا مِّنَ اللَّيْلِ﴾',
      emoji: '🌤️',
    );

    await _schedulePrayerNotification(
      id: 4,
      prayerName: 'المغرب',
      prayerTime: prayerTimes.maghrib,
      message: 'قال تعالى: ﴿وَأَقِمِ الصَّلَاةَ لِذِكْرِي﴾',
      emoji: '🌙',
    );

    await _schedulePrayerNotification(
      id: 5,
      prayerName: 'العشاء',
      prayerTime: prayerTimes.isha,
      message: 'قال تعالى: ﴿إِنَّ الصَّلَاةَ كَانَتْ عَلَى الْمُؤْمِنِينَ كِتَابًا مَّوْقُوتًا﴾',
      emoji: '🌃',
    );
  }

  /// Schedule a single prayer notification
  Future<void> _schedulePrayerNotification({
    required int id,
    required String prayerName,
    required DateTime prayerTime,
    required String message,
    required String emoji,
  }) async {
    // Only schedule if prayer time is in the future
    if (prayerTime.isBefore(DateTime.now())) {
      return;
    }

    final scheduledTime = tz.TZDateTime.from(prayerTime, tz.local);

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Format time nicely
    final timeString = '${prayerTime.hour.toString().padLeft(2, '0')}:${prayerTime.minute.toString().padLeft(2, '0')}';

    await _notifications.zonedSchedule(
      id,
      'حان الآن موعد صلاة $prayerName $emoji',
      '$message\nالوقت: $timeString',
      scheduledTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: prayerName,
    );
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Show immediate test notification
  Future<void> showTestNotification() async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      0,
      'اختبار التنبيهات 🕌',
      'هذا تنبيه تجريبي للتأكد من عمل النظام بشكل صحيح',
      notificationDetails,
    );
  }

  /// Schedule end-of-day reminder (10 PM default)
  Future<void> scheduleEndOfDayReminder({int hour = 22, int minute = 0}) async {
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final scheduledTime = tz.TZDateTime.from(scheduledDate, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'daily_reminder',
      'Daily Reminders',
      channelDescription: 'Daily check-in reminders',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    await _notifications.zonedSchedule(
      1000,
      'تذكير نهاية اليوم 🌙',
      'هل أكملت التزامك اليوم؟ سجّل تقدمك الآن!',
      scheduledTime,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Show achievement unlocked notification
  Future<void> showAchievementUnlocked(String title, int xpReward) async {
    await _notifications.show(
      2000,
      '🎊 إنجاز جديد: $title',
      '+$xpReward XP',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'achievements',
          'Achievements',
          importance: Importance.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
