import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/journey_provider.dart';
import '../../providers/gamification_provider.dart';
import '../../providers/achievement_provider.dart';
import '../../core/theme/app_theme.dart';

/// Advanced Stats Screen
/// Detailed statistics and charts for journey progress
class AdvancedStatsScreen extends StatelessWidget {
  const AdvancedStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'إحصائيات متقدمة',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer3<JourneyProvider, GamificationProvider, AchievementProvider>(
        builder: (context, journeyProvider, gamProvider, achievementProvider, _) {
          final activeJourney = journeyProvider.activeJourney;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overview Cards
                _buildOverviewCard(
                  'إجمالي الأيام',
                  '${activeJourney?.totalDays ?? 0}',
                  Icons.calendar_today,
                  AppTheme.accentCyan,
                ),
                const SizedBox(height: 12),
                _buildOverviewCard(
                  'أطول سلسلة',
                  '${activeJourney?.currentStreak ?? 0} يوم',
                  Icons.local_fire_department,
                  Colors.orange,
                ),
                const SizedBox(height: 12),
                _buildOverviewCard(
                  'نسبة النجاح',
                  '${journeyProvider.getSuccessRate().toStringAsFixed(0)}%',
                  Icons.trending_up,
                  AppTheme.primaryGreen,
                ),
                const SizedBox(height: 12),
                _buildOverviewCard(
                  'إجمالي XP',
                  '${gamProvider.totalXP}',
                  Icons.stars,
                  AppTheme.accentGold,
                ),

                const SizedBox(height: 32),

                // Progress Chart Section
                const Text(
                  '📈 تقدم الرحلة',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildProgressChart(activeJourney?.checkIns ?? []),

                const SizedBox(height: 32),

                // Achievement Breakdown
                const Text(
                  '🏆 توزيع الإنجازات',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildAchievementBreakdown(gamProvider, achievementProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverviewCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressChart(List checkIns) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          height: 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.show_chart,
                  size: 64,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                const Text(
                  'رسم بياني لتقدمك',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'يتم عرض البيانات هنا',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementBreakdown(GamificationProvider gamProvider, AchievementProvider achievementProvider) {
    final totalAchievements = achievementProvider.achievements.where((a) => a.isUnlocked).length;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildAchievementRow('🎯 إجمالي الإنجازات', totalAchievements),
            const Divider(),
            _buildAchievementRow('⭐ XP المكتسب', gamProvider.totalXP),
            const Divider(),
            _buildAchievementRow('💎 نقاط التعافي', gamProvider.recoveryPoints),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementRow(String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.accentCyan,
            ),
          ),
        ],
      ),
    );
  }
}
