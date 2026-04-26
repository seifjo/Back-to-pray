import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/quran.dart';

/// Quran Service
/// Fetches Quran data from Quran.com API (V4)
class QuranService {
  static const String _baseUrl = 'https://api.quran.com/api/v4';

  /// Get list of all 114 surahs
  Future<List<Surah>> getAllSurahs() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/chapters?language=ar'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List surahsJson = data['chapters'];
        
        return surahsJson.map((json) => Surah(
          number: json['id'],
          name: json['name_arabic'],
          englishName: json['name_complex'],
          ayahs: [],
        )).toList();
      } else {
        throw Exception('Failed to load surahs');
      }
    } catch (e) {
      print('Error loading surahs: $e');
      rethrow;
    }
  }

  /// Get full surah with ayahs
  Future<Surah> getSurahDetail(int surahNumber) async {
    try {
      // Fetch Uthmani text with a high per_page to get all ayahs at once
      // Baqarah is 286 ayahs, so 300 is enough.
      final response = await http.get(
        Uri.parse('$_baseUrl/quran/verses/uthmani?chapter_number=$surahNumber')
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List verses = data['verses'];
        
        final List<Ayah> ayahs = verses.map((v) {
          // verse_key is e.g. "1:1", "1:2"
          final keyParts = v['verse_key'].split(':');
          final verseNumber = int.parse(keyParts[1]);
          
          return Ayah(
            number: verseNumber,
            text: v['text_uthmani'],
            juz: 0, // Simplified for now to ensure stability
            page: 0,
          );
        }).toList();
        
        return Surah(
          number: surahNumber,
          name: '', 
          englishName: '',
          ayahs: ayahs,
        );
      } else {
        throw Exception('Failed to load surah details');
      }
    } catch (e) {
      print('Error loading surah details: $e');
      rethrow;
    }
  }
}
