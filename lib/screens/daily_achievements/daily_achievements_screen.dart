import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/daily_achievements_provider.dart';
import '../../providers/gamification_provider.dart';
import '../../models/daily_achievement.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/gamification/daily_achievement_card.dart';

class DailyAchievementsScreen extends StatefulWidget {
  const DailyAchievementsScreen({super.key});

  @override
  State<DailyAchievementsScreen> createState() => _DailyAchievementsScreenState();
}

class _DailyAchievementsScreenState extends State<DailyAchievementsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
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
          'الإنجازات اليومية',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            const Tab(text: 'الكل'),
            Tab(text: DailyAchievementCategory.prayer.arabicName),
            Tab(text: DailyAchievementCategory.quran.arabicName),
            Tab(text: DailyAchievementCategory.adhkar.arabicName),
            Tab(text: DailyAchievementCategory.sleep.arabicName),
            Tab(text: DailyAchievementCategory.exercise.arabicName),
          ],
        ),
      ),
      body: Consumer2<DailyAchievementsProvider, GamificationProvider>(
        builder: (context, achievementProvider, gamProvider, _) {
          final stats = achievementProvider.getTodayStats();

          return Column(
            children: [
              // Progress Summary
              Container(
                margin: const EdgeInsets.all(16),
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
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          '✅',
                          '${stats['completed']}/${stats['total']}',
                          'مكتملة',
                        ),
                        _buildStatItem(
                          '⭐',
                          '${stats['xpEarned']}',
                          'XP مكتسبة',
                        ),
                        _buildStatItem(
                          '💎',
                          '${stats['pointsEarned']}',
                          'نقاط',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: stats['total']! > 0
                          ? stats['completed']! / stats['total']!
                          : 0.0,
                      backgroundColor: Colors.white10,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryGreen,
                      ),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),

              // Achievements List
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAchievementsList(achievementProvider.achievements),
                    _buildAchievementsList(
                      achievementProvider.getByCategory(DailyAchievementCategory.prayer),
                    ),
                    _buildAchievementsList(
                      achievementProvider.getByCategory(DailyAchievementCategory.quran),
                    ),
                    _buildAchievementsList(
                      achievementProvider.getByCategory(DailyAchievementCategory.adhkar),
                    ),
                    _buildAchievementsList(
                      achievementProvider.getByCategory(DailyAchievementCategory.sleep),
                    ),
                    _buildAchievementsList(
                      achievementProvider.getByCategory(DailyAchievementCategory.exercise),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAchievementsList(List<DailyAchievement> achievements) {
    if (achievements.isEmpty) {
      return const Center(
        child: Text('لا توجد إنجازات في هذه الفئة'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: DailyAchievementCard(
            achievement: achievement,
            onTap: () => _completeAchievement(achievement.id),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String icon, String value, String label) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 32)),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.accentCyan,
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

  Future<void> _completeAchievement(String achievementId) async {
    final provider = context.read<DailyAchievementsProvider>();
    final result = await provider.completeAchievement(achievementId);

    if (!mounted) return;

    if (result['success']) {
      _showCompletionDialog(result);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['error'] ?? 'حدث خطأ')),
      );
    }
  }

  void _showCompletionDialog(Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          '🎉 أحسنت!',
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'حصلت على ${result['xpEarned']} XP',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.accentCyan,
              ),
            ),
            Text(
              '+ ${result['pointsEarned']} نقطة تعافي',
              style: const TextStyle(fontSize: 16),
            ),
            if (result['newStreak'] > 1) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.local_fire_department, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(
                    'سلل ${result['newStreak']} أيام!',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
            if (result['isNewRecord']) ...[
              const SizedBox(height: 8),
              const Text(
                '🏆 رقم قياسي جديد!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
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
  }
}
