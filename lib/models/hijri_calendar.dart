class HijriDate {
  final int year;
  final int month;
  final int day;

  const HijriDate({
    required this.year,
    required this.month,
    required this.day,
  });

  @override
  bool operator ==(Object other) =>
      other is HijriDate &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() =>
      '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
}

class CalendarDayCell {
  final DateTime gregorian;
  final HijriDate hijri;
  final bool isToday;
  final bool isCurrentMonth;
  final List<IslamicEventOccurrence> events;

  const CalendarDayCell({
    required this.gregorian,
    required this.hijri,
    required this.isToday,
    required this.isCurrentMonth,
    this.events = const [],
  });
}

class IslamicEventDefinition {
  final String id;
  final int hijriMonth;
  final int hijriDay;
  final String nameEn;
  final String nameAr;
  final String descriptionEn;
  final String descriptionAr;
  final int colorValue;

  const IslamicEventDefinition({
    required this.id,
    required this.hijriMonth,
    required this.hijriDay,
    required this.nameEn,
    required this.nameAr,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.colorValue,
  });

  String name(bool english) => english ? nameEn : nameAr;

  String description(bool english) =>
      english ? descriptionEn : descriptionAr;
}

class IslamicEventOccurrence {
  final IslamicEventDefinition definition;
  final HijriDate hijriDate;
  final DateTime gregorianDate;

  const IslamicEventOccurrence({
    required this.definition,
    required this.hijriDate,
    required this.gregorianDate,
  });

  String get id =>
      '${definition.id}_${hijriDate.year}_${hijriDate.month}_${hijriDate.day}';
}

class HijriReminderSetting {
  final String eventDefinitionId;
  final bool enabled;
  final int daysBefore;
  final int hour;
  final int minute;

  const HijriReminderSetting({
    required this.eventDefinitionId,
    this.enabled = false,
    this.daysBefore = 1,
    this.hour = 9,
    this.minute = 0,
  });

  HijriReminderSetting copyWith({
    bool? enabled,
    int? daysBefore,
    int? hour,
    int? minute,
  }) {
    return HijriReminderSetting(
      eventDefinitionId: eventDefinitionId,
      enabled: enabled ?? this.enabled,
      daysBefore: daysBefore ?? this.daysBefore,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
    );
  }

  Map<String, dynamic> toJson() => {
        'eventDefinitionId': eventDefinitionId,
        'enabled': enabled,
        'daysBefore': daysBefore,
        'hour': hour,
        'minute': minute,
      };

  factory HijriReminderSetting.fromJson(Map<String, dynamic> json) {
    return HijriReminderSetting(
      eventDefinitionId: json['eventDefinitionId'] as String,
      enabled: json['enabled'] as bool? ?? false,
      daysBefore: (json['daysBefore'] as num?)?.toInt() ?? 1,
      hour: (json['hour'] as num?)?.toInt() ?? 9,
      minute: (json['minute'] as num?)?.toInt() ?? 0,
    );
  }
}
