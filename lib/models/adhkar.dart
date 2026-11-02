// Adhkar Models
// Represents morning and evening supplications (adhkar)

class AdhkarItem {
  /// Stable local id within a category (used for progress keys).
  final String id;

  /// Canonical content id shared across categories for deduplication.
  /// When the same dhikr appears in multiple lists, they share [contentId].
  final String contentId;

  final String arabicText;
  final int repetitions;

  /// Human-readable source line shown in the reader (book / ayah / citation).
  final String reference;

  final String? transliteration;
  final String translation;
  final String? explanation;

  /// Companion who narrated the report, when reliably known.
  final String? narrator;

  /// Collection / book name when distinct from [reference] display text.
  final String? sourceBook;

  /// Hadith number when reliably available (never invented).
  final String? referenceNumber;

  /// Authenticity note when available (e.g. "Sahih" for Bukhari/Muslim only).
  final String? authenticity;

  const AdhkarItem({
    this.id = '',
    this.contentId = '',
    required this.arabicText,
    required this.repetitions,
    required this.reference,
    this.transliteration,
    required this.translation,
    this.explanation,
    this.narrator,
    this.sourceBook,
    this.referenceNumber,
    this.authenticity,
  });

  /// Prefer explicit contentId, else id, else arabic (legacy).
  String get stableContentId =>
      contentId.isNotEmpty ? contentId : (id.isNotEmpty ? id : arabicText);

  String get attributionLine {
    final parts = <String>[
      if (narrator != null && narrator!.trim().isNotEmpty) narrator!.trim(),
      if (reference.trim().isNotEmpty) reference.trim(),
      if (sourceBook != null &&
          sourceBook!.trim().isNotEmpty &&
          sourceBook!.trim() != reference.trim())
        sourceBook!.trim(),
      if (referenceNumber != null && referenceNumber!.trim().isNotEmpty)
        'No. ${referenceNumber!.trim()}',
      if (authenticity != null && authenticity!.trim().isNotEmpty)
        authenticity!.trim(),
    ];
    // Deduplicate while preserving order.
    final seen = <String>{};
    final unique = <String>[];
    for (final part in parts) {
      if (seen.add(part)) unique.add(part);
    }
    if (unique.isEmpty) return reference;
    return unique.join(' · ');
  }

  AdhkarItem copyWith({
    String? id,
    String? contentId,
    String? arabicText,
    int? repetitions,
    String? reference,
    String? transliteration,
    String? translation,
    String? explanation,
    String? narrator,
    String? sourceBook,
    String? referenceNumber,
    String? authenticity,
  }) {
    return AdhkarItem(
      id: id ?? this.id,
      contentId: contentId ?? this.contentId,
      arabicText: arabicText ?? this.arabicText,
      repetitions: repetitions ?? this.repetitions,
      reference: reference ?? this.reference,
      transliteration: transliteration ?? this.transliteration,
      translation: translation ?? this.translation,
      explanation: explanation ?? this.explanation,
      narrator: narrator ?? this.narrator,
      sourceBook: sourceBook ?? this.sourceBook,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      authenticity: authenticity ?? this.authenticity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contentId': contentId,
      'arabicText': arabicText,
      'repetitions': repetitions,
      'reference': reference,
      'transliteration': transliteration,
      'translation': translation,
      'explanation': explanation,
      'narrator': narrator,
      'sourceBook': sourceBook,
      'referenceNumber': referenceNumber,
      'authenticity': authenticity,
    };
  }

  factory AdhkarItem.fromJson(Map<String, dynamic> json) {
    return AdhkarItem(
      id: json['id'] as String? ?? '',
      contentId: json['contentId'] as String? ?? '',
      arabicText: json['arabicText'] as String,
      repetitions: json['repetitions'] as int,
      reference: json['reference'] as String,
      transliteration: json['transliteration'] as String?,
      translation: json['translation'] as String,
      explanation: json['explanation'] as String?,
      narrator: json['narrator'] as String?,
      sourceBook: json['sourceBook'] as String?,
      referenceNumber: json['referenceNumber'] as String?,
      authenticity: json['authenticity'] as String?,
    );
  }
}

class AdhkarCategory {
  final String id;
  final String name;
  final String nameEn;
  final String description;
  final String descriptionEn;
  final String recommendedTime;
  final String recommendedTimeEn;
  final String icon;
  final List<AdhkarItem> items;

  const AdhkarCategory({
    this.id = '',
    required this.name,
    this.nameEn = '',
    required this.description,
    this.descriptionEn = '',
    required this.recommendedTime,
    this.recommendedTimeEn = '',
    this.icon = '✦',
    required this.items,
  });

  String displayName(bool english) =>
      english && nameEn.isNotEmpty ? nameEn : name;

  String displayDescription(bool english) =>
      english && descriptionEn.isNotEmpty ? descriptionEn : description;

  String displayTime(bool english) =>
      english && recommendedTimeEn.isNotEmpty
          ? recommendedTimeEn
          : recommendedTime;

  String get stableId => id.isNotEmpty ? id : name;

  int get itemCount => items.length;
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
