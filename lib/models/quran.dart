// Quran Models

class Surah {
  final int number;
  final String name;
  final String englishName;
  final List<Ayah> ayahs;

  const Surah({
    required this.number,
    required this.name,
    required this.englishName,
    required this.ayahs,
  });
}

class Ayah {
  final int number;
  final String text;
  final int juz;
  final int page;

  const Ayah({
    required this.number,
    required this.text,
    required this.juz,
    required this.page,
  });
}
