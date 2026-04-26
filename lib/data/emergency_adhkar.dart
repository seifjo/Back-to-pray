// Emergency Adhkar for Urge Resistance
// 90-second motivational adhkar and messages

class EmergencyAdhkar {
  static const List<Map<String, String>> adhkar = [
    {
      'arabic': 'أَعُوذُ بِاللَّهِ السَّمِيعِ الْعَلِيمِ مِنَ الشَّيْطَانِ الرَّجِيمِ',
      'transliteration': 'A\'ūdhu billāhi s-samī\'i l-\'alīmi min ash-shayṭāni r-rajīm',
      'meaning': 'أستعيذ بالله السميع العليم من الشيطان الرجيم',
      'benefit': 'الحماية من همزات الشيطان',
      'duration': '15',
    },
    {
      'arabic': 'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
      'transliteration': 'Lā ilāha illallāhu waḥdahu lā sharīka lah',
      'meaning': 'لا إله إلا الله وحده لا شريك له، له الملك وله الحمد وهو على كل شيء قدير',
      'benefit': 'تقوية الإيمان وطرد الوساوس',
      'duration': '15',
    },
    {
      'arabic': 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ',
      'transliteration': 'Ḥasbunallāhu wa ni\'mal-wakīl',
      'meaning': 'الله كافينا ونعم الوكيل',
      'benefit': 'الاستعانة بالله واليقين بحمايته',
      'duration': '10',
    },
    {
      'arabic': 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ الْهَمِّ وَالْحَزَنِ، وَأَعُوذُ بِكَ مِنَ الْعَجْزِ وَالْكَسَلِ',
      'transliteration': 'Allāhumma innī a\'ūdhu bika min al-hammi wal-ḥazan',
      'meaning': 'اللهم إني أعوذ بك من الهم والحزن والعجز والكسل',
      'benefit': 'طرد القلق وتقوية العزيمة',
      'duration': '15',
    },
    {
      'arabic': 'رَبِّ أَعُوذُ بِكَ مِنْ هَمَزَاتِ الشَّيَاطِينِ وَأَعُوذُ بِكَ رَبِّ أَنْ يَحْضُرُونِ',
      'transliteration': 'Rabbi a\'ūdhu bika min hamazāti sh-shayāṭīn',
      'meaning': 'ربِّ أعوذ بك من همزات الشياطين',
      'benefit': 'الحماية من وسوسة الشيطان',
      'duration': '15',
    },
    {
      'arabic': 'اللَّهُمَّ طَهِّرْ قَلْبِي مِنَ النِّفَاقِ، وَعَمَلِي مِنَ الرِّيَاءِ، وَلِسَانِي مِنَ الْكَذِبِ، وَعَيْنِي مِنَ الْخِيَانَةِ',
      'transliteration': 'Allāhumma ṭahhir qalbī min an-nifāq',
      'meaning': 'اللهم طهر قلبي من النفاق وعملي من الرياء',
      'benefit': 'تطهير القلب والنفس',
      'duration': '20',
    },
  ];

  static const List<String> motivationalMessages = [
    '💪 أنت أقوى من هذه اللحظة!',
    '🌟 كل ثانية تقاومها هي انتصار',
    '🔥 أنت تبني إرادة من حديد',
    '⭐ الله معك في هذه المعركة',
    '🎯 تذكر لماذا بدأت هذه الرحلة',
    '💎 أنت تستحق حياة أفضل',
    '🌱 دماغك يتعافى الآن',
    '👑 أنت أكبر من شهواتك',
    '🦅 ارتفع فوق هذا الضعف',
    '✨ النصر قريب، استمر!',
  ];

  static const List<Map<String, String>> breathingExercises = [
    {
      'title': 'تنفس عميق - 4-7-8',
      'instruction': 'شهيق 4 ثواني\nاحبس 7 ثواني\nزفير 8 ثواني',
      'benefit': 'يهدئ الجهاز العصبي',
      'duration': '30',
    },
    {
      'title': 'تنفس متوازن',
      'instruction': 'شهيق 5 ثواني\nزفير 5 ثواني\nكرر بهدوء',
      'benefit': 'يقلل القلق والتوتر',
      'duration': '30',
    },
  ];

  static const List<String> quickReminders = [
    'اشرب كوب ماء بارد 💧',
    'قف وتحرك من مكانك 🚶',
    'افتح النافذة واستنشق الهواء 🌬️',
    'اتصل بصديق صالح 📞',
    'توضأ الآن 💦',
    'صلِّ ركعتين 🕌',
    'اقرأ صفحة من القرآن 📖',
    'اخرج للمشي 5 دقائق 🏃',
  ];

  /// Get duration in seconds for emergency session
  static int getTotalDuration() => 90;

  /// Get dhikr by index
  static Map<String, String>? getDhikr(int index) {
    if (index >= 0 && index < adhkar.length) {
      return adhkar[index];
    }
    return null;
  }

  /// Get random motivational message
  static String getRandomMotivation() {
    return motivationalMessages[
        DateTime.now().second % motivationalMessages.length];
  }

  /// Get breathing exercise
  static Map<String, String> getBreathingExercise() {
    return breathingExercises[0]; // Return first one for now
  }

  /// Get quick action reminder
  static String getRandomQuickAction() {
    return quickReminders[DateTime.now().second % quickReminders.length];
  }
}
