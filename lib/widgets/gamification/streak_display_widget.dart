import 'package:flutter/material.dart';

/// Streak Display Widget
/// Shows current streak with milestone progress
class StreakDisplayWidget extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;
  final List<int> milestones = const [3, 7, 14, 30, 60, 90, 180, 365];

  const StreakDisplayWidget({
    super.key,
    required this.currentStreak,
    required this.longestStreak,
  });

  /// Get next milestone
  int? getNextMilestone() {
    for (var milestone in milestones) {
      if (currentStreak < milestone) return milestone;
    }
    return null; // Max milestone reached
  }

  /// Get progress to next milestone (0-100)
  double getProgressToMilestone() {
    final nextMilestone = getNextMilestone();
    if (nextMilestone == null) return 100.0;

    // Find previous milestone
    int prevMilestone = 0;
    for (var milestone in milestones) {
      if (milestone >= nextMilestone) break;
      prevMilestone = milestone;
    }

    final range = nextMilestone - prevMilestone;
    final progress = currentStreak - prevMilestone;

    return (progress / range * 100).clamp(0.0, 100.0);
  }

  @override
  Widget build(BuildContext context) {
    final nextMilestone = getNextMilestone();
    final progress = getProgressToMilestone();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFF6B6B),
            Color(0xFFFF8E53),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B6B).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text(
                '🔥',
                style: TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 12),
              const Text(
                'سلسلة الالتزام',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Streak number
          Text(
            '$currentStreak',
            style: const TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.0,
            ),
          ),

          const Text(
            'أيام متتالية',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white70,
            ),
          ),

          const SizedBox(height: 20),

          // Progress to next milestone
          if (nextMilestone != null) ...[
            Text(
              'التالي: $nextMilestone يوم',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
            Stack(
              children: [
                Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white30,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: progress / 100,
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${(progress).toStringAsFixed(0)}%',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white54,
              ),
            ),
          ] else ...[
            const Text(
              '🎉 جميع المعالم تم تحقيقها!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Longest streak
          if (longestStreak > currentStreak) ...[
            Text(
              'أطول سلسلة: $longestStreak يوم',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white54,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
