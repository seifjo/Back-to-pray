/// A dhikr used by the Digital Tasbeeh counter.
class TasbeehDhikr {
  final String id;
  final String arabic;
  final String nameEn;
  final String nameAr;
  final String transliteration;
  /// Traditional count from common practice when known; null means unlimited.
  final int? traditionalTarget;
  final String? traditionalNoteEn;
  final String? traditionalNoteAr;
  /// User-defined personal goal; null means unlimited.
  final int? personalTarget;
  final bool isCustom;
  final bool isFavorite;

  const TasbeehDhikr({
    required this.id,
    required this.arabic,
    required this.nameEn,
    required this.nameAr,
    this.transliteration = '',
    this.traditionalTarget,
    this.traditionalNoteEn,
    this.traditionalNoteAr,
    this.personalTarget,
    this.isCustom = false,
    this.isFavorite = false,
  });

  /// Active goal for the counter UI. Personal goal wins when set.
  int? get activeTarget => personalTarget ?? traditionalTarget;

  bool get hasTraditionalTarget => traditionalTarget != null;

  bool get usesPersonalGoal => personalTarget != null;

  String displayName(bool english) => english ? nameEn : nameAr;

  String? traditionalNote(bool english) =>
      english ? traditionalNoteEn : traditionalNoteAr;

  TasbeehDhikr copyWith({
    String? arabic,
    String? nameEn,
    String? nameAr,
    String? transliteration,
    int? traditionalTarget,
    String? traditionalNoteEn,
    String? traditionalNoteAr,
    int? personalTarget,
    bool clearPersonalTarget = false,
    bool? isCustom,
    bool? isFavorite,
  }) {
    return TasbeehDhikr(
      id: id,
      arabic: arabic ?? this.arabic,
      nameEn: nameEn ?? this.nameEn,
      nameAr: nameAr ?? this.nameAr,
      transliteration: transliteration ?? this.transliteration,
      traditionalTarget: traditionalTarget ?? this.traditionalTarget,
      traditionalNoteEn: traditionalNoteEn ?? this.traditionalNoteEn,
      traditionalNoteAr: traditionalNoteAr ?? this.traditionalNoteAr,
      personalTarget:
          clearPersonalTarget ? null : (personalTarget ?? this.personalTarget),
      isCustom: isCustom ?? this.isCustom,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'arabic': arabic,
        'nameEn': nameEn,
        'nameAr': nameAr,
        'transliteration': transliteration,
        'traditionalTarget': traditionalTarget,
        'traditionalNoteEn': traditionalNoteEn,
        'traditionalNoteAr': traditionalNoteAr,
        'personalTarget': personalTarget,
        'isCustom': isCustom,
        'isFavorite': isFavorite,
      };

  factory TasbeehDhikr.fromJson(Map<String, dynamic> json) {
    return TasbeehDhikr(
      id: json['id']?.toString() ?? '',
      arabic: json['arabic']?.toString() ?? '',
      nameEn: json['nameEn']?.toString() ?? '',
      nameAr: json['nameAr']?.toString() ?? '',
      transliteration: json['transliteration']?.toString() ?? '',
      traditionalTarget: (json['traditionalTarget'] as num?)?.toInt(),
      traditionalNoteEn: json['traditionalNoteEn']?.toString(),
      traditionalNoteAr: json['traditionalNoteAr']?.toString(),
      personalTarget: (json['personalTarget'] as num?)?.toInt(),
      isCustom: json['isCustom'] as bool? ?? false,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }
}

class TasbeehDailyStat {
  final String day; // yyyy-MM-dd
  final Map<String, int> byDhikr;

  const TasbeehDailyStat({required this.day, required this.byDhikr});

  int get total => byDhikr.values.fold(0, (sum, value) => sum + value);

  Map<String, dynamic> toJson() => {'day': day, 'byDhikr': byDhikr};

  factory TasbeehDailyStat.fromJson(Map<String, dynamic> json) {
    final raw = json['byDhikr'];
    final map = <String, int>{};
    if (raw is Map) {
      raw.forEach((key, value) {
        if (value is num) map[key.toString()] = value.toInt();
      });
    }
    return TasbeehDailyStat(day: json['day']?.toString() ?? '', byDhikr: map);
  }
}
