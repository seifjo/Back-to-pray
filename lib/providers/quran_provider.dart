import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuranProvider with ChangeNotifier {
  int? _lastSurahNumber;
  int? _lastAyahNumber;
  String? _lastSurahName;

  int? get lastSurahNumber => _lastSurahNumber;
  int? get lastAyahNumber => _lastAyahNumber;
  String? get lastSurahName => _lastSurahName;

  QuranProvider() {
    _loadLastRead();
  }

  Future<void> _loadLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    _lastSurahNumber = prefs.getInt('last_surah_number');
    _lastAyahNumber = prefs.getInt('last_ayah_number');
    _lastSurahName = prefs.getString('last_surah_name');
    notifyListeners();
  }

  Future<void> saveLastRead(int surahNumber, int ayahNumber, String surahName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_surah_number', surahNumber);
    await prefs.setInt('last_ayah_number', ayahNumber);
    await prefs.setString('last_surah_name', surahName);
    
    _lastSurahNumber = surahNumber;
    _lastAyahNumber = ayahNumber;
    _lastSurahName = surahName;
    notifyListeners();
  }

  Future<void> clearLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('last_surah_number');
    await prefs.remove('last_ayah_number');
    await prefs.remove('last_surah_name');
    
    _lastSurahNumber = null;
    _lastAyahNumber = null;
    _lastSurahName = null;
    notifyListeners();
  }
}
