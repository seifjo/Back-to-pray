import 'package:flutter/material.dart';
import '../../models/level_system.dart';

/// Level Badge Widget
/// Displays current level with progress ring/bar
class LevelBadgeWidget extends StatelessWidget {
  final Level level;
  final double progress; // 0-100
  final int currentXP;
  final int? xpToNextLevel;

  const LevelBadgeWidget({
    super.key,
    required this.level,
    required this.progress,
    required this.currentXP,
    this.xpToNextLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: level.badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: level.badgeColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Level icon and number
          Stack(
            alignment: Alignment.center,
            children: [
              // Progress ring
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: progress / 100,
                  strokeWidth: 6,
                  backgroundColor: Colors.white10,
                  valueColor: AlwaysStoppedAnimation<Color>(level.badgeColor),
                ),
              ),
              // Level badge
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      level.badgeColor,
                      level.badgeColor.withValues(alpha: 0.7),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: level.badgeColor.withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    level.badgeIcon,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Level title
          Text(
            level.titleArabic,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: level.badgeColor,
            ),
          ),

          const SizedBox(height: 4),

          // Level number
          Text(
            'المستوى ${level.level}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),

          const SizedBox(height: 12),

          // XP progress bar
          if (xpToNextLevel != null) ...[
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerRight,
                widthFactor: progress / 100,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        level.badgeColor,
                        level.badgeColor.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$currentXP / ${currentXP + xpToNextLevel!} XP',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white54,
              ),
            ),
          ] else ...[
            const Text(
              'أعلى مستوى!',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFD700),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
