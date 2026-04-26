/// Quran Metadata
/// Static lookup data for Quran structure — ayah counts per surah,
/// juz boundaries, and progress calculation helpers.
///
/// Total Quran: 114 surahs, 6236 ayahs, 604 pages, 30 juz'

class QuranMetadata {
  QuranMetadata._();

  /// Total number of ayahs in the Quran
  static const int totalAyahs = 6236;

  /// Total pages in the Quran
  static const int totalPages = 604;

  /// Number of ayahs in each surah (index 0 = Al-Fatiha)
  static const List<int> ayahsPerSurah = [
    7, 286, 200, 176, 120, 165, 206, 75, 129, 109,   // 1-10
    123, 111, 43, 52, 99, 128, 111, 110, 98, 135,     // 11-20
    112, 78, 118, 64, 77, 227, 93, 88, 69, 60,        // 21-30
    34, 30, 73, 54, 45, 83, 182, 88, 75, 85,          // 31-40
    54, 53, 89, 59, 37, 35, 38, 29, 18, 45,           // 41-50
    60, 49, 62, 55, 78, 96, 29, 22, 24, 13,           // 51-60
    14, 11, 11, 18, 12, 12, 30, 52, 52, 44,           // 61-70
    28, 28, 20, 56, 40, 31, 50, 40, 46, 42,           // 71-80
    29, 19, 36, 25, 22, 17, 19, 26, 30, 20,           // 81-90
    15, 21, 11, 8, 8, 19, 5, 8, 8, 11,                // 91-100
    11, 8, 3, 9, 5, 4, 7, 3, 6, 3,                    // 101-110
    5, 4, 5, 6,                                         // 111-114
  ];

  /// Surah names in Arabic
  static const List<String> surahNames = [
    'الفاتحة', 'البقرة', 'آل عمران', 'النساء', 'المائدة',
    'الأنعام', 'الأعراف', 'الأنفال', 'التوبة', 'يونس',
    'هود', 'يوسف', 'الرعد', 'إبراهيم', 'الحجر',
    'النحل', 'الإسراء', 'الكهف', 'مريم', 'طه',
    'الأنبياء', 'الحج', 'المؤمنون', 'النور', 'الفرقان',
    'الشعراء', 'النمل', 'القصص', 'العنكبوت', 'الروم',
    'لقمان', 'السجدة', 'الأحزاب', 'سبأ', 'فاطر',
    'يس', 'الصافات', 'ص', 'الزمر', 'غافر',
    'فصلت', 'الشورى', 'الزخرف', 'الدخان', 'الجاثية',
    'الأحقاف', 'محمد', 'الفتح', 'الحجرات', 'ق',
    'الذاريات', 'الطور', 'النجم', 'القمر', 'الرحمن',
    'الواقعة', 'الحديد', 'المجادلة', 'الحشر', 'الممتحنة',
    'الصف', 'الجمعة', 'المنافقون', 'التغابن', 'الطلاق',
    'التحريم', 'الملك', 'القلم', 'الحاقة', 'المعارج',
    'نوح', 'الجن', 'المزمل', 'المدثر', 'القيامة',
    'الإنسان', 'المرسلات', 'النبأ', 'النازعات', 'عبس',
    'التكوير', 'الانفطار', 'المطففين', 'الانشقاق', 'البروج',
    'الطارق', 'الأعلى', 'الغاشية', 'الفجر', 'البلد',
    'الشمس', 'الليل', 'الضحى', 'الشرح', 'التين',
    'العلق', 'القدر', 'البينة', 'الزلزلة', 'العاديات',
    'القارعة', 'التكاثر', 'العصر', 'الهمزة', 'الفيل',
    'قريش', 'الماعون', 'الكوثر', 'الكافرون', 'النصر',
    'المسد', 'الإخلاص', 'الفلق', 'الناس',
  ];

  /// Juz' boundaries — each entry is [surahNumber, ayahNumber] where the juz starts
  /// (1-indexed for both surah and ayah)
  static const List<List<int>> juzBoundaries = [
    [1, 1],    // Juz 1
    [2, 142],  // Juz 2
    [2, 253],  // Juz 3
    [3, 93],   // Juz 4
    [4, 24],   // Juz 5
    [4, 148],  // Juz 6
    [5, 83],   // Juz 7
    [6, 111],  // Juz 8
    [7, 88],   // Juz 9
    [8, 41],   // Juz 10
    [9, 93],   // Juz 11
    [11, 6],   // Juz 12
    [12, 53],  // Juz 13
    [15, 1],   // Juz 14
    [17, 1],   // Juz 15
    [18, 75],  // Juz 16
    [21, 1],   // Juz 17
    [23, 1],   // Juz 18
    [25, 21],  // Juz 19
    [27, 56],  // Juz 20
    [29, 46],  // Juz 21
    [33, 31],  // Juz 22
    [36, 28],  // Juz 23
    [39, 32],  // Juz 24
    [41, 47],  // Juz 25
    [46, 1],   // Juz 26
    [51, 31],  // Juz 27
    [58, 1],   // Juz 28
    [67, 1],   // Juz 29
    [78, 1],   // Juz 30
  ];

  /// Cumulative ayah count before each surah (index 0 = before Al-Fatiha = 0)
  static List<int> get cumulativeAyahs {
    final List<int> cumulative = [0];
    for (int i = 0; i < ayahsPerSurah.length; i++) {
      cumulative.add(cumulative.last + ayahsPerSurah[i]);
    }
    return cumulative;
  }

  /// Calculate which juz a given position falls in (1-indexed result)
  static int getJuzForPosition(int surahNumber, int ayahNumber) {
    for (int i = juzBoundaries.length - 1; i >= 0; i--) {
      final boundary = juzBoundaries[i];
      if (surahNumber > boundary[0] ||
          (surahNumber == boundary[0] && ayahNumber >= boundary[1])) {
        return i + 1; // 1-indexed
      }
    }
    return 1;
  }

  /// Calculate overall completion percentage (0.0 - 100.0)
  static double calculateCompletionPercentage(int surahNumber, int ayahNumber) {
    if (surahNumber < 1 || surahNumber > 114) return 0.0;
    final cumulative = cumulativeAyahs;
    final totalRead = cumulative[surahNumber - 1] + ayahNumber;
    return (totalRead / totalAyahs * 100).clamp(0.0, 100.0);
  }

  /// Estimate total pages read based on position
  /// Approximation: 604 pages / 6236 ayahs ≈ 0.0969 pages per ayah
  static int getTotalPagesRead(int surahNumber, int ayahNumber) {
    if (surahNumber < 1 || surahNumber > 114) return 0;
    final cumulative = cumulativeAyahs;
    final totalRead = cumulative[surahNumber - 1] + ayahNumber;
    return (totalRead * totalPages / totalAyahs).round();
  }

  /// Get surah name from number (1-indexed)
  static String getSurahName(int surahNumber) {
    if (surahNumber < 1 || surahNumber > 114) return '';
    return surahNames[surahNumber - 1];
  }
}
