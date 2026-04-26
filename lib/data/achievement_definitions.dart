import '../models/achievement.dart';

/// Achievement Definitions
/// Complete database of all achievements in Arabic
class AchievementDefinitions {
  /// Get all achievement definitions
  static List<Achievement> getAllAchievements() {
    return [
      ..._consistencyAchievements,
      ..._urgeResistanceAchievements,
      ..._spiritualAchievements,
      ..._selfImprovementAchievements,
      ..._comebackAchievements,
      ..._legendaryAchievements,
      ..._hiddenAchievements,
    ];
  }

  // ========================================
  // A - CONSISTENCY ACHIEVEMENTS
  // ========================================
  static final List<Achievement> _consistencyAchievements = [
    const Achievement(
      type: AchievementType.day1,
      id: 'clean_day_1',
      title: 'يوم الالتزام',
      description: 'أكملت يومك الأول بشجاعة',
      benefits: 'بداية استعادة توازن الدوبامين في دماغك',
      category: AchievementCategory.consistency,
      rarity: AchievementRarity.common,
      icon: '🌱',
      xpReward: 10,
    ),
    const Achievement(
      type: AchievementType.day3,
      id: 'clean_day_3',
      title: '3 أيام متتالية',
      description: 'إنجاز رائع! الجسم بدأ في تنظيف نفسه',
      benefits: 'تحسن ملحوظ في جودة النوم والتركيز',
      category: AchievementCategory.consistency,
      rarity: AchievementRarity.common,
      icon: '🔥',
      xpReward: 20,
    ),
    const Achievement(
      type: AchievementType.day7,
      id: 'clean_day_7',
      title: 'أسبوع كامل',
      description: 'أنت بطل! المسارات العصبية بدأت في التغير',
      benefits: 'زيادة واضحة في الثقة بالنفس والتحكم في المشاعر',
      category: AchievementCategory.consistency,
      rarity: AchievementRarity.rare,
      icon: '⭐',
      xpReward: 50,
    ),
    const Achievement(
      type: AchievementType.day14,
      id: 'clean_day_14',
      title: 'أسبوعان قويان',
      description: 'قوة إرادتك تتزايد كل يوم',
      benefits: 'تحسن كبير في الطاقة والحيوية',
      category: AchievementCategory.consistency,
      rarity: AchievementRarity.rare,
      icon: '💫',
      xpReward: 75,
    ),
    const Achievement(
      type: AchievementType.day21,
      id: 'clean_day_21',
      title: 'ثلاثة أسابيع',
      description: 'العادات الجديدة بدأت تترسخ',
      benefits: 'العادة الصحية أصبحت جزءاً من روتينك',
      category: AchievementCategory.consistency,
      rarity: AchievementRarity.rare,
      icon: '🎯',
      xpReward: 100,
    ),
    const Achievement(
      type: AchievementType.day30,
      id: 'clean_day_30',
      title: 'شهر من القوة',
      description: 'شخصية جديدة تولد الآن',
      benefits: 'إعادة بناء كاملة للهوية واستقلالية تامة',
      category: AchievementCategory.consistency,
      rarity: AchievementRarity.epic,
      icon: '🏆',
      xpReward: 200,
    ),
    const Achievement(
      type: AchievementType.day60,
      id: 'clean_day_60',
      title: 'شهران متواصلان',
      description: 'أنت في مستوى متقدم جداً',
      benefits: 'التحكم الكامل في نظام المكافأة في دماغك',
      category: AchievementCategory.consistency,
      rarity: AchievementRarity.epic,
      icon: '💎',
      xpReward: 300,
    ),
    const Achievement(
      type: AchievementType.day90,
      id: 'clean_day_90',
      title: '90 يوماً - الحرية الكاملة',
      description: 'تحول كامل في الدماغ والجسم والنفس',
      benefits: 'الدماغ أعاد بناء نفسه بالكامل',
      category: AchievementCategory.consistency,
      rarity: AchievementRarity.epic,
      icon: '🦅',
      xpReward: 500,
    ),
    const Achievement(
      type: AchievementType.day180,
      id: 'clean_day_180',
      title: 'نصف عام من الانتصار',
      description: 'أنت مصدر إلهام للجميع',
      benefits: 'حياة جديدة تماماً',
      category: AchievementCategory.consistency,
      rarity: AchievementRarity.legendary,
      icon: '👑',
      xpReward: 1000,
    ),
    const Achievement(
      type: AchievementType.day365,
      id: 'clean_day_365',
      title: 'سنة كاملة - الأسطورة',
      description: 'عام كامل من القوة والإرادة',
      benefits: 'أنت قدوة ومثال يُحتذى',
      category: AchievementCategory.consistency,
      rarity: AchievementRarity.legendary,
      icon: '🌟',
      xpReward: 2000,
    ),
  ];

