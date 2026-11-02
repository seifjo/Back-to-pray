import 'package:hijri/hijri_calendar.dart';

import '../../data/islamic_events_catalog.dart';
import '../../models/hijri_calendar.dart';

/// Hijri conversions using the Umm al-Qura tables from the `hijri` package,
/// with an optional day adjustment for local moon-sighting differences.
class HijriCalendarService {
  static const methodNameEn = 'Umm al-Qura (Saudi Arabia civil calendar)';
  static const methodNameAr = 'تقويم أم القرى (التقويم المدني السعودي)';
  static const minAdjustment = -2;
  static const maxAdjustment = 2;

  /// [adjustmentDays] shifts the Gregorian date before Hijri conversion.
  /// Positive values make the Hijri date appear later relative to Umm al-Qura.
  HijriDate toHijri(DateTime gregorian, {int adjustmentDays = 0}) {
    final shifted = DateTime(
      gregorian.year,
      gregorian.month,
      gregorian.day,
    ).add(Duration(days: adjustmentDays.clamp(minAdjustment, maxAdjustment)));
    final h = HijriCalendar.fromDate(shifted);
    return HijriDate(year: h.hYear, month: h.hMonth, day: h.hDay);
  }

  DateTime toGregorian(
    HijriDate hijri, {
    int adjustmentDays = 0,
  }) {
    final converter = HijriCalendar();
    final g = converter.hijriToGregorian(hijri.year, hijri.month, hijri.day);
    return DateTime(g.year, g.month, g.day)
        .subtract(Duration(days: adjustmentDays.clamp(minAdjustment, maxAdjustment)));
  }

  int daysInMonth(int hijriYear, int hijriMonth) {
    return HijriCalendar().getDaysInMonth(hijriYear, hijriMonth);
  }

  String monthName(int month, {required bool english}) {
    HijriCalendar.language = english ? 'en' : 'ar';
    final probe = HijriCalendar()
      ..hYear = 1440
      ..hMonth = month
      ..hDay = 1;
    return probe.getLongMonthName();
  }

  List<IslamicEventOccurrence> eventsForHijriDay(
    HijriDate day, {
    int adjustmentDays = 0,
  }) {
    return [
      for (final definition in IslamicEventsCatalog.definitions)
        if (definition.hijriMonth == day.month &&
            definition.hijriDay == day.day)
          IslamicEventOccurrence(
            definition: definition,
            hijriDate: day,
            gregorianDate: toGregorian(day, adjustmentDays: adjustmentDays),
          ),
    ];
  }

  List<IslamicEventOccurrence> eventsInHijriMonth(
    int year,
    int month, {
    int adjustmentDays = 0,
  }) {
    final length = daysInMonth(year, month);
    return [
      for (var day = 1; day <= length; day++)
        ...eventsForHijriDay(
          HijriDate(year: year, month: month, day: day),
          adjustmentDays: adjustmentDays,
        ),
    ];
  }

  /// Upcoming occurrences across [hijriYearsAhead] Hijri years from [from].
  List<IslamicEventOccurrence> upcomingEvents({
    required DateTime from,
    int adjustmentDays = 0,
    int hijriYearsAhead = 2,
  }) {
    final start = toHijri(from, adjustmentDays: adjustmentDays);
    final endYear = start.year + hijriYearsAhead;
    final items = <IslamicEventOccurrence>[];
    for (var year = start.year; year <= endYear; year++) {
      for (final definition in IslamicEventsCatalog.definitions) {
        final hijri = HijriDate(
          year: year,
          month: definition.hijriMonth,
          day: definition.hijriDay,
        );
        final gregorian = toGregorian(hijri, adjustmentDays: adjustmentDays);
        if (!gregorian.isBefore(DateTime(from.year, from.month, from.day))) {
          items.add(
            IslamicEventOccurrence(
              definition: definition,
              hijriDate: hijri,
              gregorianDate: gregorian,
            ),
          );
        }
      }
    }
    items.sort((a, b) => a.gregorianDate.compareTo(b.gregorianDate));
    return items;
  }

  List<CalendarDayCell> buildMonthGrid({
    required int hijriYear,
    required int hijriMonth,
    required DateTime today,
    int adjustmentDays = 0,
    int firstDayOfWeek = DateTime.saturday,
  }) {
    final length = daysInMonth(hijriYear, hijriMonth);
    final firstGregorian = toGregorian(
      HijriDate(year: hijriYear, month: hijriMonth, day: 1),
      adjustmentDays: adjustmentDays,
    );
    final leading = (firstGregorian.weekday - firstDayOfWeek + 7) % 7;
    final todayKey = DateTime(today.year, today.month, today.day);
    final cells = <CalendarDayCell>[];

    for (var i = 0; i < leading; i++) {
      final g = firstGregorian.subtract(Duration(days: leading - i));
      final h = toHijri(g, adjustmentDays: adjustmentDays);
      cells.add(
        CalendarDayCell(
          gregorian: g,
          hijri: h,
          isToday: g == todayKey,
          isCurrentMonth: false,
          events: eventsForHijriDay(h, adjustmentDays: adjustmentDays),
        ),
      );
    }

    for (var day = 1; day <= length; day++) {
      final h = HijriDate(year: hijriYear, month: hijriMonth, day: day);
      final g = toGregorian(h, adjustmentDays: adjustmentDays);
      cells.add(
        CalendarDayCell(
          gregorian: g,
          hijri: h,
          isToday: g == todayKey,
          isCurrentMonth: true,
          events: eventsForHijriDay(h, adjustmentDays: adjustmentDays),
        ),
      );
    }

    while (cells.length % 7 != 0) {
      final last = cells.last.gregorian.add(const Duration(days: 1));
      final h = toHijri(last, adjustmentDays: adjustmentDays);
      cells.add(
        CalendarDayCell(
          gregorian: last,
          hijri: h,
          isToday: last == todayKey,
          isCurrentMonth: false,
          events: eventsForHijriDay(h, adjustmentDays: adjustmentDays),
        ),
      );
    }
    return cells;
  }
}
