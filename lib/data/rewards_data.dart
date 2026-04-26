import '../models/reward.dart';

/// Rewards Catalog
/// All available rewards in the shop
class RewardsData {
  static final List<Reward> allRewards = [
    // Theme Rewards
    const Reward(
      id: 'theme_ocean',
      title: 'ثيم المحيط',
      description: 'ألوان أزرق وأخضر مريحة للعين',
      type: RewardType.theme,
      cost: 50,
      themeId: 'ocean',
      icon: '🌊',
    ),
    const Reward(
      id: 'theme_sunset',
      title: 'ثيم الغروب',
      description: 'ألوان دافئة برتقالية وردية',
      type: RewardType.theme,
      cost: 50,
      themeId: 'sunset',
      icon: '🌅',
    ),
    const Reward(
      id: 'theme_forest',
      title: 'ثيم الغابة',
      description: 'ألوان خضراء طبيعية',
      type: RewardType.theme,
      cost: 50,
      themeId: 'forest',
      icon: '🌲',
    ),
    const Reward(
      id: 'theme_purple',
      title: 'ثيم البنفسجي',
      description: 'ألوان بنفسجية وزرقاء',
      type: RewardType.theme,
      cost: 75,
      themeId: 'purple',
      icon: '💜',
    ),
    const Reward(
      id: 'theme_gold',
      title: 'ثيم الذهبي',
      description: 'ألوان ذهبية فاخرة',
      type: RewardType.theme,
      cost: 100,
      themeId: 'gold',
      icon: '✨',
    ),
    const Reward(
      id: 'theme_moonlight',
      title: 'ثيم ضوء القمر',
      description: 'ألوان فضية وزرقاء ليلية',
      type: RewardType.theme,
      cost: 100,
      themeId: 'moonlight',
      icon: '🌙',
    ),

    // Badge Rewards
    const Reward(
      id: 'badge_warrior',
      title: 'شارة المحارب',
      description: 'شارة تظهر قوتك وإصرارك',
      type: RewardType.badge,
      cost: 150,
      icon: '⚔️',
    ),
    const Reward(
      id: 'badge_phoenix',
      title: 'شارة العنقاء',
      description: 'رمز النهوض من جديد',
      type: RewardType.badge,
      cost: 200,
      icon: '🔥',
    ),
    const Reward(
      id: 'badge_saint',
      title: 'شارة الصالح',
      description: 'تمنح للملتزمين بالعبادات',
      type: RewardType.badge,
      cost: 250,
      icon: '👼',
    ),

    // Feature Rewards
    const Reward(
      id: 'feature_stats',
      title: 'إحصائيات متقدمة',
      description: 'رسوم بيانية تفصيلية لتقدمك',
      type: RewardType.feature,
      cost: 100,
      icon: '📊',
    ),
    const Reward(
      id: 'feature_goals',
      title: 'أهداف مخصصة',
      description: 'أنشئ أهدافك الخاصة',
      type: RewardType.feature,
      cost: 150,
      icon: '🎯',
    ),
    const Reward(
      id: 'feature_export',
      title: 'تصدير البيانات',
      description: 'صدّر تقدمك وإنجازاتك',
      type: RewardType.feature,
      cost: 75,
      icon: '📤',
    ),
  ];

  /// Get rewards by type
  static List<Reward> getByType(RewardType type) {
    return allRewards.where((r) => r.type == type).toList();
  }

  /// Get reward by ID
  static Reward? getById(String id) {
    try {
      return allRewards.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get affordable rewards (based on user points)
  static List<Reward> getAffordable(int userPoints) {
    return allRewards.where((r) => r.cost <= userPoints && !r.isUnlocked).toList();
  }
}
