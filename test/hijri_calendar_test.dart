import 'package:back_to_prayer/core/services/hijri_calendar_service.dart';
import 'package:back_to_prayer/core/services/hijri_preferences_store.dart';
import 'package:back_to_prayer/data/islamic_events_catalog.dart';
import 'package:back_to_prayer/data/more_features_catalog.dart';
import 'package:back_to_prayer/models/hijri_calendar.dart';
import 'package:back_to_prayer/providers/hijri_calendar_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('More Features marks Hijri Calendar available', () {
    final feature = MoreFeaturesCatalog.features
        .firstWhere((item) => item.id == 'hijri_calendar');
    expect(feature.available, isTrue);
    expect(feature.route, MoreFeatureRoute.hijriCalendar);
  });

  test('date conversion round-trips within Umm al-Qura mapping', () {
    final service = HijriCalendarService();
    final sample = DateTime(2026, 3, 20);
    final hijri = service.toHijri(sample);
    expect(hijri.year, greaterThan(1400));
    expect(hijri.month, inInclusiveRange(1, 12));
    expect(hijri.day, inInclusiveRange(1, 30));

    final back = service.toGregorian(hijri);
    expect(back.year, sample.year);
    expect(back.month, sample.month);
    expect(back.day, sample.day);
  });

  test('adjustment shifts Hijri day without hardcoding events', () {
    final service = HijriCalendarService();
    final day = DateTime(2026, 3, 20);
    final base = service.toHijri(day, adjustmentDays: 0);
    final plus = service.toHijri(day, adjustmentDays: 1);
    expect(plus == base, isFalse);

    final ramadan = IslamicEventsCatalog.byId('ramadan_start')!;
    expect(ramadan.hijriMonth, 9);
    expect(ramadan.hijriDay, 1);
    final occurrence = service.eventsForHijriDay(
      HijriDate(year: base.year, month: 9, day: 1),
    );
    expect(occurrence.any((item) => item.definition.id == 'ramadan_start'), isTrue);
  });

  test('month navigation and event display on provider', () async {
    final provider = HijriCalendarProvider(
      clock: () => DateTime(2026, 3, 20, 10),
    );
    await provider.initialize();
    expect(provider.loading, isFalse);
    expect(provider.monthCells, isNotEmpty);
    expect(provider.monthCells.length % 7, 0);

    final beforeYear = provider.viewYear;
    final beforeMonth = provider.viewMonth;
    provider.nextMonth();
    if (beforeMonth == 12) {
      expect(provider.viewMonth, 1);
      expect(provider.viewYear, beforeYear + 1);
    } else {
      expect(provider.viewMonth, beforeMonth + 1);
      expect(provider.viewYear, beforeYear);
    }
    provider.previousMonth();
    expect(provider.viewMonth, beforeMonth);
    expect(provider.viewYear, beforeYear);

    provider.goToToday();
    expect(provider.selectedGregorian, DateTime(2026, 3, 20));
    expect(provider.upcomingEvents, isNotEmpty);
  });

  test('settings persistence for adjustment and reminders', () async {
    final store = HijriPreferencesStore();
    final provider = HijriCalendarProvider(
      store: store,
      clock: () => DateTime(2026, 3, 20, 12),
    );
    await provider.initialize();
    await provider.setAdjustment(1);
    expect(provider.adjustmentDays, 1);

    await provider.setReminder(
      eventDefinitionId: 'eid_fitr',
      enabled: true,
      daysBefore: 2,
      hour: 8,
      minute: 30,
    );
    expect(provider.reminderFor('eid_fitr').enabled, isTrue);
    expect(provider.reminderFor('eid_fitr').daysBefore, 2);

    final restored = HijriCalendarProvider(
      store: store,
      clock: () => DateTime(2026, 3, 20, 13),
    );
    await restored.initialize();
    expect(restored.adjustmentDays, 1);
    expect(restored.reminderFor('eid_fitr').enabled, isTrue);
    expect(restored.reminderFor('eid_fitr').hour, 8);
    expect(restored.reminderFor('eid_fitr').minute, 30);
  });
}
