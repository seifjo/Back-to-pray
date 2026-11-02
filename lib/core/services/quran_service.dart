import 'dart:convert';

import 'package:flutter/services.dart';

import '../../data/quran_data.dart';
import '../../models/quran.dart';

/// The Uthmani text is bundled with the app, so reading works without internet.
class QuranService {
  Map<String, List<String>>? _verses;

  Future<List<Surah>> getAllSurahs() async => QuranData.surahs;

  Future<Surah> getSurahDetail(int surahNumber) async {
    final verses = await _load();
    final lines = verses['$surahNumber'];
    if (lines == null || lines.isEmpty) {
      throw Exception('Surah $surahNumber is not in the local Quran text');
    }
    final meta = QuranData.surahs.firstWhere((surah) => surah.number == surahNumber);
    return Surah(
      number: surahNumber,
      name: meta.name,
      englishName: meta.englishName,
      ayahs: [
        for (var i = 0; i < lines.length; i++)
          Ayah(number: i + 1, text: lines[i], juz: 0, page: 0),
      ],
    );
  }

  Future<Map<String, List<String>>> _load() async {
    final existing = _verses;
    if (existing != null) return existing;
    final raw = await rootBundle.loadString('assets/quran/uthmani.json');
    final decoded = json.decode(raw) as Map<String, dynamic>;
    final verses = <String, List<String>>{
      for (final entry in decoded.entries)
        entry.key: (entry.value as List).map((line) => line.toString()).toList(),
    };
    _verses = verses;
    return verses;
  }
}