  // ========================================
  // B - URGE RESISTANCE ACHIEVEMENTS
  // ========================================
  static final List<Achievement> _urgeResistanceAchievements = [
    const Achievement(
      type: AchievementType.urgeFirst,
      id: 'urge_first_victory',
      title: 'أول انتصار',
      description: 'استخدم أداة الطوارئ وقاوم رغبتك الأولى بنجاح',
      benefits: 'أثبت لنفسك أنك قادر على السيطرة',
      category: AchievementCategory.urgeResistance,
      rarity: AchievementRarity.common,
      icon: '⚔️',
      xpReward: 30,
    ),
    const Achievement(
      type: AchievementType.urge5,
      id: 'urge_iron_will',
      title: 'إرادة حديدية',
      description: 'قاومت 5 رغبات باستخدام أداة الطوارئ',
      benefits: 'قوة السيطرة تتزايد',
      category: AchievementCategory.urgeResistance,
      rarity: AchievementRarity.rare,
      icon: '🛡️',
      xpReward: 100,
      currentProgress: 0,
      targetProgress: 5,
    ),
    const Achievement(
      type: AchievementType.urge10,
      id: 'urge_steel_mind',
      title: 'عقل فولاذي',
      description: 'قاومت 10 رغبات قوية عبر التطبيق',
      benefits: 'السيطرة الكاملة على النفس',
      category: AchievementCategory.urgeResistance,
      rarity: AchievementRarity.epic,
      icon: '⚡',
      xpReward: 250,
      currentProgress: 0,
      targetProgress: 10,
    ),
    const Achievement(
      type: AchievementType.urgeNight,
      id: 'urge_night_guardian',
      title: 'حارس الليل',
      description: 'قاومت رغبة ليلية باستخدام أداة الطوارئ',
      benefits: 'قهرت أصعب الأوقات',
      category: AchievementCategory.urgeResistance,
      rarity: AchievementRarity.rare,
      icon: '🌙',
      xpReward: 50,
    ),
  ];

  // ========================================
  // C - SPIRITUAL ACHIEVEMENTS
  // ========================================
  static final List<Achievement> _spiritualAchievements = [
    const Achievement(
      type: AchievementType.prayerDay,
      id: 'spiritual_5prayers',
      title: 'صلاة اليوم كاملة',
      description: 'سجّل الصلوات الخمس في سجل الصلاة اليومي',
      benefits: 'القرب من الله يقوي إرادتك',
      category: AchievementCategory.spiritual,
      rarity: AchievementRarity.common,
      icon: '🕌',
      xpReward: 25,
    ),
    const Achievement(
      type: AchievementType.fajrWarrior,
      id: 'spiritual_fajr_week',
      title: 'محارب الفجر',
      description: 'سجّل صلاة الفجر لمدة 7 أيام متتالية',
      benefits: 'بركة في اليوم وقوة في الإرادة',
      category: AchievementCategory.spiritual,
      rarity: AchievementRarity.epic,
      icon: '🌅',
      xpReward: 150,
      currentProgress: 0,
      targetProgress: 7,
    ),
    const Achievement(
      type: AchievementType.quranDaily,
      id: 'spiritual_quran_daily',
      title: 'قارئ القرآن',
      description: 'افتح المصحف للقراءة يومياً لمدة أسبوع',
      benefits: 'السكينة والطمأنينة في القلب',
      category: AchievementCategory.spiritual,
      rarity: AchievementRarity.rare,
      icon: '📖',
      xpReward: 100,
      currentProgress: 0,
      targetProgress: 7,
    ),
  ];

