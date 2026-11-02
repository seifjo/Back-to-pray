import '../models/quran_reciter.dart';

/// Curated reciters whose stream folders come from the public
/// [mp3quran.net API v3](https://mp3quran.net/api/v3/reciters) (Hafs Murattal,
/// 114 surahs) and whose ayah editions — when listed — come from
/// [islamic.network](https://cdn.islamic.network/quran/audio).
///
/// Do not invent CDN paths. Prefer verifying against the API / CDN before
/// adding entries. Reciters without an ayah edition stay surah-only.
class QuranRecitersCatalog {
  QuranRecitersCatalog._();

  static const defaultReciterId = 'mishary-alafasy';

  static const List<QuranReciter> all = [
    QuranReciter(
      id: 'mishary-alafasy',
      nameEn: 'Mishary Rashid Alafasy',
      nameAr: 'مشاري راشد العفاسي',
      surahServerBase: 'https://cdn.mp3quran.net/audio/mishary-alafasy/r1/',
      ayahEdition: 'ar.alafasy',
      ayahBitrates: [64, 128],
      imageAsset: 'assets/images/alnoor_logo.png',
      sourceNoteEn: 'mp3quran API v3 · islamic.network ar.alafasy',
      sourceNoteAr: 'واجهة mp3quran · islamic.network ar.alafasy',
    ),
    QuranReciter(
      id: 'abdulrahman-sudais',
      nameEn: 'Abdul Rahman Al-Sudais',
      nameAr: 'عبد الرحمن السديس',
      surahServerBase: 'https://cdn.mp3quran.net/audio/abdulrahman-sudais/r1/',
      ayahEdition: 'ar.abdurrahmaansudais',
      ayahBitrates: [64],
      imageAsset: 'assets/images/alnoor_logo.png',
      sourceNoteEn: 'mp3quran API v3 · islamic.network ar.abdurrahmaansudais',
      sourceNoteAr: 'واجهة mp3quran · islamic.network ar.abdurrahmaansudais',
    ),
    QuranReciter(
      id: 'saud-shuraim',
      nameEn: 'Saud Al-Shuraim',
      nameAr: 'سعود الشريم',
      surahServerBase: 'https://cdn.mp3quran.net/audio/saud-shuraim/r1/',
      ayahEdition: 'ar.saoodshuraym',
      ayahBitrates: [64],
      imageAsset: 'assets/images/alnoor_logo.png',
      sourceNoteEn: 'mp3quran API v3 · islamic.network ar.saoodshuraym',
      sourceNoteAr: 'واجهة mp3quran · islamic.network ar.saoodshuraym',
    ),
    QuranReciter(
      id: 'maher-muaiqly',
      nameEn: 'Maher Al-Muaiqly',
      nameAr: 'ماهر المعيقلي',
      surahServerBase: 'https://cdn.mp3quran.net/audio/maher-muaiqly/r1/',
      ayahEdition: 'ar.mahermuaiqly',
      ayahBitrates: [64, 128],
      imageAsset: 'assets/images/alnoor_logo.png',
      sourceNoteEn: 'mp3quran API v3 · islamic.network ar.mahermuaiqly',
      sourceNoteAr: 'واجهة mp3quran · islamic.network ar.mahermuaiqly',
    ),
    QuranReciter(
      id: 'yasser-dosari',
      nameEn: 'Yasser Al-Dosari',
      nameAr: 'ياسر الدوسري',
      surahServerBase: 'https://cdn.mp3quran.net/audio/yasser-dosari/r1/',
      ayahEdition: null,
      ayahAvailable: false,
      imageAsset: 'assets/images/alnoor_logo.png',
      sourceNoteEn: 'mp3quran API v3 (surah). Ayah audio not published.',
      sourceNoteAr: 'واجهة mp3quran (سور). لا تتوفر تسجيلات آية منشورة.',
    ),
    QuranReciter(
      id: 'mahmoud-husary',
      nameEn: 'Mahmoud Khalil Al-Husary',
      nameAr: 'محمود خليل الحصري',
      surahServerBase: 'https://cdn.mp3quran.net/audio/mahmoud-husary/r1/',
      ayahEdition: 'ar.husary',
      ayahBitrates: [64, 128],
      imageAsset: 'assets/images/alnoor_logo.png',
      sourceNoteEn: 'mp3quran API v3 · islamic.network ar.husary',
      sourceNoteAr: 'واجهة mp3quran · islamic.network ar.husary',
    ),
    QuranReciter(
      id: 'muhammad-minshawi',
      nameEn: 'Mohamed Siddiq El-Minshawi',
      nameAr: 'محمد صديق المنشاوي',
      surahServerBase: 'https://cdn.mp3quran.net/audio/muhammad-minshawi/r1/',
      ayahEdition: 'ar.minshawi',
      ayahBitrates: [128],
      imageAsset: 'assets/images/alnoor_logo.png',
      sourceNoteEn: 'mp3quran API v3 · islamic.network ar.minshawi',
      sourceNoteAr: 'واجهة mp3quran · islamic.network ar.minshawi',
    ),
    QuranReciter(
      id: 'abdulbasit-abdulsamad',
      nameEn: 'Abdul Basit Abdus Samad',
      nameAr: 'عبد الباسط عبد الصمد',
      surahServerBase:
          'https://cdn.mp3quran.net/audio/abdulbasit-abdulsamad/r3/',
      ayahEdition: 'ar.abdulbasitmurattal',
      ayahBitrates: [64],
      imageAsset: 'assets/images/alnoor_logo.png',
      sourceNoteEn: 'mp3quran API v3 · islamic.network ar.abdulbasitmurattal',
      sourceNoteAr: 'واجهة mp3quran · islamic.network ar.abdulbasitmurattal',
    ),
    QuranReciter(
      id: 'muhammad-ayyub',
      nameEn: 'Muhammad Ayyub',
      nameAr: 'محمد أيوب',
      surahServerBase: 'https://cdn.mp3quran.net/audio/muhammad-ayyub/r1/',
      ayahEdition: 'ar.muhammadayyoub',
      ayahBitrates: [128],
      imageAsset: 'assets/images/alnoor_logo.png',
      sourceNoteEn: 'mp3quran API v3 · islamic.network ar.muhammadayyoub',
      sourceNoteAr: 'واجهة mp3quran · islamic.network ar.muhammadayyoub',
    ),
    QuranReciter(
      id: 'abdullah-basfar',
      nameEn: 'Abdullah Basfar',
      nameAr: 'عبد الله بصفر',
      surahServerBase: 'https://cdn.mp3quran.net/audio/abdullah-basfar/r1/',
      ayahEdition: 'ar.abdullahbasfar',
      ayahBitrates: [64],
      imageAsset: 'assets/images/alnoor_logo.png',
      sourceNoteEn: 'mp3quran API v3 · islamic.network ar.abdullahbasfar',
      sourceNoteAr: 'واجهة mp3quran · islamic.network ar.abdullahbasfar',
    ),
    QuranReciter(
      id: 'abubakr-shatri',
      nameEn: 'Abu Bakr Al-Shatri',
      nameAr: 'أبو بكر الشاطري',
      surahServerBase: 'https://cdn.mp3quran.net/audio/abubakr-shatri/r1/',
      ayahEdition: 'ar.shaatree',
      ayahBitrates: [64, 128],
      imageAsset: 'assets/images/alnoor_logo.png',
      sourceNoteEn: 'mp3quran API v3 · islamic.network ar.shaatree',
      sourceNoteAr: 'واجهة mp3quran · islamic.network ar.shaatree',
    ),
    QuranReciter(
      id: 'saad-ghamdi',
      nameEn: 'Saad Al-Ghamdi',
      nameAr: 'سعد الغامدي',
      surahServerBase: 'https://cdn.mp3quran.net/audio/saad-ghamdi/r1/',
      ayahEdition: null,
      ayahAvailable: false,
      imageAsset: 'assets/images/alnoor_logo.png',
      sourceNoteEn: 'mp3quran API v3 (surah). Ayah audio not published.',
      sourceNoteAr: 'واجهة mp3quran (سور). لا تتوفر تسجيلات آية منشورة.',
    ),
    QuranReciter(
      id: 'nasser-qatami',
      nameEn: 'Nasser Al-Qatami',
      nameAr: 'ناصر القطامي',
      surahServerBase: 'https://cdn.mp3quran.net/audio/nasser-qatami/r1/',
      ayahEdition: null,
      ayahAvailable: false,
      imageAsset: 'assets/images/alnoor_logo.png',
      sourceNoteEn: 'mp3quran API v3 (surah). Ayah audio not published.',
      sourceNoteAr: 'واجهة mp3quran (سور). لا تتوفر تسجيلات آية منشورة.',
    ),
    QuranReciter(
      id: 'fares-abbad',
      nameEn: 'Fares Abbad',
      nameAr: 'فارس عباد',
      surahServerBase: 'https://cdn.mp3quran.net/audio/fares-abbad/r1/',
      ayahEdition: null,
      ayahAvailable: false,
      imageAsset: 'assets/images/alnoor_logo.png',
      sourceNoteEn: 'mp3quran API v3 (surah). Ayah audio not published.',
      sourceNoteAr: 'واجهة mp3quran (سور). لا تتوفر تسجيلات آية منشورة.',
    ),
    QuranReciter(
      id: 'muhammad-jibreel',
      nameEn: 'Muhammad Jibreel',
      nameAr: 'محمد جبريل',
      surahServerBase: 'https://cdn.mp3quran.net/audio/muhammad-jibreel/r1/',
      ayahEdition: null,
      ayahAvailable: false,
      imageAsset: 'assets/images/alnoor_logo.png',
      sourceNoteEn: 'mp3quran API v3 (surah). Ayah audio not published.',
      sourceNoteAr: 'واجهة mp3quran (سور). لا تتوفر تسجيلات آية منشورة.',
    ),
    QuranReciter(
      id: 'hani-rifai',
      nameEn: 'Hani Ar-Rifai',
      nameAr: 'هاني الرفاعي',
      surahServerBase: 'https://cdn.mp3quran.net/audio/hani-rifai/r1/',
      ayahEdition: null,
      ayahAvailable: false,
      imageAsset: 'assets/images/alnoor_logo.png',
      sourceNoteEn: 'mp3quran API v3 (surah). Ayah audio not published.',
      sourceNoteAr: 'واجهة mp3quran (سور). لا تتوفر تسجيلات آية منشورة.',
    ),
    QuranReciter(
      id: 'bandar-baleela',
      nameEn: 'Bandar Baleela',
      nameAr: 'بندر بليلة',
      surahServerBase: 'https://cdn.mp3quran.net/audio/bandar-baleela/r1/',
      ayahEdition: null,
      ayahAvailable: false,
      imageAsset: 'assets/images/alnoor_logo.png',
      sourceNoteEn: 'mp3quran API v3 (surah). Ayah audio not published.',
      sourceNoteAr: 'واجهة mp3quran (سور). لا تتوفر تسجيلات آية منشورة.',
    ),
    QuranReciter(
      id: 'abdullah-juhani',
      nameEn: 'Abdullah Al-Juhani',
      nameAr: 'عبد الله الجهني',
      surahServerBase: 'https://cdn.mp3quran.net/audio/abdullah-juhani/r1/',
      ayahEdition: null,
      ayahAvailable: false,
      imageAsset: 'assets/images/alnoor_logo.png',
      sourceNoteEn: 'mp3quran API v3 (surah). Ayah audio not published.',
      sourceNoteAr: 'واجهة mp3quran (سور). لا تتوفر تسجيلات آية منشورة.',
    ),
    QuranReciter(
      id: 'ali-jaber',
      nameEn: 'Ali Jaber',
      nameAr: 'علي جابر',
      surahServerBase: 'https://cdn.mp3quran.net/audio/ali-jaber/r1/',
      ayahEdition: null,
      ayahAvailable: false,
      imageAsset: 'assets/images/alnoor_logo.png',
      sourceNoteEn: 'mp3quran API v3 (surah). Ayah audio not published.',
      sourceNoteAr: 'واجهة mp3quran (سور). لا تتوفر تسجيلات آية منشورة.',
    ),
    QuranReciter(
      id: 'ibrahim-dosari',
      nameEn: 'Ibrahim Al-Dosari',
      nameAr: 'إبراهيم الدوسري',
      surahServerBase: 'https://cdn.mp3quran.net/audio/ibrahim-dosari/r2/',
      ayahEdition: null,
      ayahAvailable: false,
      imageAsset: 'assets/images/alnoor_logo.png',
      sourceNoteEn: 'mp3quran API v3 (Hafs Murattal). Ayah audio not published.',
      sourceNoteAr: 'واجهة mp3quran (حفص مرتل). لا تتوفر تسجيلات آية منشورة.',
    ),
  ];

  static QuranReciter byId(String? id) {
    if (id == null || id.isEmpty) return defaultReciter;
    for (final reciter in all) {
      if (reciter.id == id) return reciter;
    }
    // Unknown id → keep default; never silently pick a "similar" reciter.
    return defaultReciter;
  }

  static QuranReciter get defaultReciter => byId(defaultReciterId);

  static bool isKnown(String id) => all.any((r) => r.id == id);
}
