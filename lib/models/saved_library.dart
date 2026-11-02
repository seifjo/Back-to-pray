/// Content kinds surfaced in the unified Saved Library.
enum SavedContentType {
  hadith,
  hadithExplanation,
  adhkar,
  dua,
  quranBookmark,
  namesOfAllah,
}

/// Lightweight library row: stable ID + display metadata (not a content copy).
class SavedLibraryItem {
  final SavedContentType type;

  /// Stable identifier in the source module (hadith id, dua id, etc.).
  final String sourceId;

  /// Composite key unique across the library: `type:sourceId`.
  final String libraryKey;

  final String titleEn;
  final String titleAr;
  final String subtitleEn;
  final String subtitleAr;
  final String? previewEn;
  final String? previewAr;

  /// True when the source module still has resolvable content.
  final bool available;

  final DateTime savedAt;
  final DateTime? lastViewedAt;

  /// Extra navigation payload (e.g. adhkar category id, quran surah/ayah).
  final Map<String, String> routeArgs;

  const SavedLibraryItem({
    required this.type,
    required this.sourceId,
    required this.libraryKey,
    required this.titleEn,
    required this.titleAr,
    required this.subtitleEn,
    required this.subtitleAr,
    this.previewEn,
    this.previewAr,
    required this.available,
    required this.savedAt,
    this.lastViewedAt,
    this.routeArgs = const {},
  });

  String title(bool english) => english ? titleEn : titleAr;

  String subtitle(bool english) => english ? subtitleEn : subtitleAr;

  String? preview(bool english) {
    if (english) return previewEn;
    return previewAr?.isNotEmpty == true ? previewAr : previewEn;
  }

  SavedLibraryItem copyWith({
    DateTime? savedAt,
    DateTime? lastViewedAt,
    bool? available,
    String? titleEn,
    String? titleAr,
    String? subtitleEn,
    String? subtitleAr,
    String? previewEn,
    String? previewAr,
    Map<String, String>? routeArgs,
  }) {
    return SavedLibraryItem(
      type: type,
      sourceId: sourceId,
      libraryKey: libraryKey,
      titleEn: titleEn ?? this.titleEn,
      titleAr: titleAr ?? this.titleAr,
      subtitleEn: subtitleEn ?? this.subtitleEn,
      subtitleAr: subtitleAr ?? this.subtitleAr,
      previewEn: previewEn ?? this.previewEn,
      previewAr: previewAr ?? this.previewAr,
      available: available ?? this.available,
      savedAt: savedAt ?? this.savedAt,
      lastViewedAt: lastViewedAt ?? this.lastViewedAt,
      routeArgs: routeArgs ?? this.routeArgs,
    );
  }

  static String keyFor(SavedContentType type, String sourceId) =>
      '${type.name}:$sourceId';
}

/// Per-item metadata stored by the Saved Library (not full content).
class SavedLibraryMeta {
  final DateTime savedAt;
  final DateTime? lastViewedAt;

  const SavedLibraryMeta({
    required this.savedAt,
    this.lastViewedAt,
  });

  Map<String, dynamic> toJson() => {
        'savedAt': savedAt.toIso8601String(),
        'lastViewedAt': lastViewedAt?.toIso8601String(),
      };

  factory SavedLibraryMeta.fromJson(Map<String, dynamic> json) {
    return SavedLibraryMeta(
      savedAt: DateTime.parse(json['savedAt'] as String),
      lastViewedAt: json['lastViewedAt'] == null
          ? null
          : DateTime.parse(json['lastViewedAt'] as String),
    );
  }
}
