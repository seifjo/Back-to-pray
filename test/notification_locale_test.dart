import 'package:back_to_prayer/core/services/notification_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('prayer notification copy stays language-strict', () {
    expect(NotificationCopy.prayerTitle('fajr', 'en'), contains('Fajr'));
    expect(NotificationCopy.prayerTitle('fajr', 'en'), isNot(contains('الفجر')));
    expect(NotificationCopy.prayerTitle('fajr', 'ar'), contains('الفجر'));
    expect(NotificationCopy.prayerBody('isha', 'en'), contains('Isha'));
    expect(NotificationCopy.prayerBody('isha', 'en'), isNot(contains('﴿')));
    expect(NotificationCopy.prayerBody('isha', 'ar'), contains('﴿'));
  });

  test('hijri, worship, and journey bodies do not mix languages', () {
    expect(NotificationCopy.hijriBody('en'), isNot(contains('تذكير')));
    expect(NotificationCopy.hijriBody('ar'), contains('تذكير'));
    expect(NotificationCopy.worshipBody('en'), contains('checklist'));
    expect(NotificationCopy.worshipBody('ar'), contains('قائمتك'));
    expect(NotificationCopy.journeyBody('en'), contains('journey'));
    expect(NotificationCopy.journeyBody('ar'), contains('رحلتك'));
  });

  test('pick and achievement helpers follow locale', () {
    expect(
      NotificationCopy.pick('en', en: 'Eid', ar: 'عيد'),
      'Eid',
    );
    expect(
      NotificationCopy.pick('ar', en: 'Eid', ar: 'عيد'),
      'عيد',
    );
    final achievement = NotificationCopy.achievementTitle(
      'ar',
      titleEn: 'Reader',
      titleAr: 'قارئ',
    );
    expect(achievement, contains('قارئ'));
    expect(achievement, isNot(contains('Reader')));
    expect(NotificationCopy.achievementBody('en', 10), contains('XP'));
    expect(NotificationCopy.achievementBody('ar', 10), contains('نقطة'));
  });
}
