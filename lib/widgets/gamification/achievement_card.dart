import 'package:flutter/material.dart';
import '../../models/achievement.dart';

/// Achievement Card
/// Individual achievement display with lock/unlock states
class AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final VoidCallback? onTap;

  const AchievementCard({
    super.key,
    required this.achievement,
    this.onTap,
  });

  Color _getRarityColor() {
    switch (achievement.rarity) {
      case AchievementRarity.common:
        return const Color(0xFF9E9E9E);
      case AchievementRarity.rare:
        return const Color(0xFF2196F3);
      case AchievementRarity.epic:
        return const Color(0xFF9C27B0);
      case AchievementRarity.legendary:
        return const Color(0xFFFFD700);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rarityColor = _getRarityColor();
    final isLocked = !achievement.isUnlocked;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF16213E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isLocked
                ? Colors.white10
                : rarityColor.withValues(alpha: 0.5),
            width: 2,
          ),
          boxShadow: isLocked
              ? null
              : [
                  BoxShadow(
                    color: rarityColor.withValues(alpha: 0.3),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isLocked ? Colors.white10 : rarityColor.withValues(alpha: 0.2),
              ),
              child: Center(
                child: Text(
                  isLocked ? '🔒' : achievement.icon,
                  style: TextStyle(
                    fontSize: 32,
                    color: isLocked ? Colors.white30 : null,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Title
            Text(
              achievement.isHidden && isLocked ? '???' : achievement.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isLocked ? Colors.white30 : Colors.white,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 8),

            // XP reward
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isLocked ? Colors.white.withValues(alpha: 0.05) : rarityColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '+${achievement.xpReward}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isLocked ? Colors.white30 : rarityColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'XP',
                    style: TextStyle(
                      fontSize: 10,
                      color: isLocked ? Colors.white30 : rarityColor,
                    ),
                  ),
                ],
              ),
            ),

            // Unlock date (if unlocked)
            if (!isLocked && achievement.unlockedDate != null) ...[
              const SizedBox(height: 8),
              Text(
                _formatDate(achievement.unlockedDate!),
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white38,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
