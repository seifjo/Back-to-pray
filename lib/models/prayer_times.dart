/// Prayer Times Model
/// Represents the calculated prayer times for a specific day
class PrayerTimes {
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;
  final DateTime date;

  PrayerTimes({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.date,
  });

  /// Get all prayer times as a map
  Map<String, DateTime> toMap() {
    return {
      'الفجر': fajr,
      'الشروق': sunrise,
      'الظهر': dhuhr,
      'العصر': asr,
      'المغرب': maghrib,
      'العشاء': isha,
    };
  }

  /// Get next prayer time and name
  Map<String, dynamic> getNextPrayer() {
    final now = DateTime.now();
    final prayers = toMap();

    for (var entry in prayers.entries) {
      if (entry.value.isAfter(now)) {
        return {
          'name': entry.key,
          'time': entry.value,
          'isNext': true,
        };
      }
    }

    // If no prayer is found today, return Fajr of tomorrow
    return {
      'name': 'الفجر',
      'time': DateTime(now.year, now.month, now.day + 1, fajr.hour, fajr.minute),
      'isNext': true,
    };
  }

  /// Get time remaining until next prayer
  Duration getTimeUntilNextPrayer() {
    final nextPrayer = getNextPrayer();
    final nextPrayerTime = nextPrayer['time'] as DateTime;
    return nextPrayerTime.difference(DateTime.now());
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'fajr': fajr.toIso8601String(),
      'sunrise': sunrise.toIso8601String(),
      'dhuhr': dhuhr.toIso8601String(),
      'asr': asr.toIso8601String(),
      'maghrib': maghrib.toIso8601String(),
      'isha': isha.toIso8601String(),
      'date': date.toIso8601String(),
    };
  }

  /// Create from JSON
  factory PrayerTimes.fromJson(Map<String, dynamic> json) {
    return PrayerTimes(
      fajr: DateTime.parse(json['fajr']),
      sunrise: DateTime.parse(json['sunrise']),
      dhuhr: DateTime.parse(json['dhuhr']),
      asr: DateTime.parse(json['asr']),
      maghrib: DateTime.parse(json['maghrib']),
      isha: DateTime.parse(json['isha']),
      date: DateTime.parse(json['date']),
    );
  }
}

/// Calculation Method Enum
enum CalculationMethod {
  egyptianGeneralAuthority,
  ummAlQura,
  isna,
  muslimWorldLeague,
  karachi,
  dubai,
  kuwait,
  qatar,
  singapore,
  northAmerica,
  other
}

/// Extension to get Arabic names for calculation methods
extension CalculationMethodArabic on CalculationMethod {
  String localizedName(bool english) => english ? englishName : arabicName;

  String get englishName {
    switch (this) {
      case CalculationMethod.egyptianGeneralAuthority:
        return 'Egyptian General Authority of Survey';
      case CalculationMethod.ummAlQura:
        return 'Umm al-Qura (Saudi Arabia)';
      case CalculationMethod.isna:
        return 'ISNA (North America)';
      case CalculationMethod.muslimWorldLeague:
        return 'Muslim World League';
      case CalculationMethod.karachi:
        return 'University of Islamic Sciences, Karachi';
      case CalculationMethod.dubai:
        return 'Dubai';
      case CalculationMethod.kuwait:
        return 'Kuwait';
      case CalculationMethod.qatar:
        return 'Qatar';
      case CalculationMethod.singapore:
        return 'Singapore';
      case CalculationMethod.northAmerica:
        return 'North America';
      case CalculationMethod.other:
        return 'Other';
    }
  }

  String get arabicName {
    switch (this) {
      case CalculationMethod.egyptianGeneralAuthority:
        return 'الهيئة المصرية العامة للمساحة';
      case CalculationMethod.ummAlQura:
        return 'أم القرى - السعودية';
      case CalculationMethod.isna:
        return 'الجمعية الإسلامية لأمريكا الشمالية';
      case CalculationMethod.muslimWorldLeague:
        return 'رابطة العالم الإسلامي';
      case CalculationMethod.karachi:
        return 'جامعة العلوم الإسلامية - كراتشي';
      case CalculationMethod.dubai:
        return 'دبي';
      case CalculationMethod.kuwait:
        return 'الكويت';
      case CalculationMethod.qatar:
        return 'قطر';
      case CalculationMethod.singapore:
        return 'سنغافورة';
      case CalculationMethod.northAmerica:
        return 'أمريكا الشمالية';
      case CalculationMethod.other:
        return 'أخرى';
    }
  }
}

/// Displays a prayer clock time as 24-hour or 12-hour.
class PrayerClock {
  static String format(
    DateTime time, {
    required bool use24Hour,
    required bool arabic,
  }) {
    final minute = time.minute.toString().padLeft(2, '0');
    if (use24Hour) {
      return '${time.hour.toString().padLeft(2, '0')}:$minute';
    }
    final hour12 = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final suffix = time.hour < 12 ? (arabic ? 'ص' : 'AM') : (arabic ? 'م' : 'PM');
    return '$hour12:$minute $suffix';
  }
}
