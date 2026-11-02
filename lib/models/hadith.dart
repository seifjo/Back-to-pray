/// Hadith models backed by fawazahmed0/hadith-api (Unlicense).
class HadithGrade {
  final String name;
  final String grade;

  const HadithGrade({required this.name, required this.grade});

  factory HadithGrade.fromJson(Map<String, dynamic> json) {
    return HadithGrade(
      name: json['name']?.toString() ?? '',
      grade: json['grade']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'name': name, 'grade': grade};
}

class HadithItem {
  final String id;
  final String collection;
  final String collectionName;
  final int number;
  final num arabicNumber;
  final String arabic;
  final String english;
  final List<HadithGrade> grades;
  final int? book;
  final int? hadithInBook;
  final String? seedCategory;

  const HadithItem({
    required this.id,
    required this.collection,
    required this.collectionName,
    required this.number,
    required this.arabicNumber,
    required this.arabic,
    required this.english,
    this.grades = const [],
    this.book,
    this.hadithInBook,
    this.seedCategory,
  });

  bool get hasGrades => grades.any((g) => g.grade.trim().isNotEmpty);

  String? get narrator {
    final match = RegExp(
      r'^Narrated\s+([^:]+):',
      caseSensitive: false,
    ).firstMatch(english.trim());
    return match?.group(1)?.trim();
  }

  String get referenceLabel {
    final parts = <String>[collectionName];
    if (book != null && hadithInBook != null) {
      parts.add('Book $book, Hadith $hadithInBook');
    } else {
      parts.add('No. $number');
    }
    return parts.join(' · ');
  }

  factory HadithItem.fromJson(Map<String, dynamic> json) {
    final reference = json['reference'];
    int? book;
    int? hadithInBook;
    if (reference is Map) {
      book = (reference['book'] as num?)?.toInt();
      hadithInBook = (reference['hadith'] as num?)?.toInt();
    }
    final rawGrades = json['grades'];
    final grades = <HadithGrade>[];
    if (rawGrades is List) {
      for (final item in rawGrades) {
        if (item is Map) {
          grades.add(HadithGrade.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    return HadithItem(
      id: json['id']?.toString() ??
          '${json['collection']}:${json['number']}',
      collection: json['collection']?.toString() ?? '',
      collectionName: json['collectionName']?.toString() ?? '',
      number: (json['number'] as num?)?.toInt() ?? 0,
      arabicNumber: json['arabicNumber'] as num? ?? json['number'] as num? ?? 0,
      arabic: json['arabic']?.toString() ?? '',
      english: json['english']?.toString() ?? '',
      grades: grades,
      book: book,
      hadithInBook: hadithInBook,
      seedCategory: json['seedCategory']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'collection': collection,
      'collectionName': collectionName,
      'number': number,
      'arabicNumber': arabicNumber,
      'arabic': arabic,
      'english': english,
      'grades': grades.map((g) => g.toJson()).toList(),
      'reference': {
        if (book != null) 'book': book,
        if (hadithInBook != null) 'hadith': hadithInBook,
      },
      if (seedCategory != null) 'seedCategory': seedCategory,
    };
  }
}

class HadithCollectionInfo {
  final String id;
  final String nameKey;
  final String engEdition;
  final String araEdition;
  final bool typicallyGraded;

  const HadithCollectionInfo({
    required this.id,
    required this.nameKey,
    required this.engEdition,
    required this.araEdition,
    this.typicallyGraded = false,
  });
}
