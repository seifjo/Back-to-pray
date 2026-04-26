import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/achievement_provider.dart';
import '../../providers/gamification_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/achievement.dart';
import '../../widgets/gamification/achievement_card.dart';
import '../../widgets/gamification/streak_display_widget.dart';
import '../../widgets/gamification/level_badge_widget.dart';
import '../daily_achievements/daily_achievements_screen.dart';
import '../rewards/rewards_shop_screen.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  AchievementCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'الإنجازات والتقدم',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'الإنجازات'),
            Tab(text: 'إحصائيات'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAchievementsTab(),
          _buildStatsTab(),
        ],
      ),
    );
  }

  Widget _buildAchievementsTab() {
    return Consumer<AchievementProvider>(
      builder: (context, provider, _) {
        final stats = provider.getStatistics();
        final displayAchievements = _selectedCategory == null
            ? provider.achievements
            : provider.getByCategory(_selectedCategory!);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Quick Access Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DailyAchievementsScreen(),
                        ),
                      ),
                      icon: const Icon(Icons.today),
                      label: const Text('إنجازات يومية'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RewardsShopScreen(),
                        ),
                      ),
                      icon: const Icon(Icons.shopping_bag),
                      label: const Text('متجر المكافآت'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentGold,
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Progress Summary
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryGreen.withValues(alpha: 0.3),
                      AppTheme.secondaryGreen.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      '🏆',
                      '${stats['unlocked']}/${stats['total']}',
                      'مفتوحة',
                    ),
                    _buildStatItem(
                      '⭐',
                      '${stats['legendary']}',
                      'أسطورية',
                    ),
                    _buildStatItem(
                      '💜',
                      '${stats['epic']}',
                      'ملحمية',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Category Filter
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryChip('الكل', null),
                    _buildCategoryChip(
                      'الالتزام',
                      AchievementCategory.consistency,
                    ),
                    _buildCategoryChip(
                      'مقاومة الرغبات',
                      AchievementCategory.urgeResistance,
                    ),
                    _buildCategoryChip(
                      'روحانية',
                      AchievementCategory.spiritual,
                    ),
                    _buildCategoryChip(
                      'التحسين الذاتي',
                      AchievementCategory.selfImprovement,
                    ),
                    _buildCategoryChip(
                      'العودة',
                      AchievementCategory.comeback,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Achievements Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemCount: displayAchievements.length,
                itemBuilder: (context, index) {
                  final achievement = displayAchievements[index];
                  return AchievementCard(
                    achievement: achievement,
                    onTap: () => _showAchievementDetail(context, achievement),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsTab() {
    return Consumer2<GamificationProvider, AchievementProvider>(
      builder: (context, gamProvider, achieveProvider, _) {
        final userProgress = gamProvider.userProgress;
        final currentLevel = gamProvider.getCurrentLevelInfo();
        final progressToNext = gamProvider.getProgressToNextLevel();
        final xpToNext = gamProvider.getXPToNextLevel();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Streak Widget
              StreakDisplayWidget(
                currentStreak: userProgress.currentStreak,
                longestStreak: userProgress.longestStreak,
              ),

              const SizedBox(height: 16),

              // Level Badge
              LevelBadgeWidget(
                level: currentLevel,
                progress: progressToNext,
                currentXP: userProgress.totalXP,
                xpToNextLevel: xpToNext,
              ),

              const SizedBox(height: 24),

              // Motivational Message
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryGreen.withValues(alpha: 0.3),
                      AppTheme.secondaryGreen.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Text('💪', style: TextStyle(fontSize: 32)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        gamProvider.currentMotivation,
                        style: const TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF14FFEC),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              ElevatedButton.icon(
                onPressed: () async => _completeDay(context, gamProvider),
                icon: const Icon(Icons.check_circle),
                label: const Text('تسجيل التزام اليوم'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  padding: const EdgeInsets.all(16),
                ),
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: () => _confirmRelapse(context, gamProvider),
                child: const Text(
                  'تبليغ عن تعثر (بداية جديدة)',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),

              const SizedBox(height: 24),

              // Brain Recovery Stats
              const Text(
                'تعافي الدماغ',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildBrainStat(
                '🧠 توازن الدوبامين',
                userProgress.brainRecoveryStats['dopamine']!,
              ),
              _buildBrainStat(
                '🎯 التركيز',
                userProgress.brainRecoveryStats['focus']!,
              ),
              _buildBrainStat(
                '⚡ الطاقة',
                userProgress.brainRecoveryStats['energy']!,
              ),
              _buildBrainStat(
                '😊 المزاج',
                userProgress.brainRecoveryStats['mood']!,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryChip(String label, AchievementCategory? category) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? category : null;
          });
        },
        selectedColor: AppTheme.primaryGreen.withValues(alpha: 0.3),
      ),
    );
  }

  Widget _buildStatItem(String icon, String value, String label) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 32)),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF14FFEC),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white54),
        ),
      ],
    );
  }

  Widget _buildBrainStat(String title, double percentage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 14)),
              Text(
                '${percentage.toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF14FFEC),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppTheme.primaryGreen,
            ),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  void _showAchievementDetail(BuildContext context, Achievement achievement) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Text(achievement.icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                achievement.isHidden && !achievement.isUnlocked
                    ? '???'
                    : achievement.title,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!achievement.isHidden || achievement.isUnlocked) ...[
              Text(achievement.description),
              const SizedBox(height: 16),
              Text(
                'الفوائد:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(achievement.benefits),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      '+${achievement.xpReward} XP',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF14FFEC),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              const Text('إنجاز خفي - افتحه لترى التفاصيل!'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  Future<void> _completeDay(
    BuildContext context,
    GamificationProvider provider,
  ) async {
    final result = await provider.completeCleanDay();

    if (!context.mounted) return;

    // Show celebration
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          '🎉 أحسنت!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'حصلت على ${result['xpEarned']} XP',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF14FFEC),
              ),
            ),
            if (result['leveledUp']) ...[
              const SizedBox(height: 16),
              const Text(
                '🎊 مستوى جديد!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('رائع!'),
          ),
        ],
      ),
    );

    // Check achievements
    final achieveProvider = context.read<AchievementProvider>();
    final newAchievements = await achieveProvider.checkAndUnlockAchievements(
      streak: provider.currentStreak,
      totalCleanDays: provider.totalCleanDays,
    );

    if (newAchievements.isNotEmpty && context.mounted) {
      for (var achievement in newAchievements) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (context.mounted) {
          _showAchievementUnlocked(context, achievement);
        }
      }
    }
  }

  void _showAchievementUnlocked(BuildContext context, Achievement achievement) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          '🎊 إنجاز جديد!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 28),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              achievement.icon,
              style: const TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            Text(
              achievement.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              achievement.description,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '+${achievement.xpReward} XP',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF14FFEC),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('رائع!', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  void _confirmRelapse(BuildContext context, GamificationProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('هل تعثرت؟'),
        content: const Text(
          'لا بأس، العثرات جزء من الرحلة.\n\nلن تفقد XP أو إنجازاتك، فقط سنعيد ضبط السلسلة الحالية.\n\nالمهم هو العودة بقوة أكبر.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              provider.handleRelapse();
              Navigator.pop(ctx);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('لم تسقط... أنت تتعلم. ابدأ من جديد!'),
                  backgroundColor: AppTheme.primaryGreen,
                ),
              );
            },
            child: const Text(
              'نعم، بداية جديدة',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
