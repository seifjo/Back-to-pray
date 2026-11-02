class HadithVocabularyEntry {
  final String term;
  final String definition;

  const HadithVocabularyEntry({
    required this.term,
    required this.definition,
  });

  factory HadithVocabularyEntry.fromJson(Map<String, dynamic> json) {
    return HadithVocabularyEntry(
      term: json['term']?.toString() ?? '',
      definition: json['definition']?.toString() ?? '',
    );
  }
}

/// Scholarly explanation keyed by stable Hadith ID (e.g. nawawi:1).
class HadithExplanation {
  final String hadithId;
  final bool available;
  final String authorAr;
  final String authorEn;
  final String sourceBookAr;
  final String sourceBookEn;
  final String sourceReference;
  final String licenseNote;
  final String scholarlyArabic;
  final String scholarlyEnglish;
  final List<HadithVocabularyEntry> vocabulary;
  final String contextAr;
  final String contextEn;
  final List<String> lessonsAr;
  final List<String> lessonsEn;
  final String applicationAr;
  final String applicationEn;
  final String summaryNoteAr;
  final String summaryNoteEn;

  const HadithExplanation({
    required this.hadithId,
    required this.available,
    this.authorAr = '',
    this.authorEn = '',
    this.sourceBookAr = '',
    this.sourceBookEn = '',
    this.sourceReference = '',
    this.licenseNote = '',
    this.scholarlyArabic = '',
    this.scholarlyEnglish = '',
    this.vocabulary = const [],
    this.contextAr = '',
    this.contextEn = '',
    this.lessonsAr = const [],
    this.lessonsEn = const [],
    this.applicationAr = '',
    this.applicationEn = '',
    this.summaryNoteAr = '',
    this.summaryNoteEn = '',
  });

  bool get hasScholarlyBody =>
      scholarlyArabic.trim().isNotEmpty || scholarlyEnglish.trim().isNotEmpty;

  String author(bool english) => english ? authorEn : authorAr;

  String sourceBook(bool english) => english ? sourceBookEn : sourceBookAr;

  String context(bool english) => english ? contextEn : contextAr;

  List<String> lessons(bool english) => english ? lessonsEn : lessonsAr;

  String application(bool english) => english ? applicationEn : applicationAr;

  String summaryNote(bool english) => english ? summaryNoteEn : summaryNoteAr;

  String scholarlyBody(bool english) =>
      english ? scholarlyEnglish : scholarlyArabic;

  factory HadithExplanation.unavailable(String hadithId) {
    return HadithExplanation(hadithId: hadithId, available: false);
  }

  factory HadithExplanation.fromJson(Map<String, dynamic> json) {
    final vocabulary = <HadithVocabularyEntry>[];
    final rawVocab = json['vocabulary'];
    if (rawVocab is List) {
      for (final item in rawVocab) {
        if (item is Map) {
          vocabulary.add(
            HadithVocabularyEntry.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }
    List<String> strings(dynamic value) {
      if (value is! List) return const [];
      return value.map((item) => item.toString()).where((s) => s.isNotEmpty).toList();
    }

    return HadithExplanation(
      hadithId: json['hadithId']?.toString() ?? '',
      available: json['available'] as bool? ?? false,
      authorAr: json['authorAr']?.toString() ?? '',
      authorEn: json['authorEn']?.toString() ?? '',
      sourceBookAr: json['sourceBookAr']?.toString() ?? '',
      sourceBookEn: json['sourceBookEn']?.toString() ?? '',
      sourceReference: json['sourceReference']?.toString() ?? '',
      licenseNote: json['licenseNote']?.toString() ?? '',
      scholarlyArabic: json['scholarlyArabic']?.toString() ?? '',
      scholarlyEnglish: json['scholarlyEnglish']?.toString() ?? '',
      vocabulary: vocabulary,
      contextAr: json['contextAr']?.toString() ?? '',
      contextEn: json['contextEn']?.toString() ?? '',
      lessonsAr: strings(json['lessonsAr']),
      lessonsEn: strings(json['lessonsEn']),
      applicationAr: json['applicationAr']?.toString() ?? '',
      applicationEn: json['applicationEn']?.toString() ?? '',
      summaryNoteAr: json['summaryNoteAr']?.toString() ?? '',
      summaryNoteEn: json['summaryNoteEn']?.toString() ?? '',
    );
  }
}
