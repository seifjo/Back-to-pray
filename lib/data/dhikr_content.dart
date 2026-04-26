/// Dhikr Content for Urge Resistance
/// Spiritual support during difficult moments
class DhikrContent {
  /// Get dhikr for urge resistance timer
  static List<String> getUrgeResistanceDhikr() {
    return _urgeResistanceDhikr;
  }

  /// Get random dhikr phrase
  static String getRandomDhikr() {
    final index = DateTime.now().second % _urgeResistanceDhikr.length;
    return _urgeResistanceDhikr[index];
  }

  /// Get breathing guidance
  static List<String> getBreathingGuidance() {
    return _breathingGuidance;
  }

  // ========================================
  // DHIKR FOR URGE RESISTANCE
  // ========================================
  static const List<String> _urgeResistanceDhikr = [
    'لا إله إلا الله',
    'سبحان الله وبحمده',
    'استغفر الله العظيم',
    'حسبي الله ونعم الوكيل',
    'لا حول ولا قوة إلا بالله',
    'اللهم إني أعوذ بك من الشيطان الرجيم',
    'رب اشرح لي صدري',
    'يا مقلب القلوب ثبت قلبي على دينك',
  ];

  // ========================================
  // QURANIC VERSES ABOUT PURITY & PATIENCE
  // ========================================
  static const List<String> quranVerses = [
    'وَالَّذِينَ هُمْ لِفُرُوجِهِمْ حَافِظُونَ',
    'إِنَّ اللَّهَ يُحِبُّ التَّوَّابِينَ وَيُحِبُّ الْمُتَطَهِّرِينَ',
    'فَاصْبِرْ إِنَّ الْعَاقِبَةَ لِلْمُتَّقِينَ',
    'وَاسْتَعِينُوا بِالصَّبْرِ وَالصَّلَاةِ',
  ];

  /// Get random Quranic verse
  static String getRandomVerse() {
    final index = DateTime.now().second % quranVerses.length;
    return quranVerses[index];
  }

  // ========================================
  // BREATHING GUIDANCE TEXT
  // ========================================
  static const List<String> _breathingGuidance = [
    'خذ نفساً عميقاً... احبسه... أخرجه ببطء',
    'تنفس من أنفك... احبس 4 ثوانٍ... أخرج من فمك',
    'ركز على تنفسك... أنت في سيطرة كاملة',
    'كل نفس يجلب لك السكينة',
  ];

  // ========================================
  // PROTECTIVE DUAS
  // ========================================
  static const List<String> protectiveDuas = [
    'أعوذ بكلمات الله التامات من شر ما خلق',
    'اللهم إني أسألك العفو والعافية في الدنيا والآخرة',
    'اللهم اهدني فيمن هديت',
    'ربنا آتنا في الدنيا حسنة وفي الآخرة حسنة',
  ];

  /// Get random protective dua
  static String getProtectiveDua() {
    final index = DateTime.now().minute % protectiveDuas.length;
    return protectiveDuas[index];
  }

  // ========================================
  // URGE TIMER ROTATION SEQUENCE
  // ========================================
  /// Get content for a specific second in the timer (0-90)
  static String getTimerContent(int secondsRemaining) {
    if (secondsRemaining > 80) {
      return 'ابدأ بالتنفس العميق...\n\nلا إله إلا الله';
    } else if (secondsRemaining > 70) {
      return 'تنفس ببطء وعمق\n\n${_breathingGuidance[0]}';
    } else if (secondsRemaining > 60) {
      return getRandomDhikr();
    } else if (secondsRemaining > 50) {
      return 'الرغبة مؤقتة... ستمر\n\n${getRandomVerse()}';
    } else if (secondsRemaining > 40) {
      return getRandomDhikr();
    } else if (secondsRemaining > 30) {
      return 'أنت قوي... استمر\n\n${getProtectiveDua()}';
    } else if (secondsRemaining > 20) {
      return getRandomDhikr();
    } else if (secondsRemaining > 10) {
      return 'تقريباً... أنت تنتصر الآن';
    } else {
      return 'قوي! النصر قريب جداً!';
    }
  }
}
