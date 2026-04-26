import '../models/daily_achievement.dart';

/// Daily Achievements Data
/// Catalog of all daily trackable achievements
class DailyAchievementsData {
  static final List<DailyAchievement> allDailyAchievements = [
    // Prayer Achievements
    const DailyAchievement(
      id: 'prayer_all_five',
      title: 'الصلوات الخمس',
      description: 'أدِّ جميع الصلوات الخمس في وقتها',
      category: DailyAchievementCategory.prayer,
      xpReward: 50,
      pointsReward: 10,
    ),
    const DailyAchievement(
      id: 'prayer_fajr',
      title: 'صلاة الفجر',
      description: 'صلِّ الفجر في وقته',
      category: DailyAchievementCategory.prayer,
      xpReward: 20,
      pointsReward: 5,
    ),
    const DailyAchievement(
      id: 'prayer_congregation',
      title: 'الصلاة في جماعة',
      description: 'صلِّ صلاة واحدة على الأقل في المسجد او في جماعة',
      category: DailyAchievementCategory.prayer,
      xpReward: 15,
      pointsReward: 3,
    ),

    // Quran Achievements
    const DailyAchievement(
      id: 'quran_daily_read',
      title: 'قراءة يومية',
      description: 'اقرأ أي قدر من القرآن اليوم',
      category: DailyAchievementCategory.quran,
      xpReward: 20,
      pointsReward: 5,
    ),
    const DailyAchievement(
      id: 'quran_page',
      title: 'صفحة قرآن',
      description: 'اقرأ صفحة كاملة من القرآن',
      category: DailyAchievementCategory.quran,
      xpReward: 15,
      pointsReward: 3,
    ),
    const DailyAchievement(
      id: 'quran_juz',
      title: 'جزء كامل',
      description: 'اختم جزءاً كاملاً من القرآن',
      category: DailyAchievementCategory.quran,
      xpReward: 100,
      pointsReward: 20,
    ),

    // Adhkar Achievements
    const DailyAchievement(
      id: 'adhkar_morning',
      title: 'أذكار الصباح',
      description: 'اقرأ أذكار الصباح كاملة',
      category: DailyAchievementCategory.adhkar,
      xpReward: 15,
      pointsReward: 3,
    ),
    const DailyAchievement(
      id: 'adhkar_evening',
      title: 'أذكار المساء',
      description: 'اقرأ أذكار المساء كاملة',
      category: DailyAchievementCategory.adhkar,
      xpReward: 15,
      pointsReward: 3,
    ),
    const DailyAchievement(
      id: 'adhkar_sleep',
      title: 'أذكار النوم',
      description: 'اقرأ أذكار النوم قبل النوم',
      category: DailyAchievementCategory.adhkar,
      xpReward: 10,
      pointsReward: 2,
    ),

    // Sleep Achievements
    const DailyAchievement(
      id: 'sleep_early',
      title: 'نوم مبكر',
      description: 'نم قبل الساعة 11 مساءً',
      category: DailyAchievementCategory.sleep,
      xpReward: 15,
      pointsReward: 3,
    ),
    const DailyAchievement(
      id: 'sleep_8hours',
      title: '8 ساعات نوم',
      description: 'احصل على 7-8 ساعات من النوم',
      category: DailyAchievementCategory.sleep,
      xpReward: 10,
      pointsReward: 2,
    ),

    // Exercise Achievements
    const DailyAchievement(
      id: 'exercise_cardio',
      title: 'تمرين يومي',
      description: 'مارس الرياضة لمدة 20 دقيقة على الأقل',
      category: DailyAchievementCategory.exercise,
      xpReward: 20,
      pointsReward: 5,
    ),
    const DailyAchievement(
      id: 'exercise_walk',
      title: 'المشي',
      description: 'امشِ 15 دقيقة على الأقل',
      category: DailyAchievementCategory.exercise,
      xpReward: 10,
      pointsReward: 2,
    ),
    const DailyAchievement(
      id: 'exercise_strength',
      title: 'تمارين القوة',
      description: 'مارس تمارين المقاومة أو القوة',
      category: DailyAchievementCategory.exercise,
      xpReward: 15,
      pointsReward: 3,
    ),
  ];

  /// Get achievements by category
  static List<DailyAchievement> getByCategory(DailyAchievementCategory category) {
    return allDailyAchievements.where((a) => a.category == category).toList();
  }

  /// Get achievement by ID
  static DailyAchievement? getById(String id) {
    try {
      return allDailyAchievements.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }
}
