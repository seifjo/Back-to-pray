import 'package:flutter/material.dart';
import '../../models/daily_achievement.dart';
import '../../core/theme/app_theme.dart';

/// Daily Achievement Card Widget
/// Displays individual daily achievement with completion status
class DailyAchievementCard extends StatelessWidget {
  final DailyAchievement achievement;
  final VoidCallback onTap;
  final bool showStreak;

const DailyAchievementCard({
    super.key,
    required this.achievement,
    required this.onTap,
    this.showStreak = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: achievement.isCompleted ? 0 : 2,
      color: achievement.isCompleted
          ? AppTheme.primaryGreen.withValues(alpha: 0.2)
          : Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: achievement.isCompleted
              ? AppTheme.primaryGreen
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: achievement.isCompleted ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: achievement.isCompleted
                      ? AppTheme.primaryGreen.withValues(alpha: 0.3)
                      : Colors.white10,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    achievement.category.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      achievement.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        decoration: achievement.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      achievement.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    if (showStreak && achievement.currentStreak > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.local_fire_department,
                            size: 16,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${achievement.currentStreak} يوم',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Reward badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.accentCyan.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '+${achievement.xpReward} XP',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accentCyan,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '+${achievement.pointsReward} نقطة',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),

              // Checkmark
              if (achievement.isCompleted) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.check_circle,
                  color: AppTheme.primaryGreen,
                  size: 32,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
