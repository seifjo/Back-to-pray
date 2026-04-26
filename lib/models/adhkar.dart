// Adhkar Models
// Represents morning and evening supplications (adhkar)

class AdhkarItem {
  final String arabicText;
  final int repetitions;
  final String reference;
  final String? transliteration;
  final String translation;

  const AdhkarItem({
    required this.arabicText,
    required this.repetitions,
    required this.reference,
    this.transliteration,
    required this.translation,
  });

  Map<String, dynamic> toJson() {
    return {
      'arabicText': arabicText,
      'repetitions': repetitions,
      'reference': reference,
      'transliteration': transliteration,
      'translation': translation,
    };
  }

  factory AdhkarItem.fromJson(Map<String, dynamic> json) {
    return AdhkarItem(
     arabicText: json['arabicText'],
      repetitions: json['repetitions'],
      reference: json['reference'],
      transliteration: json['transliteration'],
      translation: json['translation'],
    );
  }
}

class AdhkarCategory {
  final String name;
  final String description;
  final String recommendedTime;
  final List<AdhkarItem> items;

  const AdhkarCategory({
    required this.name,
    required this.description,
    required this.recommendedTime,
    required this.items,
  });
}

enum AdhkarType {
  morning,
  evening,
}

extension AdhkarTypeExtension on AdhkarType {
  String get arabicName {
    switch (this) {
      case AdhkarType.morning:
        return 'أذكار الصباح';
      case AdhkarType.evening:
        return 'أذكار المساء';
    }
  }
}