  // ========================================
  // D - SELF-IMPROVEMENT ACHIEVEMENTS
  // ========================================
  static final List<Achievement> _selfImprovementAchievements = [
    const Achievement(
      type: AchievementType.day7, // Re-using as placeholder
      id: 'self_daily_login',
      title: 'الالتزام اليومي',
      description: 'افتح التطبيق يومياً لمدة 7 أيام',
      benefits: 'الاستمرارية هي مفتاح النجاح',
      category: AchievementCategory.selfImprovement,
      rarity: AchievementRarity.common,
      icon: '📱',
      xpReward: 30,
      currentProgress: 0,
      targetProgress: 7,
    ),
  ];

  // ========================================
  // E - COMEBACK ACHIEVEMENTS
  // ========================================
  static final List<Achievement> _comebackAchievements = [
    const Achievement(
      type: AchievementType.comebackFast,
      id: 'comeback_fast_return',
      title: 'سريع العودة',
      description: 'ابدأ رحلة جديدة فوراً (خلال 24 ساعة) بعد الانتكاسة',
      benefits: 'السرعة في التوبة فضيلة',
      category: AchievementCategory.comeback,
      rarity: AchievementRarity.rare,
      icon: '🔄',
      xpReward: 50,
    ),
    const Achievement(
      type: AchievementType.comebackPhoenix,
      id: 'comeback_phoenix',
      title: 'طائر العنقاء',
      description: 'ابدأ من جديد وحقق 30 يوماً بعد الانتكاسة',
      benefits: 'النهوض بعد السقوط قوة حقيقية',
      category: AchievementCategory.comeback,
      rarity: AchievementRarity.epic,
      icon: '🔥',
      xpReward: 200,
    ),
  ];

  // ========================================
  // F - LEGENDARY ACHIEVEMENTS
  // ========================================
  static final List<Achievement> _legendaryAchievements = [
    const Achievement(
      type: AchievementType.perfectMonth,
      id: 'legendary_perfect_month',
      title: 'الشهر المثالي',
      description: '30 يوماً نظيفاً + جميع الصلوات + لا زلات',
      benefits: 'الكمال في الالتزام',
      category: AchievementCategory.legendary,
      rarity: AchievementRarity.legendary,
      icon: '💫',
      xpReward: 500,
    ),
  ];

  // ========================================
  // G - HIDDEN ACHIEVEMENTS
  // ========================================
  static final List<Achievement> _hiddenAchievements = [
    const Achievement(
      type: AchievementType.hiddenSecret1,
      id: 'hidden_midnight_warrior',
      title: '???',
      description: 'إنجاز سري - اكتشفه بنفسك',
      benefits: 'مكافأة خاصة جداً',
      category: AchievementCategory.hidden,
      rarity: AchievementRarity.legendary,
      icon: '❓',
      xpReward: 300,
      isHidden: true,
    ),
    const Achievement(
      type: AchievementType.hiddenSecret2,
      id: 'hidden_early_bird',
      title: '???',
      description: 'إنجاز سري - اكتشفه بنفسك',
      benefits: 'مكافأة خاصة جداً',
      category: AchievementCategory.hidden,
      rarity: AchievementRarity.legendary,
      icon: '🎁',
      xpReward: 300,
      isHidden: true,
    ),
  ];

  /// Get achievements by category
  static List<Achievement> getByCategory(AchievementCategory category) {
    return getAllAchievements()
        .where((a) => a.category == category)
        .toList();
  }

  /// Get achievements by rarity
  static List<Achievement> getByRarity(AchievementRarity rarity) {
    return getAllAchievements()
        .where((a) => a.rarity == rarity)
        .toList();
  }

  /// Get achievement by ID
  static Achievement? getById(String id) {
    try {
      return getAllAchievements().firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }
}
